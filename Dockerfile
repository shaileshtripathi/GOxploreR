# GOxploreR container image.
#
# Build (package source supplied as a named build context, so this file can
# live on a separate branch from the package code, as Bioconductor requires):
#
#   git clone https://github.com/<owner>/GOxploreR pkg            # package (default branch)
#   docker build -t goxplorer --build-context pkgsrc=./pkg .
#
# Base image: official Bioconductor image (R + RStudio Server).
# Pin the Bioconductor release so builds are reproducible.
ARG BASE_IMAGE=bioconductor/bioconductor_docker:RELEASE_3_23
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="GOxploreR" \
      org.opencontainers.image.description="Structural exploration of the Gene Ontology (GO) knowledge base" \
      org.opencontainers.image.licenses="GPL-2.0-only"

# 1. Install the package's declared dependencies (Depends/Imports/Suggests)
#    from Bioconductor/CRAN. Only missing packages are installed.
COPY --from=pkgsrc DESCRIPTION /tmp/GOxploreR/DESCRIPTION
RUN Rscript -e ' \
  d <- read.dcf("/tmp/GOxploreR/DESCRIPTION", c("Depends","Imports","Suggests")); \
  p <- trimws(sub("\\(.*", "", unlist(strsplit(d[!is.na(d)], ",")))); \
  p <- setdiff(p[nzchar(p)], c("R", rownames(installed.packages(priority = "base")))); \
  todo <- setdiff(p, rownames(installed.packages())); \
  if (length(todo)) BiocManager::install(todo, update = FALSE, ask = FALSE); \
  miss <- setdiff(p, rownames(installed.packages())); \
  if (length(miss)) stop("Failed to install: ", paste(miss, collapse = ", "))'

# 2. Install GOxploreR itself. The GO hierarchy is built from GO.db at
#    install time, so it is baked into the image (fast start-up, offline use).
COPY --from=pkgsrc . /tmp/GOxploreR
RUN R CMD INSTALL /tmp/GOxploreR && rm -rf /tmp/GOxploreR

# 3. Smoke test: fail the build if the package does not load and run.
COPY scripts/smoke-test.R /opt/goxplorer/smoke-test.R
RUN Rscript /opt/goxplorer/smoke-test.R

WORKDIR /work
# The base image's default command (/init) starts RStudio Server on :8787.
# Any other command, e.g. `Rscript script.R` or `R`, runs directly instead.

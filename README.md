# GOxploreR container (`docker` branch)

This branch holds only container tooling. The package itself lives on the
default branch, because Bioconductor requires the default branch to contain
package code only.

## Run in the browser (no install, no account)

[![Launch on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/shaileshtripathi/GOxploreR/docker?urlpath=lab)

Click the button, wait a few minutes, and RStudio opens with GOxploreR
loaded via `library(GOxploreR)`. Sessions are temporary: download your
results before closing the tab.

## Use a pre-built image

```bash
docker pull ghcr.io/shaileshtripathi/goxplorer:latest

# Run a script in the current folder (Linux/macOS; on Windows PowerShell use ${PWD})
docker run --rm -v "$PWD":/work ghcr.io/shaileshtripathi/goxplorer Rscript analysis.R

# Interactive R
docker run --rm -it ghcr.io/shaileshtripathi/goxplorer R

# RStudio in the browser at http://localhost:8787 (user: rstudio)
docker run --rm -p 8787:8787 -e PASSWORD=choose_one -v "$PWD":/home/rstudio/work ghcr.io/shaileshtripathi/goxplorer
```

HPC clusters without Docker (Apptainer/Singularity):

```bash
apptainer build goxplorer.sif docker://ghcr.io/shaileshtripathi/goxplorer:latest
apptainer exec goxplorer.sif Rscript analysis.R
```

The GO hierarchy is built from `GO.db` when the image is built, so the
level/DAG functions work offline. `Gene2GOTermAndLevel_ON()` and other
biomaRt-based calls still need internet access to Ensembl.

## Build it yourself

```bash
git clone -b docker https://github.com/shaileshtripathi/GOxploreR goxplorer-docker
cd goxplorer-docker
git clone https://github.com/shaileshtripathi/GOxploreR pkg      # package source
docker build -t goxplorer --build-context pkgsrc=./pkg .
```

Requires Docker 23+ (BuildKit named build contexts). To target another
Bioconductor release: `--build-arg BASE_IMAGE=bioconductor/bioconductor_docker:devel`.
The arm64 build in CI depends on the chosen base image publishing an arm64
variant; if it does not, drop `linux/arm64` from the workflow's `platforms`.

The workflow in `.github/workflows/docker.yml` builds amd64 + arm64 images
and pushes them to GHCR on every push to this branch.

## After Bioconductor acceptance

Once GOxploreR is in a Bioconductor release, it can be installed in any
official Bioconductor image with `BiocManager::install("GOxploreR")`.
A Bioconda recipe (`bioconductor-goxplorer`, created with bioconda-utils'
`bioconductor-skeleton`) additionally gets a BioContainers image built
automatically on quay.io/biocontainers once the recipe is merged.

# GOxploreR

Structural exploration of the Gene Ontology (GO) knowledge base.

GOxploreR provides a fast way to explore the Gene Ontology. Given a set of
genes, it returns the GO terms associated with the genes and the levels of
those terms in the GO hierarchy. It also gives access to the structure of
the GO directed acyclic graph (DAG): the terms on each level, leaf, regular
and jump nodes, reduced DAGs per organism, and rankings of GO terms. All
three ontologies are supported: biological process (BP), molecular function
(MF) and cellular component (CC).

The methods are described in:

> Manjang K, Tripathi S, Yli-Harja O, Dehmer M, Emmert-Streib F (2020).
> Graph-based exploitation of gene ontology using GOxploreR for scrutinizing
> biological significance. Scientific Reports 10(1): 16672.
> https://doi.org/10.1038/s41598-020-73326-3

## Which way should it be used?

| Option | installation needed | Package versions | Good for |
|---|---|---|---|
| 1. Browser (Binder) | Nothing | Frozen | Trying the package, short analyses |
| 2. Docker | Docker | Frozen | Reproducible analyses, long runs, offline use |
| 3. Normal R install | R packages | Existing R installation with suitable version | running with current R |

Options 1 and 2 run the same container image. R and every dependency in it
are fixed at the versions present when the image was built, so results do
not change when packages are updated later.

## 1. In the browser (nothing to install)

[![Launch on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/shaileshtripathi/GOxploreR/docker?urlpath=lab)

1. Click the button above and wait. The first start can take several minutes.
2. A JupyterLab page opens in your browser with several tiles. Click the
   **R** tile (under "Notebook" or "Console"). Do not use the RStudio tile;
   it does not work on Binder.
3. Type your commands into the empty box and press Shift+Enter to run them.
   Output and plots appear directly below:

   ```r
   library(GOxploreR)
   options(repr.plot.width = 11, repr.plot.height = 9)
   res <- visRDAGBP(organism = "Human", plot = TRUE)
   res$plot
   ```

   More examples are in the section "Visualisation examples" below.

Things to know:

- No account is needed.
- The session is temporary and closes after about 10 minutes without
  activity. Download results before closing the tab: right-click the
  file in the file list on the left, then Download.
- To use  own data, drag the file into the file list on the left, or
  use the upload button (arrow pointing up) above it.

## 2. On computer with Docker

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
(Windows, macOS) or Docker Engine (Linux) once. The first run downloads the
image (about 2 GB); after that it starts in seconds.

R prompt:

```
docker run --rm -it ghcr.io/shaileshtripathi/goxplorer:0.99.0 R
```

R prompt with access to the current folder (files  saved will appear there):

```
docker run --rm -it -v ${PWD}:/work ghcr.io/shaileshtripathi/goxplorer:0.99.0 R
```

RStudio in the browser at http://localhost:8787 (user `rstudio`, password
`goxplorer`):

```
docker run --rm -p 8787:8787 -e PASSWORD=goxplorer ghcr.io/shaileshtripathi/goxplorer:0.99.0
```

Run a script without opening R:

```
docker run --rm -v ${PWD}:/work ghcr.io/shaileshtripathi/goxplorer:0.99.0 Rscript analysis.R
```

Notes:

- `${PWD}` works in PowerShell and in Linux/macOS shells. In the Windows
  Command Prompt use `%cd%` instead.
- Without `-v ${PWD}:/work` the container cannot see your files, and
  anything saved inside it is lost when it stops.
- On HPC clusters without Docker, the same image runs with Apptainer:

  ```
  apptainer build goxplorer.sif docker://ghcr.io/shaileshtripathi/goxplorer:0.99.0
  apptainer exec goxplorer.sif Rscript analysis.R
  ```

## 3. Normal installation in R (versions not frozen)

Requires R 4.3 or later.

```r
install.packages(c("BiocManager", "remotes"))
BiocManager::install("shaileshtripathi/GOxploreR")
library(GOxploreR)
```

This installs GOxploreR from this GitHub repository together with its
dependencies from CRAN and Bioconductor (including `GO.db`). The GO
hierarchy is built from the `GO.db` version installed at that moment, so
results can differ between installations made at different times. Use
option 1 or 2 when exact reproducibility matters.

## Quick example

```r
library(GOxploreR)

# GO terms and their levels for a set of Entrez gene IDs
Gene2GOTermAndLevel(genes = c(10212, 9833, 6713),
                    organism = "Homo sapiens", domain = "BP")

# All biological-process GO terms on level 2 for human
Level2GOTermBP(level = 2, organism = "Human")

# Node category and ontology (BP, MF or CC) of GO terms
getGOcategory(c("GO:0008150", "GO:0003674", "GO:0005575"))

# Organism-specific GO-DAG as an edge list
dag <- GetDAG(organism = "Human", domain = "MF")
head(dag)
```

## Visualisation examples

These work in all three options. In Binder, plots appear below the cell;
the `options()` line only sets their size there.

```r
library(GOxploreR)
options(repr.plot.width = 11, repr.plot.height = 8)

# 1. Reduced GO-DAG of an organism: one row per GO level, with the number
#    of jump (J), regular (R) and leaf (L) nodes on each level
res <- visRDAGBP(organism = "Human", plot = TRUE)
res$plot

# 2. Where a set of GO terms sits in the DAG: the levels containing the
#    terms are highlighted and connected
Terms <- c("GO:0000278", "GO:0006414", "GO:0022403", "GO:0006415",
           "GO:0006614", "GO:0045047", "GO:0072599", "GO:0000279")
visRsubDAGBP(goterm = Terms, organism = "Human")

# 3. Ranking GO terms by depth: a line from each term's level to the
#    deepest level reachable below it
rank <- distRankingGO(goterm = Terms, domain = "BP", plot = TRUE)
rank$plot
rank$`GO-terms_ranking`

# 4. Degree distribution of the GO terms on one level
degreeDistBP(level = 4)

# Save a plot as a file
ggplot2::ggsave("go_dag_human.png", res$plot, width = 11, height = 8)
```

The MF and CC ontologies work the same way (`visRDAGMF`, `visRsubDAGCC`,
`degreeDistMF`, ...). `scoreRankingGO()` gives a score-based ranking.

Help for any function: `?Gene2GOTermAndLevel`. List of all functions:
`help(package = "GOxploreR")`.

## Supported organisms

Either the scientific or the common name can be used.

| Scientific name | Common name |
|---|---|
| Homo sapiens | Human |
| Rattus norvegicus | Rat |
| Mus musculus | Mouse |
| Danio rerio | Zebrafish |
| Caenorhabditis elegans | Worm |
| Arabidopsis thaliana | Cress |
| Saccharomyces cerevisiae | Yeast |
| Schizosaccharomyces pombe | Fission yeast |
| Drosophila melanogaster | Fruit fly |
| Escherichia coli | E.coli |

## Main functions

| Task | Functions |
|---|---|
| Genes to GO terms and levels | `Gene2GOTermAndLevel`, `Gene2GOTermAndLevel_ON` |
| Level of a GO term | `GOTermBPOnLevel`, `GOTermMFOnLevel`, `GOTermCCOnLevel` |
| GO terms on a level | `Level2GOTermBP`, `Level2GOTermMF`, `Level2GOTermCC` |
| Leaf, regular and jump nodes | `Level2LeafNodeBP`, `Level2RegularNodeBP`, `Level2JumpNodeBP`, `GetLeafNodesBP` (and MF, CC versions) |
| Descendants and children | `GO2DecBP`, `GOTermBP2ChildLevel` (and MF, CC versions) |
| Organism-specific GO-DAG | `GO4Organism`, `GetDAG` |
| Visualisation of reduced DAGs | `visRDAGBP`, `visRsubDAGBP` (and MF, CC versions) |
| Degree distribution | `degreeDistBP`, `degreeDistMF`, `degreeDistCC` |
| Ranking and prioritising GO terms | `distRankingGO`, `scoreRankingGO`, `prioritizedGOTerms` |
| Node category and ontology of a GO term | `getGOcategory` |

`Gene2GOTermAndLevel_ON()` queries Ensembl through biomaRt and needs an
internet connection.


## Container files

The Dockerfile, the GitHub Actions workflow that builds the image, and the
Binder setup are on the
[`docker` branch](https://github.com/shaileshtripathi/GOxploreR/tree/docker).

## Bug reports

Please report problems at
https://github.com/shaileshtripathi/GOxploreR/issues

## Licence

GPL-2

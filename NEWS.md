# GOxploreR 0.99.0

* Submitted to Bioconductor (previously distributed on CRAN up to 1.2.8).
* `GO.db` is now a hard dependency in `Imports`; GO hierarchies are
  obtained through a cached, lazily evaluated loader (`go_db_data()`).
* `GO4Organism()` checks that `GO.db` is available.
* Vignette installation instructions now use `BiocManager`;
  session information added.
* Added unit tests (testthat).

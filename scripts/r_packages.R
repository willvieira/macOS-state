#!/usr/bin/env Rscript
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install pak first for fast parallel installs
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

pkgs <- c(
  # Tidyverse & core wrangling
  "tidyverse",
  "data.table",
  "dtplyr",
  "janitor",
  "skimr",
  "broom",
  "modelr",
  "scales",
  "glue",
  "here",
  "fs",
  "clock",

  # Geospatial
  "sf",
  "terra",
  "stars",
  "sp",
  "tmap",
  "leaflet",
  "mapview",
  "spatstat",
  "spdep",
  "geoR",
  "gstat",
  "geodata",
  "exactextractr",
  "rasterVis",
  "whitebox",

  # DuckDB
  "duckdb",
  "duckplyr",

  # Stan / Bayesian
  "rstan",
  "rstanarm",
  "brms",
  "bayesplot",
  "tidybayes",
  "posterior",

  # Modeling & ML
  "tidymodels",
  "xgboost",
  "ranger",
  "glmnet",
  "mgcv",
  "lme4",
  "torch",

  # Visualization
  "ggdist",
  "patchwork",
  "ggrepel",
  "ggforce",
  "gganimate",
  "viridis",
  "RColorBrewer",
  "colorspace",
  "cowplot",
  "ggpubr",

  # Quarto & reporting
  "quarto",
  "rmarkdown",
  "knitr",
  "kableExtra",
  "gt",
  "gtsummary",
  "flextable",
  "DT",
  "htmlwidgets",
  "plotly",
  "reactable",

  # Package development
  "devtools",
  "usethis",
  "roxygen2",
  "testthat",
  "pkgdown",
  "covr",
  "lintr",
  "styler",
  "pak",
  "available",
  "desc",
  "lifecycle",
  "rlang",
  "cli",
  "withr",
  "vctrs",

  # Utilities
  "yaml",
  "jsonlite",
  "httr2",
  "curl",
  "future",
  "furrr",
  "doParallel",
  "foreach",
  "arrow",
  "targets",
  "tarchetypes"
)

message("Installing ", length(pkgs), " CRAN packages via pak...")
pak::pak(pkgs)

# cmdstanr from Stan r-universe
if (!requireNamespace("cmdstanr", quietly = TRUE)) {
  message("Installing cmdstanr from r-universe...")
  pak::pak("stan-dev/cmdstanr")
}

# GitHub-only packages
pak::pak("nbafrank/uvr")
uvr::install_uvr()

message("\nAll R packages installed.")

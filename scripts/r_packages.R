#!/usr/bin/env Rscript
options(repos = c(CRAN = "https://cloud.r-project.org"))

args <- commandArgs(trailingOnly = TRUE)
csv_file <- if (length(args) >= 1) normalizePath(args[1], mustWork = FALSE) else ""

# Install pak first — used for all sources
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

if (nzchar(csv_file) && file.exists(csv_file)) {
  # ── Snapshot restore path ─────────────────────────────────────────────────
  message("Restoring R packages from snapshot: ", csv_file)
  pkgs <- read.csv(csv_file, stringsAsFactors = FALSE)

  to_pak_ref <- function(pkg, src) {
    if (src == "cran")           return(pkg)
    if (src == "bioc")           return(paste0("bioc::", pkg))
    if (grepl("^github::", src)) return(sub("^github::", "", src))
    pkg  # unknown source — try by name
  }

  refs <- mapply(to_pak_ref, pkgs$Package, pkgs$Source, USE.NAMES = FALSE)

  n_gh   <- sum(grepl("^github::", pkgs$Source))
  n_bioc <- sum(pkgs$Source == "bioc")
  n_cran <- sum(pkgs$Source == "cran")
  message("Installing ", nrow(pkgs), " packages (",
          n_cran, " CRAN, ", n_gh, " GitHub, ", n_bioc, " Bioc)...")

  pak::pak(refs)

  # uvr requires a post-install step regardless of source
  if ("uvr" %in% pkgs$Package) {
    message("Running uvr::install_uvr()...")
    uvr::install_uvr()
  }

} else {
  # ── Fresh machine path (no snapshot) ─────────────────────────────────────
  message("No r-packages.csv snapshot found — installing curated package list...")

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
    "languageserver",
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

  # uvr from GitHub
  pak::pak("nbafrank/uvr-r")
  uvr::install_uvr()
}

message("\nAll R packages installed.")

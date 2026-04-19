#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

if ! command -v Rscript &>/dev/null; then
  echo "  Rscript not found — skipping"
  exit 0
fi

Rscript - "$SNAPSHOTS_DIR/r-packages.csv" <<'REOF'
args <- commandArgs(trailingOnly = TRUE)
out_file <- args[1]

pkgs <- as.data.frame(
  installed.packages()[, c("Package", "Version")],
  stringsAsFactors = FALSE
)

get_source <- function(pkg) {
  desc <- tryCatch(as.list(packageDescription(pkg)), error = function(e) list())
  rt <- desc$RemoteType
  if (!is.null(rt) && rt == "github") {
    return(paste0("github::", desc$RemoteUsername, "/", desc$RemoteRepo))
  }
  if (requireNamespace("BiocManager", quietly = TRUE)) {
    bioc_pkgs <- tryCatch(BiocManager::installed(), error = function(e) character(0))
    if (pkg %in% bioc_pkgs) return("bioc")
  }
  "cran"
}

pkgs$Source <- sapply(pkgs$Package, get_source)

# Non-CRAN wins: sort non-cran first, deduplicate by Package, then re-sort alphabetically
pkgs <- pkgs[order(pkgs$Source == "cran"), ]
pkgs <- pkgs[!duplicated(pkgs$Package), ]
pkgs <- pkgs[order(pkgs$Package), ]

write.csv(pkgs, file = out_file, row.names = FALSE)

n_gh   <- sum(grepl("^github::", pkgs$Source))
n_bioc <- sum(pkgs$Source == "bioc")
n_cran <- sum(pkgs$Source == "cran")
message("  ", nrow(pkgs), " packages captured (",
        n_cran, " CRAN, ", n_gh, " GitHub, ", n_bioc, " Bioc)",
        " -> snapshots/r-packages.csv")
REOF

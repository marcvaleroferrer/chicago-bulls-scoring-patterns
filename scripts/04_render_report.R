source("R/load.R")
require_packages(c("rmarkdown", "knitr"))
if (!rmarkdown::pandoc_available()) stop("Pandoc missing: render inside RStudio or configure RSTUDIO_PANDOC")
rmarkdown::render("reports/analysis.Rmd", knit_root_dir = normalizePath("."),
  envir = new.env(parent = globalenv()), quiet = FALSE)
dir.create("results/reproduced", recursive = TRUE, showWarnings = FALSE)
write_session("results/reproduced/session_report.txt")

require_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "),
    ". See installation commands in README.md.")
}

write_session <- function(path) {
  writeLines(sub("[[:blank:]]+$", "", capture.output(sessionInfo())), path)
}

save_plot <- function(object, path, ylim = NULL) {
  png(path, width = 1000, height = 700)
  on.exit(dev.off())
  plot(object, ylim = ylim)
  invisible(path)
}

comparison_limits <- function(...) {
  fits <- list(...)
  c(0, max(vapply(fits, function(x) max(predict(x)$intensity, coef(x)[1]), numeric(1))) * 1.05)
}

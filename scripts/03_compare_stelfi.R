source("R/load.R")
require_packages("stelfi")
output <- "results/reproduced"
if (!file.exists(file.path(output, "deoptim_fits.rds"))) stop("Run scripts/02_fit_deoptim.R first")
deoptim <- readRDS(file.path(output, "deoptim_fits.rds"))
stelfi <- lapply(deoptim, function(x) fit(x$model, x$data, engine = "stelfi"))
comparison <- do.call(rbind, lapply(c(deoptim, stelfi), as.data.frame))
write.csv(comparison, file.path(output, "comparison.csv"), row.names = FALSE)
saveRDS(stelfi, file.path(output, "stelfi_fits.rds"))

warnings <- data.frame(case = character(), warning = character())
for (name in names(stelfi)) {
  if (length(stelfi[[name]]$warnings)) {
    warnings <- rbind(warnings, data.frame(case = name, warning = stelfi[[name]]$warnings))
  }
  limits <- comparison_limits(deoptim[[name]], stelfi[[name]])
  save_plot(deoptim[[name]], file.path(output, paste0(name, "_deoptim.png")), ylim = limits)
  save_plot(stelfi[[name]], file.path(output, paste0(name, "_stelfi.png")), ylim = limits)
}
write.csv(warnings, file.path(output, "stelfi_warnings.csv"), row.names = FALSE)
write_session(file.path(output, "session_stelfi.txt"))

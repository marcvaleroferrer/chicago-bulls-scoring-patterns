# Check saved fit objects in a fresh session without running optimizers.
source("R/load.R")
output <- "results/reproduced"
paths <- file.path(output, c("deoptim_fits.rds", "stelfi_fits.rds", "team_season_fit.rds"))
if (!all(file.exists(paths))) stop("Run fitting scripts 02 and 03 first")
deoptim <- readRDS(paths[1])
stelfi <- readRDS(paths[2])
season <- readRDS(paths[3])
close <- function(x, y) stopifnot(isTRUE(all.equal(x, y, tolerance = 1e-10)))
for (result in c(deoptim, stelfi, list(season))) {
  stopifnot(inherits(result, "scoring_fit"),
    identical(names(coef(result)), c("mu", "theta", "phi")),
    nobs(result) == nrow(result$data$baskets), all(is.finite(coef(result))))
  score <- objective(result$model, result$data, cached = FALSE)
  close(score(coef(result)), result$negative_log_likelihood)
  row <- as.data.frame(result)
  close(unname(unlist(row[c("mu", "theta", "phi")])), unname(coef(result)))
  if (result$method == "DEoptim") {
    close(result$optimizer_objective, result$negative_log_likelihood)
    stopifnot(result$iterations == 1000L, result$evaluations > 0)
  }
  prediction <- predict(result, match_id = result$data$horizons$match_id[1])
  stopifnot(all(is.finite(prediction$intensity)), all(prediction$intensity >= coef(result)[1]))
}
for (name in names(deoptim)) {
  limits <- comparison_limits(deoptim[[name]], stelfi[[name]])
  stopifnot(limits[1] == 0, limits[2] >= max(predict(stelfi[[name]])$intensity),
            limits[2] >= max(predict(deoptim[[name]])$intensity))
}
rejects <- function(expr) stopifnot(tryCatch({force(expr); FALSE}, error = function(e) TRUE))
rejects(predict(season))
rejects(predict(deoptim[[1]], match_id = 999))
rejects(predict(deoptim[[1]], newdata = -1))
message("PASS: saved S3 fits, diagnostics, scores, predictions and comparison scales.")

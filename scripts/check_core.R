# Checks on the supplied data and numerical conventions; no optimizer is run.
source("R/load.R")
close <- function(x, y) stopifnot(isTRUE(all.equal(x, y, tolerance = 1e-10)))
expect_error <- function(expr) {
  failed <- tryCatch({ force(expr); FALSE }, error = function(e) TRUE)
  stopifnot(failed)
}
data <- scoring_data()
baskets <- as.data.frame(data)
stopifnot(inherits(data, "scoring_data"), nrow(baskets) == 3566,
  nrow(data$games) == 84, sum(baskets$tipo == "2") == 2697,
  sum(baskets$tipo == "3") == 869, !anyNA(baskets))
game <- series(data, games = 7)
midpoint <- scoring_model("midpoint")
trapezoid_model <- scoring_model("trapezoid")
mu <- 0.7
end <- game$horizons$t_max
close(objective(midpoint, game)(c(mu, 0, 1)), mu * end - nobs(game) * log(mu))
close(objective(trapezoid_model, game)(c(mu, 0, 1)), mu * (end - 1) - nobs(game) * log(mu))
close(intensity(midpoint, 1, c(1, 2), c(.7, .2, 1)), .7)
close(intensity(midpoint, 2, c(1, 2), c(.7, .2, 1)), .7 + .2 * exp(-1))

parameters <- list(c(.7,.1,1), c(.9,0,60), c(.1,.5,0), c(0,0,0), c(2,2,100))
cases <- selected_cases()
events <- lapply(seq_len(nrow(cases)), function(i)
  series(data, subject = cases$subject[i], games = cases$match_id[i]))
events <- c(events, list(series(data), series(data, games = c(7, 70))))
for (x in events) {
  for (rule in c("midpoint", "trapezoid")) {
    model <- scoring_model(rule)
    cached <- objective(model, x)
    scalar <- objective(model, x, cached = FALSE)
    for (p in parameters) close(cached(p), scalar(p))
  }
}
two_games <- objective(trapezoid_model, series(data, games = c(7, 70)))
single_games <- lapply(c(7, 70), function(id) objective(trapezoid_model, series(data, games = id)))
for (p in parameters) close(two_games(p), sum(vapply(single_games, function(f) f(p), numeric(1))))

expect_error(series(data, games = 999))
expect_error(series(data, games = c(7, 7)))
expect_error(series(data, subject = "Unknown player"))
expect_error(series(data, games = numeric()))
expect_error(scoring_model("unknown"))
expect_error(scoring_model(upper = c(0, 2, 100)))
expect_error(objective(midpoint, baskets))
expect_error(objective(midpoint, game)(c(.7, NA, 1)))
expect_error(objective(midpoint, game)(c(.7, -.1, 1)))
bad <- data
bad$baskets$tiempo[1] <- NA_real_
expect_error(series(bad))
close(objective(midpoint, game)(c(phi = 1, theta = .1, mu = .7)),
      objective(midpoint, game)(c(.7, .1, 1)))
message("PASS: S3 data, series, model, numerical equivalence and invalid-input checks.")

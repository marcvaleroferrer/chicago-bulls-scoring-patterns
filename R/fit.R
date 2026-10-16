fit <- function(object, ...) UseMethod("fit")

fit.scoring_model <- function(object, data, engine = c("DEoptim", "stelfi"),
                              seed = NULL, ...) {
  engine <- match.arg(engine)
  if (!inherits(data, "scoring_series")) stop("data must be a scoring_series")
  require_packages(engine)
  score <- objective(object, data)
  warnings <- character()
  result <- withCallingHandlers({
    if (engine == "DEoptim") {
      if (!is.numeric(seed) || length(seed) != 1L || !is.finite(seed) ||
          seed < 0 || seed > .Machine$integer.max || seed != as.integer(seed)) {
        stop("Provide an integer seed for DEoptim")
      }
      set.seed(seed)
      raw <- DEoptim::DEoptim(fn = score, lower = unname(object$lower),
        upper = unname(object$upper),
        control = DEoptim::DEoptim.control(itermax = object$itermax, trace = FALSE))
      list(parameters = raw$optim$bestmem, optimizer_objective = raw$optim$bestval,
        iterations = raw$optim$iter, evaluations = raw$optim$nfeval)
    } else {
      if (nrow(data$horizons) != 1L) stop("The selected stelfi comparison is single-game only")
      raw <- stelfi::fit_hawkes(times = data$baskets$tiempo,
        parameters = c(mu = 0.05, alpha = 0.05, beta = 1))
      list(parameters = as.numeric(stelfi::get_coefs(raw)[1:3]),
        optimizer_objective = raw$objective, iterations = NA_integer_, evaluations = NA_integer_)
    }
  }, warning = function(w) warnings <<- c(warnings, conditionMessage(w)))
  parameters <- model_parameters(unname(result$parameters))
  structure(list(model = object, data = data, coefficients = parameters,
    method = engine, seed = if (engine == "DEoptim") as.integer(seed) else NA_integer_,
    negative_log_likelihood = score(parameters), optimizer_objective = result$optimizer_objective,
    iterations = result$iterations, evaluations = result$evaluations,
    warnings = warnings), class = "scoring_fit")
}

coef.scoring_fit <- function(object, ...) object$coefficients

nobs.scoring_fit <- function(object, ...) nobs(object$data)

print.scoring_fit <- function(x, ...) {
  cat(x$data$subject, "-", x$data$label, "(", x$method, ")\n", sep = " ")
  print(coef(x))
  cat("Scored negative log-likelihood:", format(x$negative_log_likelihood), "\n")
  if (length(x$warnings)) cat("Recorded warnings:", length(x$warnings), "\n")
  invisible(x)
}

as.data.frame.scoring_fit <- function(x, ...) {
  h <- x$data$horizons
  p <- coef(x)
  data.frame(case = x$data$label, subject = x$data$subject,
    match_id = if (nrow(h) == 1L) h$match_id else NA_real_, games = nrow(h),
    method = x$method, integration = x$model$integration,
    t_max = if (nrow(h) == 1L) h$t_max else NA_real_, seed = x$seed,
    iterations = x$iterations, evaluations = x$evaluations,
    mu = unname(p[1]), theta = unname(p[2]), phi = unname(p[3]),
    negative_log_likelihood = x$negative_log_likelihood,
    optimizer_objective = x$optimizer_objective, warning_count = length(x$warnings))
}

predict.scoring_fit <- function(object, newdata = NULL, match_id = NULL, ...) {
  h <- object$data$horizons
  if (is.null(match_id)) {
    if (nrow(h) != 1L) stop("Choose match_id for a multi-game fit")
    match_id <- h$match_id[1]
  }
  if (length(match_id) != 1L || is.na(match_id) || !match_id %in% h$match_id) {
    stop("match_id is not in this fit")
  }
  end <- h$t_max[match(match_id, h$match_id)]
  if (is.null(newdata)) newdata <- seq(0.5, end - 0.5, by = 1)
  if (!is.numeric(newdata) || any(!is.finite(newdata)) || any(newdata < 0 | newdata > end)) {
    stop("Prediction times must lie inside the observation window")
  }
  times <- object$data$baskets$tiempo[object$data$baskets$match_id == match_id]
  data.frame(time = newdata, intensity = intensity(object$model, newdata, times, coef(object)))
}

plot.scoring_fit <- function(x, match_id = NULL, ylim = NULL, main = NULL, ...) {
  values <- predict(x, match_id = match_id)
  if (is.null(match_id)) match_id <- x$data$horizons$match_id[1]
  times <- x$data$baskets$tiempo[x$data$baskets$match_id == match_id]
  if (is.null(ylim)) ylim <- c(0, max(values$intensity, coef(x)[1]) * 1.05)
  if (is.null(main)) main <- paste(x$data$subject, "- game", match_id, "(", x$method, ")")
  plot(values$time, values$intensity, type = "l", col = "#2456A6", lwd = 2,
    xlab = "Game time (minutes)", ylab = expression(lambda(t)), ylim = ylim, main = main, ...)
  points(times, rep(coef(x)[1], length(times)), col = "#C53030", pch = 16, cex = 0.55)
  legend("topright", c("Conditional intensity", "Made field goals"),
    col = c("#2456A6", "#C53030"), lty = c(1, NA), pch = c(NA, 16), cex = 0.8)
  invisible(x)
}

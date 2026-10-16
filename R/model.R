scoring_model <- function(integration = c("midpoint", "trapezoid"),
                          lower = c(0, 0, 0), upper = c(2, 2, 100),
                          itermax = 1000L) {
  integration <- match.arg(integration)
  lower <- model_parameters(lower)
  upper <- model_parameters(upper)
  if (any(upper <= lower)) stop("Each upper bound must exceed its lower bound")
  if (!is.numeric(itermax) || length(itermax) != 1L || !is.finite(itermax) ||
      itermax < 1 || itermax > .Machine$integer.max || itermax != as.integer(itermax)) {
    stop("itermax must be a positive integer")
  }
  structure(list(integration = integration, lower = lower, upper = upper,
    itermax = as.integer(itermax)), class = "scoring_model")
}

model_parameters <- function(parameters) {
  expected <- c("mu", "theta", "phi")
  if (!is.numeric(parameters) || length(parameters) != 3L ||
      any(!is.finite(parameters)) || any(parameters < 0)) {
    stop("Parameters must be three finite, non-negative numbers: mu, theta, phi")
  }
  if (!is.null(names(parameters))) {
    if (!setequal(names(parameters), expected)) stop("Parameter names must be mu, theta, phi")
    parameters <- parameters[expected]
  }
  setNames(as.numeric(parameters), expected)
}

print.scoring_model <- function(x, ...) {
  cat("Temporal self-exciting model\nIntegration:", x$integration,
      "\nDEoptim iterations:", x$itermax, "\n")
  invisible(x)
}

intensity <- function(object, ...) UseMethod("intensity")

intensity.scoring_model <- function(object, times, history, parameters, ...) {
  parameters <- model_parameters(parameters)
  vapply(times, function(t) parameters[1] + sum(parameters[2] *
    exp(-parameters[3] * (t - history[history < t]))), numeric(1), USE.NAMES = FALSE)
}

trapezoid <- function(a, b, n, f) {
  grid <- seq(a, b, length.out = n + 1)
  h <- (b - a) / n
  (h / 2) * (f(a) + 2 * sum(sapply(grid[2:n], f)) + f(b))
}

objective <- function(object, ...) UseMethod("objective")

objective.scoring_model <- function(object, data, cached = TRUE, ...) {
  if (!inherits(data, "scoring_series")) stop("data must be a scoring_series")
  if (!is.logical(cached) || length(cached) != 1L || is.na(cached)) stop("Invalid cache option")
  if (cached) {
    terms <- lapply(seq_len(nrow(data$horizons)), function(i) {
      times <- data$baskets$tiempo[data$baskets$match_id == data$horizons$match_id[i]]
      cached_terms(times, data$horizons$t_max[i], object$integration)
    })
  } else {
    terms <- lapply(seq_len(nrow(data$horizons)), function(i) {
      times <- data$baskets$tiempo[data$baskets$match_id == data$horizons$match_id[i]]
      end <- data$horizons$t_max[i]
      function(parameters) {
        grid <- seq(0.5, end - 0.5, by = 1)
        f <- function(t) intensity(object, t, times, parameters)
        integral <- if (object$integration == "midpoint") sum(sapply(grid, f)) else
          trapezoid(0.5, end - 0.5, length(grid), f)
        c(log_sum = sum(log(pmax(sapply(times, f), .Machine$double.eps))), integral = integral)
      }
    })
  }
  function(parameters) {
    parameters <- model_parameters(parameters)
    log_sum <- 0
    integral_sum <- 0
    for (term in terms) {
      value <- term(parameters)
      log_sum <- log_sum + value[1]
      integral_sum <- integral_sum - value[2]
    }
    unname(-(log_sum + integral_sum))
  }
}

# Time differences and quadrature weights are constant during optimization.
cached_terms <- function(times, t_max, integration) {
  grid <- seq(0.5, t_max - 0.5, by = 1)
  if (integration == "trapezoid") {
    n <- length(grid)
    grid <- seq(0.5, t_max - 0.5, length.out = n + 1)
    weights <- rep((t_max - 1) / n, n + 1)
    weights[c(1, n + 1)] <- weights[c(1, n + 1)] / 2
  } else {
    weights <- rep(1, length(grid))
  }
  lags <- outer(c(times, grid), times, "-")
  prior <- lags > 0
  lags[!prior] <- 0
  function(parameters) {
    values <- parameters[1] + parameters[2] * rowSums(exp(-parameters[3] * lags) * prior)
    c(log_sum = sum(log(pmax(values[seq_along(times)], .Machine$double.eps))),
      integral = sum(weights * values[length(times) + seq_along(grid)]))
  }
}

# Constructors for the input data and event sequences.
scoring_data <- function(path = "data/raw/shots_CHI.RData") {
  input <- new.env(parent = baseenv())
  if (!file.exists(path)) stop("Input file not found: ", path)
  objects <- load(path, envir = input)
  if (!"data_shots_CHI" %in% objects) stop("Input must contain data_shots_CHI")
  shots <- input$data_shots_CHI
  required <- c("period", "elapsed", "type", "numeric_res", "match_id",
                "player", "game_id", "date", "data_set")
  if (!is.data.frame(shots) || !all(required %in% names(shots))) {
    stop("Input does not have the expected shot-data columns")
  }
  keep <- shots$numeric_res == 1 & !grepl("free throw", shots$type)
  if (anyNA(keep)) stop("Missing values in the scoring filter")
  x <- shots[keep, , drop = FALSE]
  baskets <- data.frame(
    match_id = x$match_id, period = x$period,
    tiempo = ifelse(x$period < 6,
      round(x$elapsed / 60 + (x$period - 1) * 12, 3),
      round(x$elapsed / 60 + (x$period - 5) * 5 + 48, 3)),
    tipo = ifelse(grepl("3pt", x$type), "3", "2"),
    player = x$player, stringsAsFactors = FALSE
  )
  if (!nrow(baskets) || anyNA(baskets)) stop("Scoring data are empty or incomplete")
  structure(list(baskets = baskets,
    games = unique(shots[c("match_id", "game_id", "date", "data_set")]),
    input_rows = nrow(shots)), class = "scoring_data")
}

as.data.frame.scoring_data <- function(x, ...) x$baskets

print.scoring_data <- function(x, ...) {
  cat("Chicago Bulls scoring data\n", nrow(x$baskets), "baskets in",
      length(unique(x$baskets$match_id)), "games\n")
  invisible(x)
}

series <- function(x, ...) UseMethod("series")

series.scoring_data <- function(x, subject = "Chicago Bulls", games = NULL,
                                label = NULL, ...) {
  if (!is.character(subject) || length(subject) != 1L || is.na(subject)) {
    stop("subject must be a team or player name")
  }
  baskets <- x$baskets
  if (subject != "Chicago Bulls") {
    baskets <- baskets[baskets$player == subject, , drop = FALSE]
    counts <- table(baskets$match_id)
    baskets <- baskets[baskets$match_id %in% names(counts[counts >= 2]), , drop = FALSE]
  }
  available <- sort(unique(baskets$match_id))
  if (is.null(games)) games <- available
  if (!is.numeric(games) || !length(games) || anyNA(games) ||
      anyDuplicated(games) || !all(games %in% available)) {
    stop("games must identify available games without duplicates")
  }
  baskets <- baskets[baskets$match_id %in% games, , drop = FALSE]
  games <- sort(games)
  last <- vapply(games, function(id) max(baskets$period[baskets$match_id == id]), numeric(1))
  # The original observation windows include a known limitation for players.
  horizons <- data.frame(match_id = games,
    t_max = ifelse(last <= 4, last * 12, 48 + (last - 4) * 5))
  for (i in seq_along(games)) {
    times <- baskets$tiempo[baskets$match_id == games[i]]
    if (!is.numeric(times) || any(!is.finite(times)) || any(diff(times) <= 0) ||
        any(times < 0 | times > horizons$t_max[i])) stop("Invalid event times")
  }
  if (is.null(label)) label <- if (length(games) == 1L) paste0("game_", games) else "season"
  if (!is.character(label) || length(label) != 1L || is.na(label)) stop("Invalid series label")
  structure(list(baskets = baskets, horizons = horizons, subject = subject,
    label = label), class = "scoring_series")
}

nobs.scoring_series <- function(object, ...) nrow(object$baskets)

print.scoring_series <- function(x, ...) {
  cat(x$subject, "-", x$label, "\n", nobs(x), "baskets in",
      nrow(x$horizons), "games\n")
  invisible(x)
}

selected_cases <- function() {
  data.frame(case = c("team_7", "team_70", "derozan_35", "lavine_53"),
    subject = c("Chicago Bulls", "Chicago Bulls", "DeMar DeRozan", "Zach LaVine"),
    match_id = c(7, 70, 35, 53), seed = c(20261001L, 20261002L, 20261003L, 20261004L))
}

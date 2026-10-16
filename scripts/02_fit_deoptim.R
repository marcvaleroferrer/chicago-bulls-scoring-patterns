source("R/load.R")
require_packages("DEoptim")
data <- scoring_data()
model <- scoring_model("midpoint")
output <- "results/reproduced"
dir.create(output, recursive = TRUE, showWarnings = FALSE)
cases <- selected_cases()
fits <- setNames(vector("list", nrow(cases)), cases$case)
for (i in seq_len(nrow(cases))) {
  case <- cases[i, ]
  events <- series(data, subject = case$subject, games = case$match_id, label = case$case)
  message("Fitting ", case$case)
  fits[[i]] <- fit(model, events, seed = case$seed)
  save_plot(fits[[i]], file.path(output, paste0(case$case, "_deoptim.png")))
}
write.csv(do.call(rbind, lapply(fits, as.data.frame)),
          file.path(output, "selected_deoptim.csv"), row.names = FALSE)
saveRDS(fits, file.path(output, "deoptim_fits.rds"))

message("Fitting the 84-game team model")
season <- fit(scoring_model("trapezoid"), series(data, label = "team_season"), seed = 20261005L)
write.csv(as.data.frame(season), file.path(output, "team_season.csv"), row.names = FALSE)
saveRDS(season, file.path(output, "team_season_fit.rds"))
write_session(file.path(output, "session_deoptim.txt"))

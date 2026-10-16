# Reorganized workflow outputs

Files here are produced by the reorganized scripts, not transcribed from the
thesis. `selected_deoptim.csv` contains the four selected single-game fits;
`team_season.csv` contains the 84-game joint fit. `comparison.csv` adds stelfi
estimates scored with the same historical midpoint objective. That score is not
stelfi's internal optimizer objective. PNGs show the parameters from these rows.

The stelfi fit retains its original default controls and starting values;
the `iterations` field is therefore NA for stelfi. No claim of equal optimizer
iteration budgets is made. `seed` records new DEoptim seeds, not historical ones.
Session files record the environment used for each verified execution.

`deoptim_fits.rds`, `stelfi_fits.rds` and `team_season_fit.rds` contain S3
`scoring_fit` objects. Source `R/load.R` before using their `coef()`, `predict()`
or `plot()` methods. `optimizer_objective` records each routine's own target;
`negative_log_likelihood` is the separately evaluated repository score. These
are not interchangeable for stelfi. Its default parameter constraints also
differ from the DEoptim box bounds, as explained in `docs/statistical-review.md`.

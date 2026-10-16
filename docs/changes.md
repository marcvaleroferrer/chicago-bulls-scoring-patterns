# Reorganization and known discrepancies

The repository contains an agreed selection from the original thesis workspace,
reviewed in October 2026. The original files were kept unchanged. Source mappings
and hashes are in [provenance.md](provenance.md).

## Code and presentation

Local paths were replaced with repository-relative paths, and data, code and
results were separated. Repeated implementations were consolidated into native
S3 classes for input data, event series, models and fitted results. Data loading
uses an isolated environment; it does not restore the saved workspace. Equivalent
base-R transformations preserve the original filters, order, rounding and time
conversion. The derived basket table was checked against `CHI.RData`.

Fitted objects expose `coef()`, `predict()`, `plot()` and `as.data.frame()`.
They retain the analysed event sequences and diagnostics in RDS files, without
saving an interactive R session. Prediction and plotting do not rerun optimization.
The refactor preserved the fitted coefficients and scores; its execution checks
are recorded in [verification.md](verification.md).

Two errors were addressed during preparation:

- In `Definitivo.Rmd`, a Coby White duration vector overwrote the team's `t_max`
  before the team fit. The prepared fit keeps the team's original horizon
  calculation in a separate object. This defect was disclosed in the initial
  audit; the rule for inferring horizons was retained.
- Some player plots labelled `contador` as the game number. Prepared outputs
  identify games by their original `match_id`.

DEoptim seeds 20261001–20261005 and session records were added. These support
repeatable new runs; the original random states are unknown. Plotting reuses
fitted parameters, retains the original time grid and labels the objective as
negative log-likelihood. A common vertical range starting at zero is used when
comparing methods for a game: automatic scaling can make negligible fluctuations
look substantial when theta is almost zero. This changes presentation only.

Repeated likelihood evaluations cache time differences and quadrature weights.
Checks compare this implementation with the scalar functions, including boundary
parameters and all 84 games. Both evaluate the original grids; floating-point
evaluation order can differ at machine precision.

## Statistical choices retained

- Single-game comparisons use the midpoint sum from `Comparacion.Rmd` and
  `Comparacion_jugadores.Rmd`. The team-season fit uses the trapezoid from
  `Definitivo.Rmd` and Appendix 7.1. The trapezoid covers `[0.5, T - 0.5]`, with
  `n = length(seq(0.5, T - 0.5, 1))`; its step is slightly different from one
  minute. The theoretical integral is on `[0, T]`, but the original numerical
  endpoints and subdivisions have not been replaced.
- Player horizons end at the last period containing that player's basket.
  They are shorter than the team horizon in 11 DeRozan and 19 LaVine games
  (also 24 Coby and 35 Vucevic games). Using full-game horizons would change
  estimates and requires a separate scientific correction.
- Single-game player comparisons drop one-basket games. The thesis's season
  counts, Coby 70 and LaVine 79, include such games, although its prose says
  at least two baskets (which would give 64 and 78). The selected player
  examples both contain multiple baskets.
- DEoptim retains bounds `(0, 0, 0)` to `(2, 2, 100)`, including zero values,
  without imposing `theta < phi`. In contrast, stelfi 1.0.1 constrains
  `alpha / beta < 1`, where alpha and beta correspond to theta and phi.
  The methods therefore have different admissible parameter spaces.
  Phi is poorly identified when theta is approximately zero.
- The original stelfi starting values and default controls are retained.
  The source does not explicitly give it 1,000 iterations, despite wording in
  the thesis. Its estimates are evaluated with the common midpoint score for
  comparison; that score is not stelfi's internal fitting objective. Different
  constraints, exposure conventions and controls prevent interpreting this
  exercise as a controlled comparison of optimizer performance.

## Source disagreements and excluded analyses

The reference CSV keeps thesis and archived HTML values in separate rows:

- Table 5.2, team 7 DEoptim objective: 45.5866 in the thesis, 46.1727 in HTML.
- Table 5.2, team 70 DEoptim objective: 46.9568 in the thesis, 47.8903 in HTML.
- Table 7.1, DeRozan 35 stelfi score: 24.8547 in the thesis, 23.3211 in HTML.

The final highlighted-game joint selections for Table 5.3 and Figures 5.8–5.10
could not be recovered. The available CSR-selected subsets differ from those
selections. Tests labelled as autoexcitation use a bilateral chi-square
calculation and 12 bins that do not fully account for overtime; rejecting
uniformity alone does not identify self-excitation. These tests and joint
subsets are outside the executable selection.

The individual confidence-interval HTML contains covariance/NaN warnings and
differs from Table 5.5. Joint simulation intervals resemble Table 5.6, but their
generating parameters differ from the stated highlighted-game scenario. The
recovery experiment for 1/20/80/100 simulated games is also not fully traced.
None is presented as a reproduced confidence-interval analysis.

The source root's `test_auto_bulls.png` is a LaVine plot, and its edited
`intensidad_partido59.png` illustrates game 70 under stale labels. The repository
instead retains the unchanged definitive illustration for game 59.

Home/away effects, playing time, marked models and Bayesian extensions remain
future work, as in the thesis.

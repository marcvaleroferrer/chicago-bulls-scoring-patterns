# Verification on 16 October 2026

The selected workflow was run with `Rscript --vanilla` from the repository root.
Data were loaded into an isolated environment, without restoring the original
saved session. The results and checks below document those runs; later code
changes require their own checks. The S3 refactor was subsequently executed and
checked as described below. The wider thesis has not been fully reproduced.

## Completed checks

- Data preparation: 9,109 input rows yield 3,566 made field goals in 84 games
  (2,697 two-point and 869 three-point baskets). The derived
  `(match_id, tiempo, tipo)` table matches `CHI.RData`, ignoring row names.
  Source order and three-decimal time conversion are unchanged.
- Core checks: retained fields have no missing values, within-game event times
  increase, intensity uses strictly prior events, boundary cases are finite and
  game histories remain independent. Constant-background cases confirm the
  different exposure lengths of the two quadrature rules.
- Likelihood checks: scalar functions match definitions extracted from
  `Comparacion.Rmd` and `Definitivo.Rmd`, without running their other chunks.
  Five parameter vectors, including zeros and upper bounds, were checked for
  both rules on games 7, 70, 35 and 53 and on the 84-game joint objective, using
  `all.equal(..., tolerance = 1e-12)`. Cached and scalar implementations also
  agree within tolerance for both rules and all 84 games. The core checks are
  retained in `scripts/check_core.R`.
- Fitting: all four selected DEoptim fits and the 84-game team fit completed
  with 1,000 iterations. All four stelfi comparisons completed in another fresh
  process.
- Reporting: the R Markdown report rendered to HTML. Outputs use original game
  IDs, and historical references are kept separate from the new estimates.

## S3 implementation

The object-oriented workflow was run again in fresh R processes after the code
was reorganized into `scoring_data`, `scoring_series`, `scoring_model` and
`scoring_fit`. All five DEoptim runs and four stelfi comparisons completed.
The coefficients and scored objectives agree with the preceding implementation
at tolerance `1e-12`. Seeds, bounds, iterations and integration rules are unchanged.

`check_core.R` checks constructors, invalid input, strict event history,
constant-background cases, cache/scalar equivalence and separate game histories.
`check_results.R` loads the saved RDS objects without fitting. It verifies S3
methods, coefficients, diagnostics, scalar scores, prediction windows and plot
scales. The HTML report was rendered again with eight plots and no repeated
selected-game table. Both methods now share a vertical range from zero in each
game comparison.

The fit objects and CSV tables retain DEoptim's actual iteration and evaluation
counts, each routine's internal objective and the separately evaluated score.
Stelfi's unavailable optimizer diagnostics are left as NA. A text-trimming bug
in session-record output was also corrected; it did not affect the calculations.

## Numerical comparison

The table reports the historical numerical negative-log-likelihood objectives:
the midpoint sum for single games and the trapezoid for the joint fit.

| Case | Reorganized DEoptim | Archived HTML | Thesis |
|---|---:|---:|---:|
| Team 7 | 46.326220 | 46.1727 | 45.5866 |
| Team 70 | 47.890334 | 47.8903 | 46.9568 |
| DeRozan 35 | 23.084142 | 23.7254 | 23.7254 |
| LaVine 53 | 16.356061 | 16.3561 | 16.3561 |
| Team, 84 games | 3969.308569 | Not used as reference | 3969.309 |

The team-season fit gives mu = 0.8930628584, theta approximately 3.04e-18,
and phi = 57.09346. Mu and the objective agree with Table 5.4 to its displayed
precision. Phi differs from its 66.06074; at effectively zero excitation the
data do not identify a decay rate through that component.

The team-7 objective is higher than the archived HTML result; DeRozan-35's is
lower. A 1,000-iteration stochastic search need not reach the same optimum in
each run. Historical random states are unknown, and the surviving files do not
fully explain the differences between thesis, HTML and new executions.

Stelfi point estimates and common-midpoint scores agree with the archived HTML
to displayed precision. DeRozan 35 has score 23.321092, matching the HTML but
differing from the thesis's 24.8547. This discrepancy remains unresolved.

These scores do not establish which optimizer is better. Stelfi 1.0.1 imposes
`alpha / beta < 1`; the original DEoptim fit has no corresponding `theta < phi`
constraint. Controls and fitting objectives also differ. The stelfi values above
are scores evaluated with the repository's midpoint function, not its internal
optimizer objective. See [changes.md](changes.md).

## Warnings and limits

Stelfi produced `sqrt(diag(cov)): NaNs produced` for team game 70, recorded in
`results/reproduced/stelfi_warnings.csv`. The point estimates are finite;
covariance-based uncertainty has not been validated. No confidence interval or
significance claim is derived from that fit.

Automatic plot scaling can exaggerate the tiny fluctuations in the team-70
stelfi intensity. A vertical axis starting at zero and a common range for each
game's two fits make their magnitudes comparable without changing estimates.

The runs used R 4.4.2, DEoptim 2.2-8, stelfi 1.0.1 and rmarkdown 2.31. R startup
reported unavailable `C.UTF-8` locale settings and continued in locale C.
Package and platform details are in `results/reproduced/session_*.txt`.

The final highlighted-game joint selections, original confidence intervals,
simulation recovery table and remaining thesis figures have not been reproduced.
Historical player horizons and other statistical limitations listed in
`docs/changes.md` remain present. No synthetic data were used.

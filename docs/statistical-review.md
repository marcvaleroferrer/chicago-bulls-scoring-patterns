# Statistical review

The selected code, saved estimates, figures and documentation were reviewed
against the original R Markdown documents and final thesis. The changes below
concern implementation and interpretation; the statistical model and its
original numerical conventions have been retained.

## Estimation procedures

The DEoptim fit and the default stelfi fit do not search the same parameter
space. The original DEoptim code constrains each parameter independently.
In stelfi 1.0.1, `fit_hawkes(model = 1)` uses a logit transformation of
`alpha / beta` when marks equal one. Its admissible estimates satisfy
theta < phi. The reproduced DeRozan-35 DEoptim estimate has theta = 0.0373225
and phi = 0.00918872, outside that space.

A lower numerical score therefore does not establish that DEoptim is a better
optimizer or that its model is a better description of the hot hand. The CSV
separates `optimizer_objective`, returned by each fitting routine, from
`negative_log_likelihood`, the repository's common numerical scoring function.
The latter uses the same quadrature for both estimates. Stelfi's interface does
not take an explicit game endpoint; equivalence of its internal exposure with
the repository's observation window has not been established.

Stelfi 1.0.1 returns neither the optimizer's convergence code nor its iteration
count. Those diagnostics are not invented. DEoptim iterations and function
evaluations are recorded from its returned object. Completion of a fitting
routine is not evidence that the global optimum has been found. The covariance
warning for team game 70 remains recorded; it does not support a reliable
covariance-based confidence interval.

## Observation windows and numerical integration

Player windows inferred from the last period containing a basket can end before
the game does. The original integration also differs between comparison and
joint scripts. These choices affect the likelihood and cannot be corrected as
formatting changes. Their preservation and the mismatches with the thesis are
listed in [changes.md](changes.md).

For the exponential intensity in the thesis, the integral on [0,T] does have
an analytical expression when phi > 0:

$$\int_0^T\lambda(t)\,dt
=\mu T+\frac{\theta}{\phi}\sum_{t_i<T}\left(1-e^{-\phi(T-t_i)}\right).$$

When phi = 0, the contribution of each previous event is theta times its
remaining observation time. Thus the thesis's statement that the integral has
no exact solution is incorrect for this kernel. The implementation still uses
the original quadrature: replacing it would be a separate scientific revision,
with new estimates and a new comparison against the thesis.

## Interpretation in basketball

Clustering of made baskets does not isolate a change in shooting success
probability. The model does not condition on missed shots, shot opportunities,
possession, defensive context, player substitutions or court time. A temporally
clustered scoring sequence can reflect several of these factors. The study
supports an exploratory description of scoring patterns, not a causal proof
of the hot-hand effect.

Selected games are illustrative rather than an independent validation sample.
Near-zero theta also makes phi weakly identifiable: variation in the estimated
decay rate is not evidence of a different season-wide excitation pattern.

## Software review

The S3 classes separate input data, game histories, the numerical model and fitted
results. Prediction and plotting use saved coefficients and never optimize.
Constructors reject missing games, empty selections and invalid event sequences.
The cache is checked against a scalar objective, including parameter boundaries
and independent game histories. Original and reorganized code agree within the
reported numerical tolerances.

Plots include zero on the vertical axis and share a range within each method
comparison. This prevents an almost constant stelfi curve from appearing to
have large fluctuations under automatic scaling. The change affects the figure,
not the fitted coefficients or their interpretation.

Implementation details of the installed stelfi wrapper were inspected directly.
The upstream [fit_hawkes source](https://github.com/cmjt/stelfi/blob/master/R/fit_hawkes.r)
provides a related code reference; the verified local version is recorded in
the session files.

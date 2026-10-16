# Data

The supplied file `raw/shots_CHI.RData` is copied unchanged from the thesis
workspace. It contains `data_shots_CHI`, a data.frame with 9,109 rows and 14 fields:
`game_id`, `data_set`, `date`, `shot_distance`, `team`, `period`, `elapsed`,
`player`, `type`, `result`, `assist`, `description`, `numeric_res`, `match_id`.
The archive supplies no upstream download script, provider identifier or
third-party redistribution terms. The author has confirmed permission to
include the input; this does not assert a particular upstream open-data licence.

All 84 games are labelled `2022-23 Regular Season` in the input, including the
last two encounters dated 12 and 14 April 2023. This repository retains the
original 84-game scope and does not relabel competition stages without evidence.

`01_prepare_data.R` selects `numeric_res == 1`, excludes any `type` containing
`free throw`, preserves row order and converts times with the original formula:

```r
ifelse(period < 6,
       round(elapsed / 60 + (period - 1) * 12, 3),
       round(elapsed / 60 + (period - 5) * 5 + 48, 3))
```

The processed `tiempo` is in minutes; `tipo` is "2" or "3". Basket type is not
a model mark or weight. Original match IDs are retained and a `game_index.csv`
maps them to game identifiers and dates. Derived CSVs can be regenerated.

Single-game player comparisons retain the at-least-two-baskets filter. Horizons
are historically inferred from the last period containing a basket for the
analysed subject. This may truncate a player's actual observation window; it
has not been silently corrected. No failed shots, free throws, court-time
records or synthetic observations are added to the fitted event sequences.

# Source provenance

The final thesis is the primary source. Chapter 5 defines the application;
Appendix 7.1 contains the final numerical likelihood implementation; Tables 5.2,
5.4, 7.1 and 7.2 supply the selected reference values. The source workspace was
inspected in October 2026. No source was selected solely by name or timestamp.

| Original source | Role in this repository |
|---|---|
| `TFG_memoria.pdf` | Unchanged copy in `docs/`; methodology and reference tables |
| `shots_CHI.RData` | Unchanged copy in `data/raw/` |
| `CHI.RData` | External audit check of the derived baskets; not included as a duplicate |
| `Definitivo.Rmd` | Intensity, trapezoid, joint likelihood, bounds and iteration count |
| `Comparacion.Rmd` | Team comparison likelihood and stelfi initialization |
| `Comparacion_jugadores.Rmd` | Player filtering, historical horizons and comparison |
| `Graficas_jugador.Rmd` | Original plot grid and basket/intensity representation |
| `Graficas_definitivas/Comparacion*.html` | Archived displayed reference estimates; selected rows transcribed |
| `Graficas_definitivas/GRAFICAS/ejemplo_intensidad_condicional.png` | Unchanged copy as `results/reference/example_intensity_game59.png` |

The original code and HTML remain in the author's source archive outside this
cleaned repository. Their hashes below identify the audited versions; the source
names are provenance identifiers rather than links to missing repository files.
The unchanged data, thesis and figure copies can be checked directly.

## SHA-256 of audited sources

```text
83143051474acfee6e7b01e748e645e7d87dbdad2a49bbcf09196d0d6bdeef97  TFG_memoria.pdf
9ed21881649e7031f45fdb71625381aad6a15e79dee239e2f07c7b8ce691be6b  shots_CHI.RData
82d6132a3bbb59c7c683afca6edd6f00363d639a25c9fbb9a09b9be1dea8fe2a  CHI.RData
2ffb4bd8baa40c81304396bb3667c524ce1a88f5f9584bff26ff307f90babe7a  Definitivo.Rmd
c37c4e64803b52f1154210da4cef1cb5c3bb2fbbfc55adc92dcd9ab1b72ec9d8  Comparacion.Rmd
3b56e890cd51b59defa94877940bb11c4af538278dee7730ff396b0c8a937ae1  Comparacion_jugadores.Rmd
8183ac323284b3b40fd5e8e63b87a0812f4903a93e078ba682169b9b81862ff3  Graficas_jugador.Rmd
a09ae270009979a52098d70a0d82f478a0e0ec4c2934c2b828cdf85b05d8a46c  Graficas_definitivas/Comparacion.html
6764238800ccab78ac279541784bbf3f559c7b3fa907a75ad9d98e1a3361cf8b  Graficas_definitivas/Comparacion_DeMar_DeRozan.html
5ed7cb780803e6da085914726fe4c50b2d37f79b337bb476d7b2c2dbe293c7b5  Graficas_definitivas/Comparacion_Zach_LaVine.html
62d140ce9ee49df809414c80e95bf69ace4ef0011207ac67c5fe38e0711e2236  Graficas_definitivas/GRAFICAS/ejemplo_intensidad_condicional.png
```

The input's upstream provider and acquisition procedure are not recorded in
these sources. The author confirmed permission to include the supplied data.
No third-party copyright or redistribution licence is inferred from that statement.
Third-party PDFs from the original TEORIA folder were not copied.

## Academic references

- Valero Ferrer, M. (2024–2025). *Modelos estadísticos de tipo self-exciting*.
  Mathematics bachelor's thesis; the original PDF is included above.
- Mullen, K. M., Ardia, D., Gil, D. L., Windover, D., and Cline, J. (2011).
  *DEoptim: An R Package for Global Optimization by Differential Evolution*.
  Journal of Statistical Software, 40.
- Jones-Todd, C. M., and van Helsdingen, A. B. (2024). *stelfi: An R package for
  fitting Hawkes and log-Gaussian Cox point process models*. Ecology and Evolution,
  14(2), e11005.

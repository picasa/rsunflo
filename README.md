# rsunflo
Tools for phenotyping, simulating and modelling with the SUNFLO crop model [1,2]. 
Convenience and utility functions for personal use. Not to be published anywhere.

A set of tools for working with the SUNFLO crop model at different steps. 
* input data: computing genotype-specific parameters and creating climatic input files.
* simulation: designing virtual experiments and multi-simulation in R or web service interface.
* modeling: tracking the variation of prediction capacity along with model development.

Documentation: 

* model manual: graphic documentation of the sunflo algorithm [(pdf)](inst/doc/documentation_model.pdf)
* user manual: description of the workflow for simulation and model parameterization [(pdf, in French)](inst/doc/documentation_user.pdf)
* example: simulate a basic design of experiments [(rmarkdown)](inst/doc/documentation_example.rmd)

### Installation
To run simulations with the SUNFLO crop model and this R package, two softwares (VLE and R) and two packages (sunflo and rsunflo) need to be installed.

1. install the `VLE` simulation platform : `VLE project` [github](https://github.com/vle-forge/vle) or [website](http://www.vle-project.org/download/) and `RVLE` R package [github](https://github.com/vle-forge/rvle)

2. install the `SUNFLO` crop model for VLE simulation platform : [RECORD project model library](http://www6.inra.fr/record/Bibliotheque-de-modeles/Modeles-du-domaine-des-agro-ecosystemes)

3. install the development version of `rsunflo` or clone the rsunflo repository

``` r
# install.packages("devtools")
devtools::install_github("picasa/rsunflo")
```


### References
[1] Casadebaig, P.; Guilioni, L.; Lecoeur, J.; Christophe, A.; Champolivier, L. & Debaeke, P. (2011), 'SUNFLO, a model to simulate genotype-specific performance of the sunflower crop in contrasting environments', Agricultural and Forest Meteorology 151, 163-178. [(pdf)](https://drive.google.com/file/d/1_LR4LWu7TvmNTLDSPyDRRQlldTYEG5Hd/view?usp=sharing)

[2] Lecoeur, J.; Poiré-Lassus, R.; Christophe, A.; Pallas, B.; Casadebaig, P.; Debaeke, P.; Vear, F. & Guilioni, L. (2011), 'Quantifying physiological determinants of genetic variation for yield potential in sunflower. SUNFLO: a model-based analysis', Functional Plant Biology 38(3), 246--259. [(pdf)](https://drive.google.com/file/d/0BwYvFKb9sBxfUHJWTXU5T09lRTQ/view?usp=sharing&resourcekey=0-ys_RFyS3-9NEuYRT17IkhQ)




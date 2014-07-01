# rsunflo
Tools for phenotyping, simulating and modelling with the SUNFLO crop model [1,2]. 
Convenience and utility functions for personal use. Not to be published anywhere.

A set of tools for working with the SUNFLO crop model at different steps. 
* input data : computing genotype-specific parameters and creating climatic input files.
* simulation : designing virtual experiments and multi-simulation in R or web service interface.
* modelling : tracking the variation of prediction capacity along with model development.

### Installation
To install the development version of `rsunflo` please use the `devtools` package:

    # install.packages("devtools")
    library(devtools)
    install_github("rsunflo", "picasa")

Please see :
* [user manual](inst/doc/workflow.md) for a description of the workflow for simulation and model parameterization
* [model manual](inst/doc/model.md) for a more detailed documentation of the sunflo algorithm (to be completed)

### References
[1] Casadebaig, P.; Guilioni, L.; Lecoeur, J.; Christophe, A.; Champolivier, L. & Debaeke, P. (2011), 'SUNFLO, a model to simulate genotype-specific performance of the sunflower crop in contrasting environments', Agricultural and Forest Meteorology 151, 163-178. [pdf](https://www.researchgate.net/publication/230758361_SUNFLO_a_model_to_simulate_genotype-specific_performance_of_the_sunflower_crop_in_contrasting_environments)

[2] Lecoeur, J.; Poiré-Lassus, R.; Christophe, A.; Pallas, B.; Casadebaig, P.; Debaeke, P.; Vear, F. & Guilioni, L. (2011), 'Quantifying physiological determinants of genetic variation for yield potential in sunflower. SUNFLO: a model-based analysis', Functional Plant Biology 38(3), 246--259. [pdf](https://www.researchgate.net/publication/216526215_Quantifying_physiological_determinants_of_genetic_variation_for_yield_potential_in_sunflower._SUNFLO_A_model-based_analysis)




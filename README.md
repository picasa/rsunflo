# rsunflo
Tools for phenotyping, simulating and modelling with the SUNFLO crop model. 
Convenience and utility functions for personal use. Not to be published anywhere.

A set of tools for working with the SUNFLO crop model at different steps. 
* input data : computing genotype-specific parameters and creating climatic input files.
* simulation : designing virtual experiments and multi-simulation in R or web service interface.
* modelling : tracking the variation of prediction capacity along with model development.

To install the development version of `rsunflo` please use the `devtools` package:

    # install.packages("devtools")
    library(devtools)
    install_github("rsunflo", "picasa")

Please see :
* [user manual](inst/doc/workflow.md) for a description of the workflow for simulation and model parameterization
* [model manual](inst/doc/model.md) for a more detailed documentation of the sunflo algorithm (not completed)

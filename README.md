
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DHSHarmonization

<!-- badges: start -->

<!-- badges: end -->

The goal of DHSHarmonization is to provide the Golden Lab with a
pipeline to harmonize and extract data from Demographic and Health
Surveys (DHS) for analysis. The pipeline is built on targets to ensure
reproducibility and is designed to be flexible to accommodate different
research questions and datasets.

If you require a pipeline endpoint dataset that is not currently
implemented, please open an issue or reach out to Tinashe.

## Installation

If you would like to install the development version of
DHSHarmonization, and build the package pipeline yourself, you can do so
with the following code:

``` r
# install.packages("devtools")
devtools::install_github("Climate-Smart-Public-Health/DHSHarmonization")
```

> Note: This can only be accomplished if you have access to the DHS data
> through FASRC and the Golden Lab space on FASRC.

## Example

Once you’ve installed the package, you can run the pipeline with
targets::tar\_make()

``` r
tar_make()
```

This will execute the entire pipeline as defined in the `_targets.R`
file, downloading and harmonizing the DHS data according to the
specifications in the package.

See the Articles section for vignettes that provide detailed
walkthroughs of pipeline development and target components.

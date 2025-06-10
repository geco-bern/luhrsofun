[![R build status](https://github.com/geco-bern/luhrsofun/workflows/R-CMD-check/badge.svg)](https://github.com/geco-bern/luhrsofun/actions)
[![codecov](https://codecov.io/gh/geco-bern/luhrsofun/branch/master/graph/badge.svg)](https://app.codecov.io/gh/geco-bern/luhrsofun)

# luhrsofun

A helper package preprocessing for the rsofun package. 
rsofun is a R Simulating Optimal FUNctioning (RSOFUN) framework for site-scale simulations of ecosystem processes. 
rsofun can be found here: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3712928.svg)](https://doi.org/10.5281/zenodo.3712928)

## Installation

### Stable release

To be released... currently follow instructions for development release below.

### Development release

To install the latest development release of the package run the following commands to install luhrsofun directly from GitHub:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("geco-bern/luhrsofun")
library("luhrsofun")
```

## Use

Below sections show the ease of use of the package in terms of model parameter specification and running both a single run or optimizing the parameters for a given site (or multiple sites). For an in depth discussion we refer to the [vignettes](https://geco-bern.github.io/luhrsofun/articles/).

### Running model

Please see `vignettes/run_biomee_with_LUH2.Rmd` for an example how to use this package in combination with the `rsofun` package.

## Acknowledgements

The {luhrsofun} is part of the LEMONTREE project and funded by Schmidt Futures and under the umbrella of the Virtual Earth System Research Institute (VESRI). 


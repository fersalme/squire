
<!-- README.md is generated from README.Rmd. Please edit that file -->

# squire

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/mrc-ide/squire.svg?branch=master)](https://travis-ci.org/mrc-ide/squire)
[![Codecov test
coverage](https://codecov.io/gh/mrc-ide/squire/branch/master/graph/badge.svg)](https://codecov.io/gh/mrc-ide/squire?branch=master)
<!-- badges: end -->

squire enables users to simulate models of SARS-CoV-2 epidemics. This is
done using an age-structured SEIR model that also explicitly considers
healthcare capacity and disease severity.

## Overview

squire is a package enabling users to quickly and easily generate
calibrated estimates of SARS-CoV-2 epidemic trajectories under different
control scenarios. It consists of the following:

  - An age-structured SEIR model incorporating explicit passage through
    healthcare settings and explicit progression through disease
    severity stages.
  - The ability to calibrate the model to different epidemic start-dates
    based on available death data.
  - Simulate the impacts of different control interventions (including
    general social distancing, specific shielding of elderly
    populations, and more stringent suppression strategies).

If you are new to squire, the best place to start is below, where we
detail how to install the package, how to set up the model, and how to
run it with and without control
interventions.

## Model Structure

### Overall Structure

<img src="https://raw.githubusercontent.com/mrc-ide/squire/healthcare_capacity/images/Explicit_Healthcare_Model_Structure.JPG" align="center" style = "border: none; float: center;" width = "600px">

squire uses an age-structured SEIR model, with the infectious class
divided into different stages reflecting progression through different
disese severity pathways. These compartments are:  
\* S = Susceptibles  
\* E = Exposed (Latent Infection)  
\* I<sub>Mild</sub> = Mild Infections (Not Requiring Hospitalisation)  
\* I<sub>Case</sub> = Infections Requiring Hospitalisation  
\* I<sub>Hospital</sub> = Hospitalised (Requires Hospital Bed)  
\* I<sub>ICU</sub> = ICU (Requires ICU Bed)  
\* I<sub>Rec</sub> = Recovering from ICU Stay (Requires Hospital Bed)  
\* R = Recovered  
\* D =
Dead

### Decision Trees for Healthcare Capacity

<img src="https://raw.githubusercontent.com/mrc-ide/squire/healthcare_capacity/images/Explicit_Healthcare_Oxygen_Decision_Tree.JPG" align="center" style = "border: none; float: center;" width = "400px">

Given initial inputs of hospital/ICU bed capacity and the average time
cases spend in hospital, the model dynamically tracks available hospital
and ICU beds over time.

Individuals newly requiring hospitalisation (either a hospital or ICU
bed) are then assigned to either receive care (if the relevant bed is
available) or not (if maximum capacity would be exceeded otherwise).
Whether or not an individual receives the required care modifies their
probability of dying.

## Installation

<i>squire</i> utilises the package
[ODIN](https://github.com/mrc-ide/odin) to generate the model.
[ODIN](https://github.com/mrc-ide/odin) implements a high-level language
for implementing mathematical models and can be installed by running the
following command:

``` r
install.packages("odin")
```

The model generated using ODIN is written in C and so you will require a
compiler to install dependencies for the package and to build any models
with ODIN. Windows users should install
[Rtools](https://cran.r-project.org/bin/windows/Rtools/). See the
relevant section in
[R-admin](https://cran.r-project.org/doc/manuals/r-release/R-admin.html#The-Windows-toolset)
for advice. Be sure to select the “edit PATH” checkbox during
installation or the tools will not be found.

The function `odin::can_compile()` will check if it is able to compile
things, but by the time you install the package that will probably have
been satisfied.

After installation of ODIN, ensure you have the devtools package
installed by running the following:

``` r
install.packages("devtools")
```

Then install the <i>squire</i> package directly from GitHub by running:

``` r
devtools::install_github("mrc-ide/squire")
```

If you have any problems installing then please raise an issue on the
<i>squire</i> [`GitHub`](https://github.com/mrc-ide/squire/issues).

If everything has installed correctly, we then need to load the package:

``` r
library(squire)
```

## Getting Started

### Running the Model (Unmitigated)

1.  Running the model using baseline parameters and no control
    interventions

The full model is referred to as the **explicit\_SEEIR** model, with
hospital pathways explicltly exploring whether individuals will require
a general hospital bed providing oxygen or an ICU bed that provides
ventilation.

To run the model we need to provide at least one of the following
arguments:

  - `country`
  - `population` and `baseline_contact_matrix`

If the `country` is provided, the `population` and
`baseline_contact_matrix` will be generated (if not also specified)
using the demographics and matrices specified in the [global
report](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/report-12-global-impact-covid-19/).

To run the model by providing the `country` we use
`run_explicit_SEEIR_model()`:

``` r
r <- run_explicit_SEEIR_model(country = "Afghanistan")
```

The returned object is a `squire_simulation` object, which is a list of
two ojects:

  - `output` - model output
  - `parameters` - model parameters

`squire_simulation` objects can be plotted as follows:

``` r
plot(r)
```

<img src="man/figures/README-base plot-1.png" width="100%" /> This plot
will plot each of the compartments of the model output.

2.  Changing parameters in the model.

The model has a number of parameters for setting the R0, demography,
contact matrices, the durations of each compartment and the health care
outcomes and healthcare availability. In addition, the initial state of
the population can be changed as well as simulation parameters, such as
the number of replicates, length of simulation and the timestep. For a
full list of model inputs, please see the function
[documentation](https://mrc-ide.github.io/squire/reference/run_explicit_SEEIR_model.html)

For example, changing the initial R0 (default = 3), number of replicates
( default = 10), simualtion length (default = 365 days) and time step
(default = 0.5 days), as well as setting the population and contact
matrix manually:

``` r

# Get the population
pop <- get_population("United Kingdom")
population <- pop$n

# Get the mixing matrix
contact_matrix <- get_mixing_matrix("United Kingdom")

# run the model
r <- run_explicit_SEEIR_model(population = population, 
                              baseline_contact_matrix = contact_matrix,
                              R0 = 2.5, 
                              time_period = 200,
                              dt = 1,
                              replicates = 5)
plot(r)
```

<img src="man/figures/README-set params-1.png" width="100%" />

We can also change the R0 and contact matrix at set time points, to
reflect changing behaviour resulting from interventions. For example to
set a 80% reduction in the contact matrix after 50 days :

``` r

# run the model
r <- run_explicit_SEEIR_model(population = population, 
                              baseline_contact_matrix = contact_matrix,
                              tt_contact_matrix = c(0, 50),
                              contact_matrix_set = list(contact_matrix,
                                                        contact_matrix*0.2),
                              R0 = 2.5, 
                              time_period = 200,
                              dt = 1,
                              replicates = 5)
plot(r)
```

<img src="man/figures/README-set contact matrix decrease-1.png" width="100%" />

To show an 80% reduction after 50 days but only maintained for 30 days :

``` r

# run the model
r <- run_explicit_SEEIR_model(population = population, 
                              baseline_contact_matrix = contact_matrix,
                              tt_contact_matrix = c(0, 50, 80),
                              contact_matrix_set = list(contact_matrix,
                                                        contact_matrix*0.2,
                                                        contact_matrix),
                              R0 = 2.5, 
                              time_period = 200,
                              dt = 1,
                              replicates = 5)
plot(r)
```

<img src="man/figures/README-set contact matrix decrease and relax-1.png" width="100%" />

Alternatively, we could set a changing R0, which falls below 1 after 50
days:

``` r

# run the model
r <- run_explicit_SEEIR_model(population = population, 
                              baseline_contact_matrix = contact_matrix,
                              tt_R0 = c(0, 50),
                              R0 = c(2.5, 0.9),
                              time_period = 200,
                              dt = 1,
                              replicates = 5)
plot(r)
```

<img src="man/figures/README-set R0 decrease-1.png" width="100%" />

3.  Extracting and Plotting Relevant Outputs

Alternative summaries of the models can be created, which give commonly
reported measures, such as deaths, number of ICU beds and general
hospital beds required.

``` r

# Still to do
```

The number of deaths over time will depend heavily on the available
healthcare capacity of a country, with excess mortality occurring when
critical care patients, who require mechanical ventilation, are unable
to access one due to shortages:

``` r

# Still to do
```

4.  Calibrating the Model to Observed Deaths Data

The model can be simply calibrated to time series of deaths reported in
settings. This can be conducted using the `calibrate` function, by
providing a data frame of date and deaths. For example:

``` r

# create dummy data
df <- data.frame("date" = Sys.Date() - 0:6,
                 "deaths" = c(6, 2, 1, 1, 0, 0, 0))
df
#>         date deaths
#> 1 2020-04-09      6
#> 2 2020-04-08      2
#> 3 2020-04-07      1
#> 4 2020-04-06      1
#> 5 2020-04-05      0
#> 6 2020-04-04      0
#> 7 2020-04-03      0
```

``` r

# run caliibrate
out <- calibrate(data = df, country = "Senegal", replicates = 10)

head(out)
#> # A tibble: 6 x 7
#> # Groups:   replicate [1]
#>       t age_group replicate new_time date       name     value
#>   <dbl>     <dbl>     <dbl>    <dbl> <date>     <chr>    <dbl>
#> 1     1         1         1      -36 2020-03-04 S      2615338
#> 2     1         1         1      -36 2020-03-04 E1           0
#> 3     1         1         1      -36 2020-03-04 E2           0
#> 4     1         1         1      -36 2020-03-04 IMild        1
#> 5     1         1         1      -36 2020-03-04 ICase1       1
#> 6     1         1         1      -36 2020-03-04 ICase2       1
```

Simulation replicates are aligned to the current death total and the
outputs of each simulation replicate are returned in long format. To
plot the deaths over time up until the next week:

``` r

# summarise deaths
deaths <- dplyr::group_by(out[out$name == "D", ],date, replicate)
deaths <- dplyr::summarise(deaths, value = sum(value))
deaths <- deaths[deaths$date < Sys.Date() + 7,]

# plot the deaths
ggplot2::ggplot(deaths, ggplot2::aes(x = date, y = value, group = replicate)) + 
  ggplot2::geom_line() + 
  ggplot2::geom_vline(xintercept = Sys.Date()) +
  ggplot2::geom_hline(yintercept = df$deaths[1]) +
  ggplot2::xlab("Date") + 
  ggplot2::ylab("Cumulative Deaths")
```

<img src="man/figures/README-deaths over time-1.png" width="100%" />

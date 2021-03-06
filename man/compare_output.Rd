% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/particle.R
\name{compare_output}
\alias{compare_output}
\title{Compare model to death data}
\usage{
compare_output(model, pars_obs, data, type = "explicit_SEEIR_model")
}
\arguments{
\item{model}{An \code{odin_model} object}

\item{pars_obs}{Parameters for the observations}

\item{data}{The data to be compared against}

\item{type}{The class of the model. At the moment this can only be
\code{explicit_SEIR} but as more models come online we can use
this parameter to control the type of comparison function generated.}
}
\description{
Compare the model to death data for use with the particle filter
}

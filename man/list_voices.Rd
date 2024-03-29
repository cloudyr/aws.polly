% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_voices.R
\name{list_voices}
\alias{list_voices}
\title{List available voices}
\usage{
list_voices(
  language = NULL,
  token = NULL,
  engine = NULL,
  include_additional_languages = FALSE,
  ...
)
}
\arguments{
\item{language}{Optional ISO 3166 country identification tag.  If `NULL`,
voices for all available languages are returned.}

\item{token}{Optional pagination token.}

\item{engine}{Optional engine name: `"standard"` or `"neural"`. If specified,
only voices available for that engine are returned.}

\item{\dots}{Additional arguments passed to \code{\link{pollyHTTP}}.}

\item{include_additional_language}{Optional boolean specifying whether to
return bilingual voices listing the requested language as an additional
language (as opposed to their main default language).}
}
\value{
A data frame of available names.
}
\description{
Retrieve a list of available voices
}
\examples{
\dontrun{
list_voices(language = "cy-GB")
list_voices()
}
}

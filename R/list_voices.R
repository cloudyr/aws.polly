#' @title List available voices
#' @description Retrieve a list of available voices
#' @param language Optional ISO 3166 country identification tag.  If `NULL`,
#'   voices for all available languages are returned.
#' @param token Optional pagination token.
#' @param engine Optional engine name: `"standard"` or `"neural"`. If specified,
#'   only voices available for that engine are returned.
#' @param include_additional_language Optional boolean specifying whether to
#'   return bilingual voices listing the requested language as an additional
#'   language (as opposed to their main default language).
#' @param \dots Additional arguments passed to \code{\link{pollyHTTP}}.
#' @return A data frame of available names.
#' @examples
#' \dontrun{
#' list_voices(language = "cy-GB")
#' list_voices()
#' }
#' @export
list_voices <-
function(language = NULL,
         token = NULL,
         engine = NULL,
         include_additional_languages = FALSE,
         ...)
{
    query <- list(LanguageCode = language,
                  NextToken = token,
                  Engine = engine,
                  IncludeAdditionalLanguageCodes =
                      if (isTRUE(include_additional_languages)) "yes" else "no")

    # Remove empty (NULL) arguments
    query <- Filter(Negate(is.null), query)

    out <- pollyHTTP(action = "voices", verb = "GET", query = query, ...)
    structure(out[["Voices"]], NextToken = out[["NextToken"]])
}

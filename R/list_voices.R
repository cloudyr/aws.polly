#' @title List available voices
#' @description Retrieve a list of available voices
#' @param language An ISO 3166 country identification tag.  If `NULL`, then voices for all available countries are returned.
#' @param token Optionally, a pagination token.
#' @param \dots Additional arguments passed to \code{\link{pollyHTTP}}.
#' @return A data frame of available names.
#' @examples
#' \dontrun{
#' list_voices(language = "cy-GB")
#' list_voices(language = NULL)
#' }
#' @export
list_voices <-
function(language = "en-US",
         token,
         ...)
{
    query <- list()
    query$LanguageCode <- language
    if (!missing(token)) {
        query[["NextToken"]] <- token
    }
    out <- pollyHTTP(action = "voices", verb = "GET", query = query, ...)
    structure(out[["Voices"]], NextToken = out[["NextToken"]])
}

#' @rdname lexicons
#' @title Lexicons
#' @description List, put, and delete lexicons
#' @param lexicon A character string specifying the name of a lexicon. If missing, a list of available lexicons is returned.
#' @param token Optionally, a pagination token.
#' @param content A character string containing the content of the PLS lexicon.
#' @param \dots Additional arguments passed to \code{\link{pollyHTTP}}.
#' @return A list.
#' @details Note: \code{put_lexicon} will overwrite an existing lexicon with the same name.
#' @examples
#' \dontrun{
#' list_lexicons()
#' }
#' @export
get_lexicon <- function(lexicon, token, ...) {
    if (!missing(lexicon)) {
        pollyHTTP(action = paste0("lexicons/", lexicon), verb = "GET", ...)
    } else {
        if (!missing(token)) {
            query <- list(NextToken = token)
            out <- pollyHTTP(action = "lexicons", verb = "GET", query = query, ...)
        } else {
            out <- pollyHTTP(action = "lexicons", verb = "GET", ...)
        }
        structure(out[["Lexicons"]], NextToken = out[["NextToken"]])
    }
}

#' @rdname lexicons
#' @export
put_lexicon <- function(lexicon, content, ...) {
    pollyHTTP(action = paste0("lexicons/", lexicon), verb = "PUT", ...)
}

#' @rdname lexicons
#' @export
delete_lexicon <- function(lexicon, ...) {
    pollyHTTP(action = paste0("lexicons/", lexicon), verb = "DELETE", ...)
}

#' @title Execute AWS Polly API Request
#' @description This is the workhorse function to execute calls to the Polly API.
#' @param action A character string specifying the API action to take
#' @param query An optional named list containing query string parameters and their character values.
#' @param body A request body
#' @param verb A character string specifying the HTTP verb to implement.
#' @param version A character string specifying the API version.
#' @param raw_response A logical indicating whether to return the raw response body.
#' @param region A character string containing an AWS region. If missing, the default \dQuote{us-east-1} is used.
#' @param key A character string containing an AWS Access Key ID. The default is pulled from environment variable \dQuote{AWS_ACCESS_KEY_ID}.
#' @param secret A character string containing an AWS Secret Access Key. The default is pulled from environment variable \dQuote{AWS_SECRET_ACCESS_KEY}.
#' @param session_token Optionally, a character string containing an AWS temporary Session Token. If missing, defaults to value stored in environment variable \dQuote{AWS_SESSION_TOKEN}.
#' @param ... Additional arguments passed to \code{\link[httr]{GET}}.
#' @return If successful, a named list. Otherwise, a data structure of class \dQuote{aws-error} containing any error message(s) from AWS and information about the request attempt.
#' @details This function constructs and signs an Polly API request and returns the results thereof, or relevant debugging information in the case of error.
#' @author Thomas J. Leeper
#' @import httr
#' @import tuneR
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom aws.signature signature_v4_auth
#' @export
pollyHTTP <- 
function(action, 
         query = list(),
         body = NULL,
         verb = c("GET", "POST", "PUT", "DELETE"),
         version = "v1",
         raw_response = if (verb == "POST") TRUE else FALSE,
         region = Sys.getenv("AWS_DEFAULT_REGION"), 
         key = Sys.getenv("AWS_ACCESS_KEY_ID"), 
         secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
         session_token = Sys.getenv("AWS_SESSION_TOKEN"),
         ...) {
    verb <- match.arg(verb)
    action <- paste0("/", version, "/", action)
    d_timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
    if (region == "") {
        region <- "us-east-1"
    }
    url <- paste0("https://polly.",region,".amazonaws.com", action)
    if (key == "") {
        stop("AWS Access Key ID is missing!")
    }
    Sig <- signature_v4_auth(
           datetime = d_timestamp,
           region = region,
           service = "polly",
           verb = verb,
           action = action,
           query_args = query,
           canonical_headers = list(host = paste0("polly.",region,".amazonaws.com"),
                                    `x-amz-date` = d_timestamp),
           request_body = if (is.null(body)) "" else toJSON(body, auto_unbox = TRUE),
           key = key, 
           secret = secret,
           session_token = session_token)
    headers <- list()
    headers[["x-amz-date"]] <- d_timestamp
    headers[["x-amz-content-sha256"]] <- Sig$BodyHash
    if (!is.null(session_token) && session_token != "") {
        headers[["x-amz-security-token"]] <- session_token
    }
    headers[["Authorization"]] <- Sig[["SignatureHeader"]]
    H <- do.call(add_headers, headers)
        
    if (verb == "POST") {
        if (length(query)) {
            r <- POST(url, H, query = query, body = body, encode = "json", ...)
        } else {
            r <- POST(url, H, body = body, encode = "json", ...)
        }
    } else if (verb == "PUT") {
        if (length(query)) {
            r <- PUT(url, H, query = query, body = body, encode = "json", ...)
        } else {
            r <- PUT(url, H, body = body, encode = "json", ...)
        }
    } else if (verb == "DELETE") {
        r <- DELETE(url, H, ...)
    } else {
        if (length(query)) {
            r <- GET(url, H, query = query, ...)
        } else {
            r <- GET(url, H, ...)
        }
    }
    
    if (http_status(r)$category == "client error") {
        x <- fromJSON(content(r, "text", encoding = "UTF-8"))
        warn_for_status(r)
        h <- headers(r)
        out <- structure(x, headers = h, class = "aws_error")
        attr(out, "request_canonical") <- Sig$CanonicalRequest
        attr(out, "request_string_to_sign") <- Sig$StringToSign
        attr(out, "request_signature") <- Sig$SignatureHeader
    } else {
        if (isTRUE(raw_response)) { 
            out <- try(content(r, "raw"))
        } else {
            out <- try(fromJSON(content(r, "text", encoding = "UTF-8")), silent = TRUE)
        }
        if (inherits(out, "try-error")) {
            out <- structure(content(r, "text", encoding = "UTF-8"), "unknown")
        }
    }
    return(out)
}

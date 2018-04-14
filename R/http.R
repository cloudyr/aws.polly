#' @title Execute AWS Polly API Request
#' @description This is the workhorse function to execute calls to the Polly API.
#' @param action A character string specifying the API action to take
#' @param query An optional named list containing query string parameters and their character values.
#' @param headers A list of headers to pass to the HTTP request.
#' @param body A request body
#' @param verb A character string specifying the HTTP verb to implement.
#' @param version A character string specifying the API version.
#' @param raw_response A logical indicating whether to return the raw response body.
#' @param verbose A logical indicating whether to be verbose. Default is given by \code{options("verbose")}.
#' @param region A character string specifying an AWS region. See \code{\link[aws.signature]{locate_credentials}}.
#' @param key A character string specifying an AWS Access Key. See \code{\link[aws.signature]{locate_credentials}}.
#' @param secret A character string specifying an AWS Secret Key. See \code{\link[aws.signature]{locate_credentials}}.
#' @param session_token Optionally, a character string specifying an AWS temporary Session Token to use in signing a request. See \code{\link[aws.signature]{locate_credentials}}.
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}}.
#' @return If successful, a named list. Otherwise, a data structure of class \dQuote{aws-error} containing any error message(s) from AWS and information about the request attempt.
#' @details This function constructs and signs an Polly API request and returns the results thereof, or relevant debugging information in the case of error.
#' @author Thomas J. Leeper
#' @import httr
#' @import tuneR
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom aws.signature signature_v4_auth
#' @export
pollyHTTP <- 
function(
  action, 
  query = list(),
  headers = list(),
  body = NULL,
  verb = c("GET", "POST", "PUT", "DELETE"),
  version = "v1",
  raw_response = if (verb == "POST") TRUE else FALSE,
  verbose = getOption("verbose", FALSE),
  region = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"), 
  key = NULL, 
  secret = NULL, 
  session_token = NULL,
  ...
) {
    # locate and validate credentials
    credentials <- locate_credentials(key = key, secret = secret, session_token = session_token, region = region, verbose = verbose)
    key <- credentials[["key"]]
    secret <- credentials[["secret"]]
    session_token <- credentials[["session_token"]]
    region <- credentials[["region"]]
    
    # generate request signature
    verb <- match.arg(verb)
    action <- paste0("/", version, "/", action)
    d_timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
    url <- paste0("https://polly.",region,".amazonaws.com", action)
    Sig <- signature_v4_auth(
           datetime = d_timestamp,
           region = region,
           service = "polly",
           verb = verb,
           action = action,
           query_args = query,
           canonical_headers = list(host = paste0("polly.",region,".amazonaws.com"),
                                    `x-amz-date` = d_timestamp),
           request_body = if (is.null(body)) "" else jsonlite::toJSON(body, auto_unbox = TRUE),
           key = key, 
           secret = secret,
           session_token = session_token,
           verbose = verbose)
    # setup request headers
    headers[["x-amz-date"]] <- d_timestamp
    headers[["x-amz-content-sha256"]] <- Sig$BodyHash
    headers[["Authorization"]] <- Sig[["SignatureHeader"]]
    if (!is.null(session_token) && session_token != "") {
        headers[["x-amz-security-token"]] <- session_token
    }
    H <- do.call(add_headers, headers)
    
    # execute request
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
    
    if (http_error(r)) {
        x <- jsonlite::fromJSON(content(r, "text", encoding = "UTF-8"))
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
            out <- try(jsonlite::fromJSON(content(r, "text", encoding = "UTF-8")), silent = TRUE)
        }
        if (inherits(out, "try-error")) {
            out <- structure(content(r, "text", encoding = "UTF-8"), "unknown")
        }
    }
    return(out)
}

#' @rdname synthesize
#' @title Synthesize Speech
#' @description Pass text to the synthesis API and return an audio file
#' @param text Either a plain text character string (maximum 1500 characters) or
#'   a character string containing SSML (\code{ssml} should be set to
#'   \code{TRUE}).
#' @param voice Name of an AWS Polly voice. See \code{\link{list_voices}}.
#' @param format Output file format: one of `'mp3'` (default), `'ogg_vorbis'` or
#'   `'pcm'`.
#' @param rate Deprecated. Use \code{sample_rate} instead.
#' @param sample_rate Audio frequency in Hertz. One of `24000`, `22050`, `16000` or `8000`.
#'   If `NULL` (default), `AWS` will pick an appropriate value depending on the voice,
#'   engine and output format.
#' @param lexicon Deprecated. Use \code{lexicon_names} instead.
#' @param lexicon_names Optional character vector (max length 5) specifying the
#'   names of lexicons to apply during synthesis. See \code{\link{get_lexicon}}.
#' @param ssml A logical indicating whether \code{text} contains SSML markup.
#' @param engine Engine type: either `'standard'` (default) or `'neural'`.
#'   Not all voices support the neural engine, see \code{\link{list_voices}}.
#' @param language Optional language code. This is useful for bilingual voices.
#' @param \dots Additional arguments passed to \code{\link{pollyHTTP}}.
#' @return \code{get_synthesis} returns a raw vector (i.e., the bytes
#'   representing the audio as the requested file format). \code{synthesize} is
#'   a convenience wrapper around that, which returns an object of class
#'   \dQuote{Wave} (see \code{\link[tuneR]{Wave}}).
#' @examples
#' \dontrun{
#' hello <- synthesize("hello world!", voice = "Geraint")
#' if (interactive() & require("tuneR")) {
#'     try(play(hello))
#' }
#' }
#' @export
#' @importFrom lifecycle deprecated
get_synthesis <-
    function(text,
             voice,
             format = c("mp3", "ogg_vorbis", "pcm"),
             rate = deprecated(),
             lexicon = deprecated(),
             ssml = FALSE,
             lexicon_names = NULL,
             sample_rate = NULL,
             engine = c("standard", "neural"),
             language = NULL,
             ...) {

        # `rate` is deprecated in favor of `sample_rate`
        if (lifecycle::is_present(rate)) {
            lifecycle::deprecate_soft("0.1.6",
                                      "aws.polly::get_synthesis(rate = )",
                                      "aws.polly::get_synthesis(sample_rate = )")

            sample_rate <- rate
        }

        # `lexicon` is deprecated in favor of `lexicon_names`
        if (lifecycle::is_present(lexicon)) {
            lifecycle::deprecate_soft("0.1.6",
                                      "aws.polly::get_synthesis(lexicon = )",
                                      "aws.polly::get_synthesis(lexicon_names = )")

            lexicon_names <- lexicon
        }

        if (!isTRUE(ssml) && nchar(text) > 1500) {
            stop("Maximum character limit (1500) exceeded!")
        }

        body <- list(
            Engine = match.arg(engine),
            LanguageCode = language,
            Text = text,
            TextType = if (isTRUE(ssml)) "ssml" else "text",
            VoiceId = voice,
            LexiconNames = lexicon_names,
            OutputFormat = match.arg(format),
            SampleRate = sample_rate
        )

        # Remove empty (NULL) arguments
        body <- Filter(Negate(is.null), body)

        out <- pollyHTTP(action = "speech", verb = "POST", body = body, ...)

        # Handle AWS errors
        if (inherits(out, "aws_error")) {
            stop(out$message)
        }

        return(out)
    }

#' @rdname synthesize
#' @importFrom tuneR readMP3
#' @export
synthesize <-
    function(text,
             voice,
             ...)
    {
        out <- get_synthesis(text = text, voice = voice, format = "mp3", ...)
        tmp <- tempfile()
        writeBin(out, con = tmp)
        on.exit(unlink(tmp))
        tuneR::readMP3(tmp)
    }

#' @rdname synthesize
#' @title Synthesize Speech
#' @description Pass text to the synthesis API and return an audio file
#' @param text Either a plain text character string (maximum 1500 characters) or a character string containing SSML (\code{ssml} should be set to \code{TRUE}).
#' @param voice A character string specifying the name of an AWS Polly voice. See \code{\link{list_voices}}.
#' @param format A character string specifying an output file format.
#' @param rate An integer value specifying the audio frequency in Hertz. If `NULL`, `AWS` will typically default to either `22050` or `24000` depending on the voice.
#' @param lexicon Optionally, a character vector (max length 5) specifying the names of lexicons to apply during synthesis. See \code{\link{get_lexicon}}.
#' @param ssml A logical indicating whether \code{text} contains SSML markup.
#' @param engine the standard or neural engine.  Note, you may need to be
#' in certain regions depending on the API for neural voices.
#' @param language language code for the Synthesize Speech request.
#' This is only necessary if using a bilingual voice.
#' @param speech_mark The type of speech marks returned for the input text.
#' The options are `sentence`, `ssml`, `viseme`, or `word`.
#' @param \dots Additional arguments passed to \code{\link{pollyHTTP}}.
#' @return \code{get_synthesis} returns a raw vector (i.e., the bytes representing the audio as the requested file format). \code{synthesize} is a convenience wrapper around that, which returns an object of class \dQuote{Wave} (see \code{\link[tuneR]{Wave}}).
#' @examples
#' \dontrun{
#' hello <- synthesize("hello world!", voice = "Geraint")
#' if (interactive() & require("tuneR")) {
#'     try(play(hello))
#' }
#' }
#' @export
get_synthesis <-
function(text,
         voice,
         format = c("mp3", "ogg_vorbis", "pcm"),
         rate = c(22050, 16000, 8000),
         lexicon = NULL,
         ssml = FALSE,
         engine = c("standard", "neural"),
         language = NULL,
         speech_mark = NULL,
         ...)
{
    b <- list()
    if (!is.null(lexicon)) {
        b[["LexiconNames"]] <- lexicon
    }
    b[["OutputFormat"]] <- match.arg(format)
    if (!is.null(rate)) {
        b[["SampleRate"]] <- as.character(rate[1L])
    }
    if (!isTRUE(ssml) && nchar(text) > 1500) {
        stop("Maximum character limit (1500) exceeded!")
    }
    b[["SpeechMarkTypes"]] = speech_mark
    b[["LanguageCode"]] = language
    engine = match.arg(engine)
    b[["Engine"]] <- engine
    b[["Text"]] <- text
    b[["TextType"]] <- if (isTRUE(ssml)) "ssml" else "text"
    b[["VoiceId"]] <- voice
    out <- pollyHTTP(action = "speech", verb = "POST", body = b, ...)
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

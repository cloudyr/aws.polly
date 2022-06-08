# aws.polly 0.1.6 

* `list_voices()` can now list voices for all language codes (`@muschellij2`, #6).
  All voices (for all language codes) are now shown by default. 
  Use `language = "en-US"` to replicate the previous default.

* `list_voices()` has new arguments `engine` (to filter on engine types) and 
  `include_additional_languages` (to find bilingual voices with specific additional languages).

* `synthesize()` and `get_synthesis()` have new arguments 
  `engine` (to specify the engine type) and 
  `language` (to specify the language code when using bilingual voices).
  
* In `synthesize()` and `get_synthesis()`, arguments `rate` and `lexicon` are 
  deprecated and replaced by `sample_rate` and `lexicon_names`.

* In `synthesize()` and `get_synthesis()`, the default sample rate is no longer 22050 Hz.
  Instead, AWS will pick the appropriate default based on the voice, engine and output format.

* Speech synthesis now fails with a useful error message when AWS returns an error.

# aws.polly 0.1.5

* Released on CRAN 2020-03-11
* New maintainer @antoine-sachet

# aws.polly 0.1.4

* Fixed a function not found bug in `pollyHTTP()`. (#3)

# aws.polly 0.1.3

* Requests to `get_synthesis()` or `synthesize()` now fail when `nchar(text) > 1500`. (#1, h/t Sean Kross)
* Bumped **aws.signature** dependency to use new, more sophisticated credentials checking.

# aws.polly 0.1.2

* Created separate `synthesize()` and `get_synthesis()` functions. The former as a convenience function wrapping the latter lower-level function.

# aws.polly 0.1.1

* Initial release.

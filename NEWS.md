# aws.polly 0.1.5

* First CRAN release
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

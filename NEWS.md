# CHANGES TO aws.polly 0.1.3

* Requests to `get_synthesis()` or `synthesize()` now fail when `nchar(text) > 1500`. (#1, h/t Sean Kross)
* Bumped **aws.signature** dependency to use new, more sophisticated credentials checking.

# CHANGES TO aws.polly 0.1.2

* Created separate `synthesize()` and `get_synthesis()` functions. The former as a convenience function wrapping the latter lower-level function.

# CHANGES TO aws.polly 0.1.1

* Initial release.

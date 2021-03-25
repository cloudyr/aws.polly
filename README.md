# Speech Synthesis (Text-to-Speech) from AWS Polly

[![CRAN](https://www.r-pkg.org/badges/version/aws.polly)](https://cran.r-project.org/package=aws.polly)
![Downloads](https://cranlogs.r-pkg.org/badges/aws.polly)
[![Build Status](https://travis-ci.org/cloudyr/aws.polly.png?branch=master)](https://travis-ci.org/cloudyr/aws.polly)
[![codecov.io](https://codecov.io/github/cloudyr/aws.polly/coverage.svg?branch=master)](https://codecov.io/github/cloudyr/aws.polly?branch=master)

**aws.polly** is a package for [Polly](http://aws.amazon.com/documentation/polly), an Amazon Web Services speech synthesis (computer voice) web service.

## Code Examples

The basic use of the package is super simple and revolves around the `synthesize()` function, which takes a character string and a voice as input:


```r
library("aws.polly")

# list available voices
list_voices()
```

```
##   AdditionalLanguageCodes Gender       Id LanguageCode LanguageName     Name SupportedEngines
## 1                      NA Female    Salli        en-US   US English    Salli neural, standard
## 2                      NA Female   Joanna        en-US   US English   Joanna neural, standard
## 3                      NA   Male  Matthew        en-US   US English  Matthew neural, standard
## 4                      NA Female      Ivy        en-US   US English      Ivy neural, standard
## 5                      NA   Male   Justin        en-US   US English   Justin neural, standard
## 6                      NA Female   Kendra        en-US   US English   Kendra neural, standard
## 7                      NA Female Kimberly        en-US   US English Kimberly neural, standard
## 8                      NA   Male     Joey        en-US   US English     Joey neural, standard
```

```r
# synthesize some text
vec <- synthesize("Hello world!", voice = "Joanna")
```

The result is a "Wave" object (from the tuneR package), which can be played using `play()` from the `tuneR` package. On Mac OSX and GNU/Linux, you'll first need to specify a player using `setWavPlayer`.

```R
library("tuneR")

# On Mac OSX: setWavPlayer("/usr/bin/afplay")
# On Linux systems, try: setWavPlayer("/usr/bin/aplay")

play(vec)
```

This might also be handy for setting up an audio error handler:

```R
audio_error <- function() tuneR::play(aws.polly::synthesize(geterrmessage(), voice = "Joanna"))
options(error = audio_error)
stop("Everything went horribly wrong")
options(error = NULL)
```


## Setting up credentials


To use the package, you will need an AWS account and to enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. The [**aws.iam** package](https://github.com/cloudyr/aws.iam) profiles tools for working with IAM, including creating roles, users, groups, and credentials programmatically; it is not needed to *use* IAM credentials.

A detailed description of how credentials can be specified is provided at: https://github.com/cloudyr/aws.signature/. The easiest way is to simply set environment variables on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`). They can be also set within R:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```


## Installation


You can install this package from CRAN or, to install the latest development version, from the cloudyr drat repository:

```R
# Install from CRAN
install.packages("aws.polly")

# Latest version passing CI tests, from drat repo
install.packages("aws.polly", repos = c(getOption("repos"), "http://cloudyr.github.io/drat"))
```

You can also pull a potentially unstable version directly from GitHub, using the `remotes` package:

```R
remotes::install_github("cloudyr/aws.polly")
```


---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)

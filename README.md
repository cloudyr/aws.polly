# Speech Synthesis (Text-to-Speech) from AWS Polly

**aws.polly** is a package for [Polly](http://aws.amazon.com/documentation/polly), an Amazon Web Services speech synthesis (computer voice) web service.

To use the package, you will need an AWS account and enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. 

By default, all **cloudyr** packages look for the access key ID and secret access key in environment variables. You can also use this to specify a default region or a temporary "session token". For example:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```

These can alternatively be set on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`).

If you work with multiple AWS accounts, another option that is consistent with other Amazon SDKs is to create [a centralized `~/.aws/credentials` file](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), containing credentials for multiple accounts. You can then use credentials from this file on-the-fly by simply doing:

```R
# use your 'default' account credentials
use_credentials()

# use an alternative credentials profile
use_credentials(profile = "bob")
```

Temporary session tokens are stored in environment variable `AWS_SESSION_TOKEN` (and will be stored there by the `use_credentials()` function). The [aws.iam package](https://github.com/cloudyr/aws.iam/) provides an R interface to IAM roles and the generation of temporary session tokens via the security token service (STS).


## Code Examples ##

The basic use of the package is super simple and revolves around the `synthesize()` function, which takes a character string and a voice as input:


```r
library("aws.polly")

# list available voices
list_voices()
```

```
##   Gender       Id LanguageCode LanguageName     Name
## 1 Female   Joanna        en-US   US English   Joanna
## 2 Female    Salli        en-US   US English    Salli
## 3 Female Kimberly        en-US   US English Kimberly
## 4 Female   Kendra        en-US   US English   Kendra
## 5   Male   Justin        en-US   US English   Justin
## 6   Male     Joey        en-US   US English     Joey
## 7 Female      Ivy        en-US   US English      Ivy
```

```r
# synthesize some text
vec <- synthesize("Hello world!", voice = "Joanna")
```

The result is a "Wave" object (from the tuneR package), which can be played using `play()`:

```R
library("tuneR")
play(vec)
```

This might also be handy for setting up an audio error handler:

```R
audio_error <- function() tuneR::play(aws.polly::synthesize(geterrmessage(), voice = "Joanna"))
options(error = audio_error)
stop("Everything went horribly wrong")
options(error = NULL)
```


## Installation

[![CRAN](https://www.r-pkg.org/badges/version/aws.polly)](https://cran.r-project.org/package=aws.polly)
![Downloads](https://cranlogs.r-pkg.org/badges/aws.polly)
[![Build Status](https://travis-ci.org/cloudyr/aws.polly.png?branch=master)](https://travis-ci.org/cloudyr/aws.polly)
[![codecov.io](https://codecov.io/github/cloudyr/aws.polly/coverage.svg?branch=master)](https://codecov.io/github/cloudyr/aws.polly?branch=master)

This package is not yet on CRAN. To install the latest development version you can install from the cloudyr drat repository:

```R
# latest stable version
install.packages("aws.polly", repos = c(getOption("repos"), "http://cloudyr.github.io/drat"))
```

Or, to pull a potentially unstable version directly from GitHub:

```R
if(!require("ghit")){
    install.packages("ghit")
}
ghit::install_github("cloudyr/aws.polly")
```


---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)

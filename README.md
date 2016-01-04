# boxr
[![Build Status](https://travis-ci.org/brendan-R/boxr.svg)](https://travis-ci.org/brendan-R/boxr)
[![Win Build Status](https://ci.appveyor.com/api/projects/status/github/brendan-r/boxr?branch=master&svg=true)](https://ci.appveyor.com/project/brendan-r/boxr)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](https://img.shields.io/badge/repo%20status-active-brightgreen.svg)](http://www.repostatus.org/#active)
[![cran version](http://www.r-pkg.org/badges/version/boxr)](http://cran.rstudio.com/web/packages/boxr)
![monthly_downloads](http://cranlogs.r-pkg.org/badges/boxr)

A lightweight, high-level R interface for the box.com API, standing on the shoulders of [`httr`](https://github.com/hadley/httr/).

## Installation
You can download boxr from [CRAN](http://cran.r-project.org/web/packages/boxr/), with

```R
install.packages("boxr")
```

If you'd like to download the development version from GitHub, use

```R
# install.packages("devtools")
devtools::install_github("brendan-R/boxr")
```

## Usage
### Basic Operations
Aside from file upload/download, boxr provides functions which mirror base R operations for local files.

* `box_dl(file_id)` and `box_ul(file = 'path/to/file')` download and upload files, respectively
* `box_search()` to query files & folders stored on box.com
* `box_read()` read files straight into R (e.g. .csv or .xlsx files as `data.frames`)
* `box_write()` write R objects to remotely hosted files
* `box_setwd()`/`box_getwd()` get/set a default box folder
* `box_source()` read and execute remote code
* `box_load()`/`box_save()` for remote R workspaces
* `box_add_description()` add text descriptions to your files on box.com


### Directory wide Operations
Cloud storage services can complement version control systems for code, which aren't well suited to large binary files (e.g. databases, .RData, or heaps of pdfs). box explicitly versions binary files, keeping old ones, and making it easy fall back to an older copy.

boxr provides *git style* facilities to upload, download, and synchronize the contents of entire local and remote directories. At the time of writing, the box.com API does not support this directly, and so boxr recursively loops through directory structures.

![Synch a whole directory!](https://s3-us-west-2.amazonaws.com/brendan-misc/boxr_console.png)

* `box_push` will update the remote directory with new/changed local files
* `box_fetch` will update the local directory with new/changed remote files

These functions all have `overwrite` and `delete` parameters, which are set to `FALSE` by default.

**Disclaimer:** box.com is no replacement for a VCS/remote-database, and familiar verbs are no guarantee of expected behavior! Do check the function documentation before jumping in.

### Piping
boxr's functions have been designed to be 'pipable'. Here's a little example:

```r
library(boxr)
library(dplyr)
library(magrittr)

# 'nycflights13.json' is the same as nycflights13::flights, if you want to 
# follow along at home

box_auth()

box_search("nycflights13.json") %>%                # Find a remote file
  box_read() %>%                                   # Download it as a data.frame
    group_by(origin, dest, month) %>%              #   Do some, er, cutting edge 
    summarise(mu = mean(arr_delay), n = n()) %>%   #   analysis with dplyr!
  box_write("delay_summary.xlsx") %>%              # Convert to .xlsx, upload
  box_add_description("Check out these averages!") # Add a description to your file!
  
```

### File/Folder IDs
Are how box.com identifies things. You can find them in an item's URL:

![Finding file and folder ids](https://s3-us-west-2.amazonaws.com/brendan-misc/file_ids.png)

## Getting set up
To use boxr, you need to enable API access for your box.com account. The process is slightly annoying. You only need to do it once - it takes around 2 minutes.

#### 1. 'Create an app'
At [https://www.box.com/developers/services](https://www.box.com/developers/services), log in and create a new 'app' for your box.com account. You can call it anything you like. This won't do anything remotely like creating an app, but it does allow you to access your account via the API.

#### 2. Set OAuth2 Parameters
On the next screen, you'll want to set **Content API Access Only**, and `http://localhost` as your **redirect_uri** as in the screenshot below.

![Setting OAuth2.0 parameters](https://s3-us-west-2.amazonaws.com/brendan-misc/oauth2_paramters.png)

#### 3. Connect boxr to your account
This means passing your client_id and client_secret to the `box_auth` function. These strings are not enough for someone to access your account maliciously. However, it's still a good idea to keep them safe, and out of any files or code which might be shared with others.

Run:

```R
library(boxr)
box_auth()
```

And paste/type the `client_id` and `client_secret` when prompted. If these are valid, a browser window should open, for you to formally grant yourself access to your files at box.com.


#### 4. And you're done
If `box_auth()` worked successfully, you won't need to do any of this again, and thanks to the magic of `httr` everything should *just work*. Your client_id and client_secret will be securely stored in your R environment variables, your hashed OAuth2.0 token will stored at `~/.boxr-oauth`, .gitignore'd if necessary, and automatically refreshed when needed.


## Notes
#### Verbosity
boxr is by default rather verbose, printing status to the console with `cat`. This is 'rude' package behaviour, and may cause unwanted output if used in conjunction with the excellent [`knitr`](https://github.com/yihui/knitr) package.

To supress messages produced using `cat`, set boxr's verbose option with:

```R
options(boxr.verbose = FALSE, boxr.progress = FALSE)
```

#### Alternatives
boxr aims to expedite data analysis/communication/distribution. Other ways to manipulate a box.com account include:

* The box desktop app
* The *other* boxr, [written in Ruby](https://github.com/cburnette/boxr). It's motivations are rather different, and it covers 100% of the box.com API (e.g account administration, etc.)
* box themselves [provide a wide range of SDKs](https://github.com/box), including [one for Python](https://github.com/box/box-python-sdk)

#### Managing your client id & secret
If you don't like the idea of typing credentials into your console, you can put them straight into `~/.Renviron` yourself, prior to the R session:

```bash
BOX_CLIENT_ID="youridhere"
BOX_CLIENT_SECRET="yoursecrethere"
 
```

(Note the final blank line).

#### Troubleshooting
Via [GitHub issues](https://github.com/brendan-R/boxr/issues), please. It's been a while since I've read the R mailing lists!

#### Contributing
Always very welcome! If you'd like to submit a pull request for a new feature, ideally it would be documented, come with an addtion to [NEWS.md](NEWS.md), and have a test or two. This project has a standard [Code of Conduct](CONDUCT.md).

## License
The MIT License (MIT)

Copyright (c) 2015 Brendan Rocks

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

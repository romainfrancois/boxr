# boxr  0.3.4.99999

## Improvements

* modifies `box_source()`: adds `...` argument to pass other arguments to `source()`.

* modifies `box_write()`, `box_dl()`:
  - deprecates the `filename` argument in favor of `file_name`.

* modifies `box_auth()` (#96):
  - deprecates `write.Renv` argument
  - copies text to the clipboard, rather than overwrite the `.Renviron` file
  - returns `invisible(NULL)` upon success 

* deprecates `box_auth_on_attach()` (#96)

* adds a logo (#92, @nathancday)

* converts pagination method from offset to marker-based paging (#79, @awong234)

* adds option to return specified `fields` in `box_ls()` (#72, @awong234)

* adds updated screen shots (pngs in `images/`) and description for creating a Box App with the new Box Developer Console UI. Also added reference for `box_auth_on_attach` in step 4 'And you're done'. (#57, @nathancday)

## Bug Fixes

* `box_pagination()` refactored to employ marker-based paging instead of offset-based paging, avoiding a hard limit of 300,000 offset (#74, @awong234)

* ~~fixes bug in `box_pagination()` to enforce integer for offset (#71, @awong234)~~ Deprecated, pagination now uses marker-based paging.

* fixes bug in `box_search_files()` (#61, @j450h1)

-------------------------------------------------------------------------------

# boxr v0.3.4

## Improvements

* Thanks to Ian Lyttle (added to contributors), the number of entries returned 
by `box_ls()` now has an upper limit of 1,000, as opposed to 100


## Bug Fixes

* The boxr authorization URL grew a spare '/' which caused it to 404, now 
removed (hat tip to Yvonne K. for reporting via email)


-------------------------------------------------------------------------------

# boxr v0.3.3

## Minor Improvements

* `box_push`'s `ignore.dots` parameter now includes directories (65acef7)

* Broader validation that users are correctly authenticated (47b16b5)

* Minor improvements to S3 classes (9a64aa0)

* More prominent troubleshooting section in README (8ccdaa5)

* Updated author email address (a23acc0)


## Big fixes

* box.com API changes had made the ordering in `box_previous_versions` 
unreliable (693f5a2)


--------------------------------------------------------------------------------

# boxr v0.3.2

## Minor Improvements

This release contains some minor changes for compatibility with `httr v1.1.0` 
(boxr's major dependency).

* Some code to work around bugs in the previous versions of `httr` has been 
removed

* Some minor tweaks for compatibility (mainly changes in reporting http status 
codes)


-------------------------------------------------------------------------------

# boxr v0.3.1

## New Features

* `box_search` (and convenience functions `box_search_files`, 
`box_search_folders`, `box_search_trash`) allow use of box.com's superb 
searching facilities to find files and folders. Various parameters can be set to
search filenames, file contents, and to limit searches to certain file types. 
Results are summarised by default, can be coerced via `as.data.frame`. They can 
also be passed in place of a file_id to other boxr functions (e.g. `box_dl`) to 
perform an operation on the first result.

* `box_read_excel` Finally support for everyone *else's* favorite way to store 
data!

* `box_write` A convenience function to convert R objects to common file types 
(e.g. .json, .csv, .tsv, .xlsx, etc.), and upload to box. Using the default 
write function ([rio::export](https://github.com/leeper/rio)), the file type can
be determined automatically from the filename provided.

* `box_add_description` A simple way to add a description to a file on box.com. 
These are a useful way to decribe the contents of a file, and can also be used 
like commit messages on GitHub, to describe recent changes made.

* `box_fresh_auth` A convenience function for users having trouble 
authenticating -- it will delete existing tokens (which are by default hidden 
files) for a fresh authentication process

* S3 classes for files, folders, and object lists

* Objects of class `boxr_object_list` can be passed directly to functions in 
place of a file_id string

* Objects of class `boxr_object_list` now have an `as.data.frame` method


## Improvements

* Example of usage with `magrittr` pipes is added to the [README](README.md)

* box file/folder id's are now validated locally before requests are sent

* Filenames are now validated locally, with helpful/informative error mesages

* `box_read` now accepts a user specified read function, which is now by default
`rio::import`

* `box_read` will now try and do the right thing for files without an extension 
by considering the MIME type of the API response

* S3 classes and methods have been consolidated into three basic types, and 
functions now use them in a consistent manner. Now documented for those 
interested (`?boxr_S3_classes`)

* Print methods: Prettier and more informative

* `box_getwd` no longer logs an uninformative message

* Documentation / collaboration improvements (improved function documentation, 
[variable naming conventions](R/README.md), and a code of conduct)

* Improved tests


## Bug Fixes

* `options(boxr.progress = TRUE)` is now respected consistently

* Fix for spurious warnings comming from the latest version of `httr` (see 
jeroenooms/curl#30 and hadley/httr#252)

* Fix for weird reporting for certain valid API queries, which return exactly 0 
results


-------------------------------------------------------------------------------

# boxr v0.2.9

Note: Skipped a version increment for CRAN iterationsii


## Bug Fixes

* Namespace stuff for the latest Rbuild under Windows


## Installtion

Now up on CRAN:

```r install.packages("boxr") ```


-------------------------------------------------------------------------------

# boxr v0.2.7

## Bug Fixes

* Fixed broken link for image assets in vignette


## Minor Improvements

* The default OAuth2.0 token cache is now `~/.boxr-oauth`


-------------------------------------------------------------------------------

# boxr v0.2.6

This release contains small changes to help new users get started (especially 
those who don't get to see the GitHub README).


## Minor Improvements

* The package vignette (`vignette("boxr")`) is now more oriented towards getting
new users up and running (fc931cd), providing much of the same information as at
`?box_auth`, but with screenshots and friendlier formatting

* Upon loading boxr, users are now provided with the [GitHub issues 
URL](https://github.com/r-box/boxr/issues) for bug reports. If it looks like
the user hasn't used boxr before (`!file.exists("~/.boxr_oauth")`), the code to 
generate the Getting Started vignette is presented (e18864d)

* R help 'homepage': `?boxr` now takes the user to a summary of the package, 
which links back to the Getting Started vignette (#31)

* Continuous integration now covers Windows via appveyor (08925e5), and for 
useRs coming from GitHub, there's a few more visual aids in the README to help 
them evaluate/grok the package (1c574c2, 593101d, 670487b)


## Installation

boxr v0.2.6 is on CRAN, the following will do the trick:

```r install.packages("boxr") ```

-------------------------------------------------------------------------------

# boxr v0.2.5

## CRAN Release

* LO!

* http://cran.r-project.org/web/packages/boxr/


## Bug Fixes

* json is now parsed consistently by `box_read()` and `box_read_json()`

* `box_getwd()` and `box_setwd()` now write to the correct options vars (e.g., 
work properly again) (#27)


## Minor Changes

* General CRAN policy stuff

* Improved tests (f6cc01c, 55d6581)

-------------------------------------------------------------------------------

# boxr v0.2.0

## New Features

* Several new wrapper functions for `box_read` have been added (#25):

* `box_read_csv`

* `box_read_tsv`

* `box_read_json`

* `box_previous_versions` allows you to query previous versions of a file

* `box_dl` can now download specific versions of a file, via either the 
`version_no` or `version_id` parameter (#21)


## Minor Changes

* URLs for the set-up process now point to 
https://www.box.com/developers/services, as opposed to 
https://www.box.com/developers/services (#20)


-------------------------------------------------------------------------------

# boxr v0.1.2

## Minor Changes

* Tiny changes to make the package more amenable to CRAN (not there yet!)

-------------------------------------------------------------------------------

# boxr v0.1.0

## Minor Improvements

* Much more thorough documentation (#1, #3, #16)

* box_dir_diff now has it's own S3 class (#16)

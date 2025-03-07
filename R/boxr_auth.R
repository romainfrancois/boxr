#' Obtain a Box token
#'
#' @description
#' `box_auth()` serves two purposes:
#' 
#' 1. connecting to [box.com](https://developer.box.com/docs) 
#'    accounts from **boxr** for the first time
#' 2. connecting to previously-connected 
#'    [box.com](https://developer.box.com/docs) accounts
#'
#' In either case, it should be sufficient to run `box_auth()` with no
#' parameters. If you have authenticated with boxr before, this should be all
#' that is required. However, the first time you use boxr, the process is
#' slightly more involved (see 'Getting Set-Up' below).
#'
#' @section Getting Set-Up:
#' 
#' A version of this guide is in the package vignette, with some additional
#' screenshots. To view the vignette, run `vignette("boxr")`, or visit this
#' [article](https://r-box.github.io/boxr/articles/boxr.html). To use boxr
#' for the first time, you need to enable API access for your 
#' [box.com](https://developer.box.com/docs) account. The process is slightly annoying. 
#' You only need to do it once - it takes around two minutes.
#'
#' The next time you use boxr, you should be able to just run
#' `box_auth()` (without entering anything else) to be authenticated and
#' ready-to-go.
#' 
#'  1. Create an app:
#'
#'     At [Box Developers Center](https://www.box.com/developers), 
#'     click on 'My Apps', in the top
#'     right hand corner log in and create a new 'app' for your box.com account.
#'     This won't create an app of any description; you'll simply be granting
#'     yourself programmatic access to your files. You can call it anything you
#'     like.
#'     
#'  2. Set OAuth2 Parameters:
#'
#'     On the next screen, you'll want to check the box for 'Content API
#'     Access Only', and enter `http://localhost` as your
#'     `redirect_uri`.
#'     
#'  3. Connect boxr to your account:
#'
#'     Run `box_auth()` and pass your `client_id` and
#'     `client_secret` to the console when prompted. These strings are
#'     not' enough for someone to access your account maliciously. However,
#'     it's still a good idea to keep them safe, and out of any files or code
#'     which might be shared with others.
#'
#' A browser window should open, for you to formally grant yourself access to
#' your files at [box.com](https://developer.box.com/docs).
#'
#' From this point on, simply running `box_auth()` at the start of a
#' session should be all that is required.
#' 
#' @section Side-effects:
#' 
#' This function has some side effects, which make subsequent calls to 
#' `box_auth()` easier:
#' 
#' - a browser window may be opened at [box.com](https://developer.box.com/docs), 
#'   for you to authorize to your Box app.
#'  
#' - a token file is written, according to the value of `cache`. The default
#'   behaviour is to write this file to `~/.boxr-oauth`.
#'
#' - some global [options()] are set for your session to manage the token.
#' 
#' - environment variables `BOX_CLIENT_ID` and `BOX_CLIENT_SECRET` are set.
#' 
#' - if these environment variables have changed, and you have the 
#'   [usethis]() package installed, it will copy some text to your clipboard
#'   that you can paste into your `.Renviron` file.
#' 
#' - a message is printed to the console.  
#' 
#'
#' @inheritParams httr::oauth2.0_token
#' @param client_id `character`, 
#'   the client id for the account to use.
#' @param client_secret `character`, 
#'   the client secret for the account to use. 
#' @param interactive `logical`, indicates that the authorization process 
#'   will be interactive (requiring user input to the R console, and/or a 
#'   visit to [box.com](https://developer.box.com/docs)).
#' @param write.Renv **deprecated**.
#' @param ... Other arguments passed to [httr::oauth2.0_token()].
#'
#' @return `invisible(NULL)`, called for side-effects.
#'
#' See [httr::oauth2.0_token()] for details.
#'
#' @seealso [httr::oauth2.0_token()] for details on how tokens are handled
#'
#' @export
#' 
box_auth <- function(client_id = NULL, client_secret = NULL, 
                     interactive = TRUE, cache = "~/.boxr-oauth", 
                     write.Renv, ...) {

  # deprecate write.Renv
  if (!missing(write.Renv)) {
    warning(
      "argument `write.Renv` is deprecated; ",
      "information provided instead at console."
    )
  }
  
  # read environment variables
  client_id_env <- Sys.getenv("BOX_CLIENT_ID")
  client_secret_env <- Sys.getenv("BOX_CLIENT_SECRET")
  
  # if no input, look to .Renviron for the id and secret
  if (is_void(client_id) && !is_void(client_id_env)) {
    message("Using `BOX_CLIENT_ID` from environment")
    client_id <- client_id_env
  }

  if (is_void(client_secret) && !is_void(client_secret_env)) {
    message("Using `BOX_CLIENT_SECRET` from environment")
    client_secret <- client_secret_env 
  }

  # UI for interactively entering ids and secrets
  if (is_void(client_id) && interactive()) {
    
    message(
      glue::glue(
        "Please enter your box client id.",
        "If you don't have one, hit ENTER to abort, then",
        "see the documentation at ?box_auth.",           
        .sep = "\n"
      )
    )
    client_id <- readline()
    
    # Tidy up any invalid characters
    client_id <- gsub("[[:space:]]|[[:punct:]]", "", client_id)
    
    if (is_void(client_id)) {
      stop("Aborting")
    }
  }

  if (is.null(client_secret) && interactive()) {
    
    message(
      glue::glue(
        "Please enter your box client secret",
        "(Hit ENTER to abort.)",
        .sep = "\n"
      )
    )
    client_secret <- readline()

    # Tidy up any invalid characters
    client_secret <- gsub("[[:space:]]|[[:punct:]]", "", client_secret)
    
    if (is_void(client_secret)) {
      stop("Aborting")
    }
  }

  # At this point, a non-interactive call may still have no id & secret
  if (is_void(client_id) || is_void(client_secret)) {
    stop(
      "box.com authorization unsuccessful; client id and/or secret not found\n",
      "See ?box_auth for help."
    )
  }

  box_app <- 
    httr::oauth_app(
      appname = "box",
      key     = client_id,
      secret  = client_secret
    )

  box_endpoint <- 
    httr::oauth_endpoint(
      authorize = "authorize",
      access    = "token",
      base_url  = "https://app.box.com/api/oauth2"
    )

  box_token <- 
    httr::oauth2.0_token(
      box_endpoint,
      box_app,
      use_oob   = getOption("httr_oob_default"),
      cache     = cache,
      ...
    )

  if (!exists("box_token")) {
    stop("Login at box.com failed; unable to connect to API.")
  }
 
  # Test the connection; retrieve the username
  test_req <- 
    httr::GET(
      "https://api.box.com/2.0/folders/0", 
      httr::config(token = box_token)
    )

  if (httr::http_status(test_req)$cat != "Success") 
    stop("Login at box.com failed; unable to connect to API.")

  cr <- httr::content(test_req)

  # Write the details to the Sys.env
  app_details <-
    stats::setNames(
      list(client_id, client_secret), 
      c("BOX_CLIENT_ID", "BOX_CLIENT_SECRET")
    )

  do.call(Sys.setenv, app_details)

  # Write to options
  options(
    boxr.token = box_token,
    boxr.token.cache = cache,
    boxr.username = cr$owned_by$login,
    box_wd = "0"
  )

  # Let the user know they're logged in
  message(
    glue::glue(
      "boxr: Authenticated at box.com as ",
      "{cr$owned_by$name} ({cr$owned_by$login})"
    )
  )

  new_client_info <- 
    !identical(
      c(client_id, client_secret), 
      c(client_id_env, client_secret_env)
    )

  if (new_client_info && interactive()) {

    # create a code-block for the console
    msg_client_info <- 
      "BOX_CLIENT_ID={client_id}\nBOX_CLIENT_SECRET={client_secret}"
    
    # if usethis installed, encourage to edit .Renviron
    if (requireNamespace("usethis", quietly = FALSE)) {
      usethis::ui_todo(
        "You may wish to add to your {usethis::ui_code('.Renviron')} file:"
      )
      usethis::ui_code_block(msg_client_info)
      usethis::ui_todo(
        c(
          "To edit your {usethis::ui_code('.Renviron')} file:",
          "  - {usethis::ui_code('usethis::edit_r_environ()')}",
          "  - check that {usethis::ui_code('.Renviron')} ends with a newline"
        )
      )
    } else {
      message(
        glue::glue_collapse(
          c(
            "\nYou may wish to add the following to your `.Renviron` file:",
            "  - check that `.Renviron` ends with a newline" ,
            "",
            glue::glue(msg_client_info),
            ""
          ),
          sep = "\n"
        )
      )
    }
  
  }
  
  invisible(NULL)
}


#' Obtain a fresh Box token
#' 
#' Deletes the cached token-file before trying to re-authorise. This 
#' is often the solution to authorisation problems.
#'
#' @inheritParams box_auth
#' @param ... Other arguments passed to [box_auth()].
#' 
#' @seealso [box_auth()] for the usual method of authorisation
#'   
#' @export
#' 
box_fresh_auth <- function(cache = "~/.boxr-oauth", ...) {
  
  assertthat::assert_that(
    is.character(cache),
    fs::file_exists(cache),
    msg = "`cache` must be a valid filename"
  )
  
  unlink(cache, force = TRUE)
  box_auth(cache = cache, ...)
}


#' Obtain a Box token automatically
#'
#' **This function is deprecated, and will be removed at the next relase.** 
#'  
#' This function saves you the effort of typing [box_auth()] after
#' the package loads. Executing `box_auth_on_attach(TRUE)` will mean that
#' `boxr` will automatically attempt to authorize itself when
#' 'attached' (e.g. `library(boxr)`), using the credentials from the
#' current session.
#' 
#' @note This is provided for convenience, but it's a bad idea to use, if:
#'   * You'd like your code to be reporoducible. Even if your
#'   collaborators have access to the same files on box.com, as the default
#'   behaviour is to require using [box_auth()], code is likely to
#'   become irreproducible.
#'   
#'   * You use more than one box.com account. Things could get
#'   rather confusing.
#'
#' @param auth_on_attach `logical`, indicates if boxr should authenticate 
#'   as soon as it's loaded.
#'
#' @return `invisible(NULL)`, called for side-effects.
#'
#' @seealso [box_auth()]
#'
#' @export
#' 
box_auth_on_attach <- function(auth_on_attach = FALSE) {
  assertthat::assert_that(!is.na(auth_on_attach))
  assertthat::assert_that(is.logical(auth_on_attach))

  .Deprecated(
    msg = "box_auth_on_attach() is deprecated; it will be removed in boxr 3.6.0"
  )
  
  if (!interactive()) {
    stop("box_auth_on_attach() can be called only interactively.")
  }
  
  checkAuth()

  # Path to the R environment variables file, if it exists
  env_path <-
    normalizePath(paste0(Sys.getenv("HOME"), "/.Renviron"), mustWork = FALSE)

  if (file.exists(env_path)) {
    re <- readLines(env_path)
  } else {
    re <- NULL
  }

  # Remove any where they details were previously set, and write the new ones
  # to the end of the file
  writeLines(
    c(
      re[!grepl("BOX_AUTH_ON_ATTACH|BOX_TOKEN_CACHE", re)],
      paste0('BOX_AUTH_ON_ATTACH="', auth_on_attach, '"'),
      paste0('BOX_TOKEN_CACHE="', getOption("boxr.token.cache"), '"')
    ),
    con = env_path
  )

  user <- getOption("boxr.username")

  if (auth_on_attach) {
    message(
      "boxr will now attempt to authorize you as\n    ", user, "\nwhen",
      "'attached', e.g.    \nlibrary(boxr)\n"
    )
  } else {
    message(
      "boxr will *NOT* attempt to authorize you when",
      "'attached', e.g.    \nlibrary(boxr)\n"
    )
  }
  
  invisible(NULL)
}


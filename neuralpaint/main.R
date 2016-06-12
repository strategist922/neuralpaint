library(httr)
library(httpuv)
library(twitteR)
library(magrittr)

source("./credentials.R")

BASE_DIR <- file.path(Sys.getenv("HOME"), "neuralpaint-users")

application <- oauth_app("twitter",
                        key = consumer_key,
                        secret = consumer_secret)

twitter_token <- oauth1.0_token(oauth_endpoints("twitter"), application)

setup_twitter_oauth(consumer_key = consumer_key,
                    consumer_secret = consumer_secret,
                    access_token = access_token,
                    access_secret = access_secret)

query_twitter <- function() {
  req <- httr::GET("https://api.twitter.com/1.1/statuses/mentions_timeline.json", config(token = twitter_token))
}

get_inputs <- function(status_id) {
  selected_status <- content(req)[sapply(content(req), FUN = function(x) x$id == status_id)][[1]]
  username <- selected_status$user$screen_name
  content_image_url <- selected_status$extended_entities$media[[1]]$media_url_https
  style_image_url <- selected_status$extended_entities$media[[2]]$media_url_https
  outputs <- list(username = username,
                 status_id = status_id,
               content_image_url = content_image_url,
               style_image_url = style_image_url)
}

create_directory <- function(inputs) {
  dir.create(file.path(BASE_DIR, inputs$username, inputs$status_id), recursive = TRUE,showWarnings = FALSE)
  return(inputs)
}

save_images <- function(inputs) {
  content_image_loc <- file.path(BASE_DIR, inputs$username, inputs$status_id, "content_image")
  style_image_loc <- file.path(BASE_DIR, inputs$username, inputs$status_id, "style_image")
  download.file(inputs$content_image_url, content_image_loc)
  download.file(inputs$style_image_url, style_image_loc)
  outputs <- c(inputs, list(content_image_loc = content_image_loc, style_image_loc = style_image_loc))
}

construct_system_call <- function(inputs, num_iterations = 200, output_image_loc = file.path(BASE_DIR, inputs$username, inputs$status_id, "out.png")) {
  paste(
    "th",
    "./neural_style.lua",
    "-content_image",
    inputs$content_image_loc,
    "-style_image",
    inputs$style_image_loc,
    "-output_image",
    output_image_loc,
    "-num_iterations",
    num_iterations,
    "-gpu",
    "-1",
    "-optimizer",
    "adam"
  )
}

style_image_synchronous <- function(inputs) {
  setwd("../neural-style")
  system(construct_system_call(inputs))
  return(c(inputs, list(output_image_loc = file.path(BASE_DIR, inputs$username, inputs$status_id, "out.png"))))
}

post_image <- function(inputs) {
  text <- paste0("@", inputs$username)
  media_path <- inputs$output_image_loc
  tweet(text = text,
        inReplyTo = inputs$status_id,
        mediaPath = media_path)
}

req <- query_twitter()
most_recent_id <- content(req)[[1]]$id_str

get_inputs(most_recent_id) %>% create_directory() %>% save_images() %>% style_image_synchronous() %>% post_image()

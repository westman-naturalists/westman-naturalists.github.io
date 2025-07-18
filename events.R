library(dplyr)
library(stringr)
library(tidyr)
library(purrr)
library(lubridate)
library(glue)
library(janitor)
library(googlesheets4)

gs4_deauth()

events <- gs4_get("https://docs.google.com/spreadsheets/d/132krSjS7w574gavkX31XxmcmmafXbC-zfM81W2mDXAY/") |>
  read_sheet() |>
  clean_names() |>
  select(-contains("calendar")) |>
  mutate(across(c("tentative", "remote_speaker"), \(x) {
    x <- tolower(x) == "yes"
    replace_na(x, FALSE)
  })) |>
  mutate(month = month(date),
         year = year(date),
         date = as_date(date),
         date_pretty = if_else(tentative, "%b %Y", "%A, %b %d %Y"),
         date_pretty = format(date, date_pretty),
         time = map(time, as.character),
         speaker = if_else(is.na(speaker) | speaker == "", "the speaker", speaker)) |>
  mutate(time = map(time, ~replace(.x, length(.x) == 0, "All day"))) |>
  unnest(cols = "time") |>
  mutate(time = if_else(str_detect(time, "[0-9]{4}-[0-9]{2}"),
                        format(suppressWarnings(as_datetime(time)), "%I:%M %p"),
                        time)) |>
  mutate(
    past = date < Sys.Date(),
    past = replace_na(past, FALSE),
    time = str_remove(time, "^0"),
    description = str_replace_all(description,
                                  "westman.naturalists@gmail.com",
                                  "[westman.naturalists@gmail.com](mailto:westman.naturalists@gmail.com)"),
    description = str_replace(description, regex("(Trip difficulty)", ignore_case = TRUE), "**\\1**"),
    extra = if_else(extra != "", glue("<div class = 'notice'>\n\n{extra}\n\n</div>"), ""),
    cancelled = str_detect(tolower(description), regex("cancelled", ignore_case = TRUE)),
    cancelled = replace_na(cancelled, FALSE),

    status = if_else(cancelled, "**<span class='notice'>Cancelled</span>** ", ""),
    hosted = replace_na(hosted, "Westman Naturalists"),
    talk = "This is a hybrid event!",
    talk = if_else(remote_speaker,
                   glue("{talk} {speaker} will be joining us via Zoom, but we'll still be meeting in person!"),
                   glue("{talk}")),
    talk = glue("{talk} Feel free to come in person to"),
    talk = if_else(remote_speaker,
                   glue("{talk} socialize with your fellow Westman Naturalists"),
                   glue("{talk} meet {speaker}")),
    talk = if_else(
      !is.na(form),
      glue("{talk} and see the talk, or join us via Zoom. ",
           "To join us via Zoom, please complete and submit this [short form]({form}) to sign-up. ",
           "We will email out the Zoom link the evening of the talk."),
      glue("{talk} and see the talk, or join us via Zoom. ",
           "**Zoom signup form coming soon!**")),
    outing = glue("Please complete this [short form]({form}) to sign-up for this event. ",
                  "We will email you with specific details a day or so before the event. ",
                  "Car pooling might be available."),
    outing = case_when(
      is.na(form) ~ "No sign up is required for this event, though there will be a waiver to sign.",
      form == tolower("TBA") ~ "Further details to come",
      .default = outing),
    form = case_when(!is.na(form) & !str_detect(form, "^http") ~ form,
                     hosted != "Westman Naturalists" ~ "",
                     type == "talk" ~ talk,
                     type == "outing" ~ outing),
    footer = if_else(str_detect(hosted, "Westman Naturalists"),
                     "[Contact Westman Naturalists for more information](mailto:westman.naturalists@gmail.com)",
                     "Note that this event is not hosted by Westman Naturalists"),
    footer = if_else(past, "", footer),
    hosted = glue("Hosted by {hosted}"),
    location = if_else(is.na(location) & type == "talk", "Brodie Building Rm 4-34, Brandon University & Online ([directions](talks.html))", location),
    form = glue("**Participation**: {form}"),
    form = if_else(past, "", form),
    event = glue("{extra}\n\n",
                 "{status}<span class = 'date'>{date_pretty}</span>\n\n",
                 "<span class = 'event-title'>{title}</span> {hosted}\n\n",
                 "{description}\n\n",
                 "{form}\n\n",
                 "**Time**: {time}<br>",
                 "**Location**: {location}\n\n",
                 "{footer}", .na = ""),
    post_link = case_when(
      !is.na(link) & !is.na(image) ~ glue("[![<a href=\"{link}\">Link to summary on Facebook</a>]({image}){{.big-figure fig-alt=\"A picture from facebook about the event\"}}]({link})"),
      !is.na(link) ~ glue("<a href=\"{link}\">Link to summary on Facebook</a>"),
      !is.na(image) ~ glue("![&nbsp;]({image}){{.big-figure fig-alt=\"A picture from facebook about the event\"}}"),
      .default = "")
  )

if(any(is.na(events$time))) stop("Problems with Time", call. = FALSE)

saveRDS(events, "events.rds")

# Create event advertising templates
e <- events |>
  filter(!cancelled, !advertised %in% "yes", date >= Sys.Date(), !tentative,
         description != "TBA") |>
  mutate(
    title = if_else(title == "Nature Walk", paste(title, "at", location), title),
    event_discover = glue("{extra}\n\n",
                          "{status}{date_pretty} - {time}\n",
                          "{location}\n\n",
                          "Westman Naturalists - {title}\n\n",
                          "{description}\n\n",
                          "{form}\n\n", .na = ""),
    form = str_replace(form, "\\[(short form)\\]", "\\1 "),
    event_ebrandon = glue("{extra}\n\n",
                          "{status}{date_pretty}- {time}\n",
                          "{location}\n\n",
                          "Westman Naturalists - {title}\n\n",
                          "{description}\n\n",
                          "{form}\n\n", .na = ""),
    form = str_remove_all(form, "\\*"),
    event_facebook = glue("{extra}\n\n",
                          "{status}{date_pretty} - {time}\n\n",
                          "{title}\n\n",
                          "{description}\n\n",
                          "{form}\n\n", .na = "")
  )

writeLines(pull(e, event_facebook) |>
             paste(collapse = "\n\n-----------\n\n"),
           glue("event_advertising/facebook.txt"))

writeLines(pull(e, event_ebrandon) |>
             paste(collapse = "\n\n-----------\n\n"),
           glue("event_advertising/ebrandon.md"))

writeLines(pull(e, event_discover) |>
             paste(collapse = "\n\n-----------\n\n"),
           glue("event_advertising/discover.txt"))


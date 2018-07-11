deps <- c(
  "shiny",
  "shinyjs",
  "dplyr",
  "purrr",
  "data.table",
  "readxl",
  "lubridate"
)

pkgs <- rownames(installed.packages())

install.packages(deps[!(deps %in% pkgs)], repo = "https://cloud.r-project.org")

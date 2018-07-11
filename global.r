library(dplyr)
library(purrr)
library(shiny)
library(shinyjs)
library(readxl)
library(lubridate)

read_sheet <- function(path) {
  switch(
    tools::file_ext(path),
    xls = read_xls(path),
    xlsx = read_xlsx(path),
    data.table::fread(path, data.table = FALSE)
  ) %>% as.data.frame
}

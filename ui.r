ui <- tagList(
  useShinyjs(),
  navbarPage(
    "Date Shift",
    tabPanel(
      "Assign shift period",
      fluidRow(
        column(
          width = 4,
          h5("Upload original data"),
          fileInput(
            "original-file", NULL,
            accept = c(
              "application/vnd.ms-excel",
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              "text/csv",
              "text/plain"
            )
          )
        ),
        column(
          width = 4,
          h5("Select identifier column"),
          uiOutput("identifier-ui")
        ),
        column(
          width = 4,
          h5("Specify shifting range (years)"),
          numericInput("from", NULL, 100L, NA, 1L),
          numericInput("to", NULL, 300L, NA, 1L)
        )
      ),
      fluidRow(
        column(
          width = 4,
          h5("Download mappings"),
          downloadButton("download-mappings", "Download",
                         class = "btn-primary")
        )
      )
    ),
    tabPanel(
      "Apply shifting",
      fluidRow(
        column(
          width = 4,
          h5("Upload original data"),
          fileInput(
            "unshifted-file",
            NULL,
            accept = c(
              "application/vnd.ms-excel",
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
          )
        ),
        column(
          width = 4,
          h5("Select identifier column"),
          uiOutput("unshifted-identifier-ui")
        ),
        column(
          width = 4,
          h5("Upload mappings"),
          fileInput(
            "mappings-upload",
            NULL,
            accept = c(
              "application/vnd.ms-excel",
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              "text/csv",
              "text/plain"
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 4,
          h5("Download shifted data"),
          downloadButton("download-shifted", "Download",
                         class = "btn-primary")
        )
      )
    )
  )
)

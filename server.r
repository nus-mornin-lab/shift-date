server <- function(input, output, session) {
  original_data <- reactive({
    in_file <- input$`original-file`
    if (is.null(in_file)) return(NULL)
    
    tryCatch(
      read_sheet(in_file$datapath),
      error = function(e) {
        print(e)
        NULL
      }
    )
  })
  
  output$`identifier-ui` <- renderUI({
    data <- original_data()
    if (is.null(data)) return(NULL)
    
    radioButtons("identifier", NULL,
                 choices = names(data), selected = character(0))
  })
  
  mappings <- reactive({
    data <- original_data()
    from <- input$from
    to <- input$to
    identifier <- input$identifier
    
    if (is.null(data) | is.null(from) | is.null(to) | is.null(identifier)) {
      return(NULL)
    }
    
    from_week <- from * 365L %/% 7L
    to_week <- to * 365L %/% 7L
    
    data %>%
      select(!! as.name(identifier)) %>%
      setNames("identifier") %>%
      mutate(shift = base::sample(from_week:to_week, n(), replace = TRUE))
  })
  
  observe(
    if (is.null(mappings())) {
      disable("download-mappings")
    } else {
      enable("download-mappings")
    }
  )
  
  output$`download-mappings` <- downloadHandler(
    filename = "mappings.csv",
    content = function(file) {
      if (is.null(mappings())) return(NULL)
      data.table::fwrite(mappings(), file)
    },
    contentType = "text/csv"
  )
  
  unshifted <- reactive({
    in_file <- input$`unshifted-file`
    if (is.null(in_file)) return(NULL)
    
    tryCatch(
      read_excel(in_file$datapath),
      error = function(e) {
        print(e)
        NULL
      }
    )
  })
  
  user_mappings <- reactiveVal()
  observe({
    in_file <- input$`mappings-upload`
    if (is.null(in_file)) return(NULL)
    
    df <- tryCatch(
      read_sheet(in_file$datapath),
      error = function(e) {
        print(e)
        NULL
      }
    )
    
    if ((! "identifier" %in% names(df)) | (! "shift" %in% names(df))) {
      showModal(modalDialog(
        HTML("The file must contain one <i>identifier</i> column and 
             one <i>shift</i> column"),
        easyClose = FALSE
      ))
    } else {
      df %>%
        select(!!! rlang::syms(c("identifier", "shift"))) %>%
        user_mappings()
    }
  })
  
  output$`unshifted-identifier-ui` <- renderUI({
    data <- unshifted()
    if (is.null(data)) return(NULL)
    
    radioButtons("unshifted-identifier", NULL,
                 choices = names(data), selected = character(0))
  })
  
  shifted <- reactive({
    unshifted_df <- unshifted()
    identifier <- input$`unshifted-identifier`
    mappings_df <- user_mappings()
    
    if (is.null(unshifted_df) | is.null(identifier) | is.null(mappings_df)) {
      return(NULL)
    }
    
    df <- unshifted_df %>%
      left_join(mappings_df %>%
                  rename(!! identifier := (!! as.name("identifier"))),
                by = identifier) %>%
      mutate_if(is.instant, funs(. + weeks(shift))) %>%
      mutate_if(
        is.instant,
        funs(
          sprintf("%s-%s-%s %s:%s:%s",
                  year(.), month(.), day(.),
                  hour(.), minute(.), second(.))
        )
      ) %>%
      select(-shift) %>%
      as.data.frame
  })
  
  observe(
    if (is.null(user_mappings())) {
      disable("download-shifted")
    } else {
      enable("download-shifted")
    }
  )
  
  output$`download-shifted` <- downloadHandler(
    filename = function() {
      input$`unshifted-file` %>%
        pluck("name") %>%
        basename %>%
        tools::file_path_sans_ext() %>%
        paste0("_shifted.csv")
    },
    content = function(file) {
      data.table::fwrite(shifted(), file)
    },
    contentType = "text/csv"
  )
}

library(shiny)

ui <-
  shinyUI(fluidPage(tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  ),
  
  fluidRow(
    column(2, "  "), column(8, box(width = NULL,
                                   uiOutput("infoTable"))), column(2, " ")
  )))
server <- shinyServer(function(input, output) {
  output$infoTable <- renderUI({
    url <- 'http://www.timeanddate.com/moon/phases/'
    xpath <- '//*[@id="mn-cyc"]'
    
    data <-
      url %>% read_html() %>% html_nodes(xpath = xpath) %>% html_table()
    data <- data.frame(data)
    moon_phases <-
      data.frame('moon_type' = t(data[1,]),
                 'phase_data' = t(data[3,]))
    rm(data)
    data_images <-
      url %>% read_html() %>% html_nodes('.wt-ic img') %>% html_attr('src')
    data_images <-
      paste0('http:',data_images)
    moon_phases$image_url <- data_images
    rm(data_images)
    tags$table(class = 'table',
               tags$thead((
                 tags$tr(
                   tags$th(moon_phases[1, 1]),
                   tags$th(moon_phases[2, 1]),
                   tags$th(moon_phases[3, 1]),
                   tags$th(moon_phases[4, 1])
                 )
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(moon_phases[1, 2]),
                   tags$td(moon_phases[2, 2]),
                   tags$td(moon_phases[3, 2]),
                   tags$td(moon_phases[4, 2])
                 ),
                 tags$tr(
                   tags$td(img(src = moon_phases[1, 3], height=80,width=80)),
                   tags$td(img(src = moon_phases[2, 3], height=80,width=80)),
                   tags$td(img(src = moon_phases[3, 3], height=80,width=80)),
                   tags$td(img(src = moon_phases[4, 3], height=80,width=80))
                 )
               ))
  })
})

shinyApp(ui,server)
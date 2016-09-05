library(stringr)
library(ggmap)
library(shiny)
library(dplyr)

# setwd("~/Downloads/national_parks/")

# Building an app ---------------------------------------------------------

geography_list <- read.csv('state_district_list.csv')
state_list <-
  setNames(as.list(1:length(unique(
    geography_list$state
  ))), unique(geography_list$state))
district_list <-
  setNames(as.list(1:length(unique(
    geography_list$district
  ))), unique(geography_list$district))

ui <- 
  shinyUI(fluidPage(
  fluidRow(column(2,"  ")),
  fluidRow(column(2),column(8,wellPanel(h2("Check out the national parks closest to your city and other details"))),column(2)),
  fluidRow(
    column(2),
    column(4, wellPanel(
      selectInput("state_label",
                  "Select your state",
                  state_list)
    )),
    
    column(4, wellPanel(
      selectInput("district_label",
                  "Choose your district",
                  district_list)
    )),
    column(2)
  )
))


server <-
  shinyServer(function(input, output, clientData, session) {
    observe({
      
      state_label <- input$state_label
      selected_state <- names(state_list[as.numeric(state_label)])
      
      geography_list <-
        geography_list[geography_list$state == selected_state,]
      district_list <-
        setNames(as.list(1:length(unique(
          geography_list$district
        ))), unique(geography_list$district))
      
      # browser()
      updateSelectInput(session, "district_label", choices = district_list)
      
    })
  })

shinyApp(ui, server)

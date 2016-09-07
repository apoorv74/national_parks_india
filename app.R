library(stringr)
library(ggmap)
library(shiny)
library(dplyr)

# Haversign function
havesign_dist <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  delta.long <- (long2 - long1)
  delta.lat <- (lat2 - lat1)
  a <-
    sin(delta.lat / 2) ^ 2 + cos(lat1) * cos(lat2) * sin(delta.long / 2) ^
    2
  c <- 2 * asin(min(1, sqrt(a)))
  d = R * c
  return(d) # Distance in km
}

# setwd("~/Downloads/national_parks/")

# Building an app ---------------------------------------------------------

geography_list <-
  read.csv('state_district_list.csv', stringsAsFactors = F)
geography_list$long <- as.numeric(geography_list$long)
geography_list$lat <- as.numeric(geography_list$lat)
geography_list$rad_lat <- geography_list$lat * pi / 180
geography_list$rad_long <- geography_list$long * pi / 180

park_data <- read.csv('np_data.csv', stringsAsFactors = F)
park_data$rad_latitude <- park_data$latitude * pi / 180
park_data$rad_longitude <- park_data$longitude * pi / 180



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
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
    ),
    
    fluidRow(column(2, "  ")),
    fluidRow(column(2), column(8, wellPanel(
      h2("Check out the national parks closest to your city and other details")
    )), column(2)),
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
    ),
    fluidRow(column(2),column(8, htmlOutput('parks_list')),column(2))
  ))


server <-
  shinyServer(function(input, output, clientData, session) {
    observe({
      state_label <- input$state_label
      selected_state <- names(state_list[as.numeric(state_label)])
      
      geography_list <-
        geography_list[geography_list$state == selected_state, ]
      district_list <- geography_list$district

      updateSelectInput(session, "district_label", choices = district_list)
      
    })
    
    output$parks_list <- renderUI({
      district <- input$district_label
      
      lat1 <- geography_list$rad_lat[geography_list$district == district]
      long1 <- geography_list$rad_long[geography_list$district == district]
      distance_master <- c()
      for(i in 1:nrow(park_data)){
        lat2 <- park_data$rad_latitude[i]
        long2 <- park_data$rad_longitude[i]

        distance <- havesign_dist(long1,lat1,long2,lat2)
        distance_master <- rbind(distance_master,distance)
      }

      distance_df <- data.frame('park_name' = park_data$Name,'state' = park_data$State,'district' = park_data$District,'distance' = distance_master,row.names = NULL)
      distance_df <- arrange(distance_df,distance)
      rm(distance_master)
      rm(distance)
      str0 <- 'Top 5 national parks closet to your district: '
      for(j in 1:5){
        assign(paste0('str',j),paste0(j,'. <b>',distance_df$park_name[j],'</b> in - ',distance_df$district[j], ', State - ',distance_df$state[j]))
      }
      # HTML(paste('<center> <h2>',str0,'</h2>', str1, str2, str3, str4, str5, '</center>',sep = '<br/>'))
      HTML(paste('<h2>',str0,'</h2>', str1, str2, str3, str4, str5, sep = '<br/>'))
      # browser()
    })
  })

shinyApp(ui, server)

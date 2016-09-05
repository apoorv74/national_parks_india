
library(rvest)

xpath <- '/html/body/table[2]'
url <- 'http://ces.iisc.ernet.in/envis/sdev/parks.htm'
data <-
  url %>% read_html() %>% html_nodes(xpath = xpath) %>% html_table()
data <- data[[1]]
names(data)[] <- data[1,]
data <- data[2:nrow(data),]
data$`Area of park (sq km)` <-
  str_replace_all(data$`Area of park (sq km)`, ',', '')
data$`Area of park (sq km)` <-
  as.numeric(data$`Area of park (sq km)`)
data$`Date of establishment` <-
  as.numeric(data$`Date of establishment`)

xpath_2 <- '/html/body/table[3]'
data_2 <-
  url %>% read_html() %>% html_nodes(xpath = xpath_2) %>% html_table()
data_2 <- data_2[[1]]
names(data_2)[] <- names(data)[]
data_2$`Area of park (sq km)` <-
  str_replace_all(data_2$`Area of park (sq km)`, ',', '')
data_2$`Area of park (sq km)` <-
  as.numeric(data_2$`Area of park (sq km)`)
data_2$`Date of establishment` <-
  as.numeric(data_2$`Date of establishment`)

np_data <- rbind(data, data_2)
geo_master <- c()
for (i in 1:nrow(np_data)) {
  temp <- geocode(np_data$Name[i])
  geo_master <- rbind(geo_master, temp)
}

np_data <- cbind(np_data, geo_master)

# write.csv(np_data,'~/Downloads/national_parks/np_data.csv',row.names=F)

xpath_3 <- '/html/body/table[18]'
state_wise_protected_areas <-
  url %>% read_html() %>% html_nodes(xpath = xpath_3) %>% html_table
state_wise_protected_areas <- state_wise_protected_areas[[1]]
names(state_wise_protected_areas)[] <-
  state_wise_protected_areas[1,]
state_wise_protected_areas <-
  state_wise_protected_areas[2:nrow(state_wise_protected_areas),]
# write.csv(
#   state_wise_protected_areas,
#   '~/Downloads/national_parks/state_wise_protected_areas.csv',
#   row.names = F
# )


# Adding lat longs to national parks --------------------------------------
location_master <- c()
count <- 0
for (i in 7:11) {
  location <-
    readline(paste0(
      'Enter coordinates for ',
      np_data$Name[i],
      ' in ',
      np_data$District[i],
      ' : '
    ))
  count <- ifelse(str_length(location) > 0, count + 1, count)
  location_master <- rbind(location_master, location)
  cat(paste0('Location for ', count, ' parks added'))
}

# If running the same code, split columns by ',' and rename columns before the next step
# location_master <- read.csv('~/Downloads/national_parks/np_lat_lon.csv')
np_data <- cbind(np_data, location_master)
# write.csv(np_data,'~/Downloads/national_parks/np_data.csv',row.names=F)

# Add Guru Ghasidas NP - Chhtisgarh 23.783234, 82.015051 (Divided from sanjay national park in MP)
np_data$Name[np_data$Name == 'Sanjay' &
               np_data$District == 'Surguja, Koria'] <-
  'Guru Ghasidas'

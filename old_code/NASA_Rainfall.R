
source("load_path.R", echo=FALSE) 

NASAdata <- file.path(AbidjanDir, "Autonome D_Abidjan")
Earthdata <- file.path(NASAdata, "EarthData")
EVIkm <- file.path(Earthdata, "MODIS-TERRA_VegetationIndex_EVI_1km_Monthly_2013-23")
EVIm <- file.path(Earthdata, "MODIS-TERRA_VegetationIndex_EVI_500m_16d_2013-23")
NDVIkm <- file.path(Earthdata,"MODIS-TERRA_VegetationIndex_NDVI_1km_Monthly_2013-23")
Rainfall2013_23 <- file.path(NASAdata, "Rainfall 2013-2023")
Climatedata <- file.path(NASAdata, "ClimateSERV")
RainfallPlus <- file.path(Climatedata, "Extracted_ClimeServ_CHIRPS_")
Abidjanmap1 <- file.path(NASAdata, "Autonome D_Abidjan2.geojson")



Abidjan = Abi_shapefile[[3]] %>% filter(NAME_1 == "Abidjan")
df_abidjan1 = st_intersection(Abi_shapefile[[7]], Abidjan)


##############################################################################################################################################################
# RAINFALL
###############################################################################################################################################################

########## Yearly rainfall 2013 ############

pattern2013 <- paste0("2013[0-9]+.tif")



rainfall_2013 <- list.files(file.path(Rainfall2013_23), pattern = pattern2013, full.names = TRUE)

# print(rainfall_2013)

rainfall_data13 = lapply(seq_along(rainfall_2013), 
                         function(x) raster::raster(rainfall_2013[[x]]))

raindata13 = rainfall_data13 %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$meanrain13 <- rowMeans(raindata13[-1], na.rm=TRUE)

rainfall_plotdata13 <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(meanrain13, c(0, 0.05, 0.1, 0.16, 0.2,
                                  0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$meanrain13
Summary$avgrain13_x <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

library(ggrepel)
ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1, aes(fill = meanrain13)) + 
  scale_fill_continuous(name = "Average Rainfall", low = "grey", high = "darkblue") +
  #geom_text_repel(data = rainfall_plotdata13, aes(label = round(meanrain13, 2)), size = 3) +
  #geom_sf_text(data = rainfall_plotdata13, aes(geometry = geometry, label = meanrain13))+
  geom_sf_text(data = rainfall_plotdata13, aes(geometry = geometry, label = round(meanrain13, 2)))+
  #geom_sf_text_repel(aes(label = meanrain13), size = 3) +
  labs(title = "Average rainfall in Abidjan (2013)", fill = "", x = NULL, y = NULL) +
  map_theme()


#####Test for absent years######
pattern2014 <- paste0("2018[0-9]+.tif")
rainfall_2014 <- list.files(file.path(Rainfall2013_23), pattern = pattern2014, full.names = TRUE)
print(rainfall_2014)

#################################################################################
#####################DATA FROM CLIMESERV FOLDER##################################
#################################################################################
##### 2013-2023####

avgrainfall  = list.files( file.path(RainfallPlus), 
                             pattern = ".tif", full.names = TRUE)

avgrainfalldata = lapply(seq_along(avgrainfall), 
                       function(x) raster::raster(avgrainfall[[x]]))

## split the list by indices, 1-100 etc. for extraction. the list of raster layer is avgrainfalldata

avgrain_allyrs = avgrainfalldata %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$meanRAIN <- rowMeans(avgrain_allyrs, na.rm=TRUE)

avgrain_plotallyrs <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(meanRAIN, c(0, 0.05, 0.1, 0.16, 0.2,
                                0.25, 0.3, 0.4), include.lowest = T ))
#####Write to summary
Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$meanRAIN
Summary$meanRAIN2013_23 <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1, aes(fill = meanRAIN)) + 
  scale_fill_continuous(name = "Average Rainfall", low = "grey", high = "darkblue") +
  geom_sf_text(data = avgrain_plotallyrs, aes(geometry = geometry, label = round(meanRAIN, 2)))+
  labs(title = "Average rainfall in Abidjan (2013-2023)", fill = "", x = NULL, y = NULL) +
  map_theme()

####2013

pattern2013 <- paste0("2013[0-9]+.tif")


rainfall_2013b <- list.files(file.path(RainfallPlus), pattern = pattern2013, full.names = TRUE)


rainfall_data13b = lapply(seq_along(rainfall_2013b), 
                         function(x) raster::raster(rainfall_2013b[[x]]))

raindata13b = rainfall_data13b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain13b <- rowMeans(raindata13b, na.rm=TRUE)

rainfall_plotdata13b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain13b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain13b
Summary$avgrain2013b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

ggplot(data = df_abidjan1[1:10, ]) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1[1:10, ], aes(fill = avgrain13b)) + 
  scale_fill_continuous(name = "Average Rainfall mm", low = "grey", high = "darkblue") +
  geom_sf_text(data = rainfall_plotdata13b[1:10, ], aes(geometry = geometry, label = round(avgrain13b, 3)))+
  labs(title = "Average rainfall in Abidjan (2013)", fill = "", x = NULL, y = NULL) +
  map_theme()

######2014
pattern2014 <- paste0("2014[0-9]+.tif")
rainfall_2014b <- list.files(file.path(RainfallPlus), pattern = pattern2014, full.names = TRUE)

rainfall_data14b = lapply(seq_along(rainfall_2014b), 
                          function(x) raster::raster(rainfall_2014b[[x]]))
raindata14b = rainfall_data14b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain14b <- rowMeans(raindata14b, na.rm=TRUE)

rainfall_plotdata14b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain14b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain14b
Summary$avgrain2014b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

ggplot(data = df_abidjan1[1:10, ]) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1[1:10, ], aes(fill = avgrain14b)) + 
  scale_fill_continuous(name = "Average Rainfall mm", low = "grey", high = "darkblue") +
  geom_sf_text(data = rainfall_plotdata14b[1:10, ], aes(geometry = geometry, label = round(avgrain14b, 3)))+
  labs(title = "Average rainfall in Abidjan (2014)", fill = "", x = NULL, y = NULL) +
  map_theme()

######2015
pattern2015 <- paste0("2015[0-9]+.tif")
rainfall_2015b <- list.files(file.path(RainfallPlus), pattern = pattern2015, full.names = TRUE)

rainfall_data15b = lapply(seq_along(rainfall_2015b), 
                          function(x) raster::raster(rainfall_2015b[[x]]))
raindata15b = rainfall_data15b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain15b <- rowMeans(raindata15b, na.rm=TRUE)

rainfall_plotdata15b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain15b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain15b
Summary$avgrain2015b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

###### 2016
pattern2016 <- paste0("2016[0-9]+.tif")
rainfall_2016b <- list.files(file.path(RainfallPlus), pattern = pattern2016, full.names = TRUE)

rainfall_data16b = lapply(seq_along(rainfall_2016b), 
                          function(x) raster::raster(rainfall_2016b[[x]]))
raindata16b = rainfall_data16b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain16b <- rowMeans(raindata16b, na.rm=TRUE)

rainfall_plotdata16b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain16b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain16b
Summary$avgrain2016b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)


######2017
pattern2017 <- paste0("2017[0-9]+.tif")
rainfall_2017b <- list.files(file.path(RainfallPlus), pattern = pattern2017, full.names = TRUE)

rainfall_data17b = lapply(seq_along(rainfall_2017b), 
                          function(x) raster::raster(rainfall_2017b[[x]]))
raindata17b = rainfall_data17b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain17b <- rowMeans(raindata17b, na.rm=TRUE)

rainfall_plotdata17b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain17b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain17b
Summary$avgrain2017b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

######2018
pattern2018 <- paste0("2018[0-9]+.tif")
rainfall_2018b <- list.files(file.path(RainfallPlus), pattern = pattern2018, full.names = TRUE)

rainfall_data18b = lapply(seq_along(rainfall_2018b), 
                          function(x) raster::raster(rainfall_2018b[[x]]))
raindata18b = rainfall_data18b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain18b <- rowMeans(raindata18b, na.rm=TRUE)

rainfall_plotdata18b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain18b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain18b
Summary$avgrain2018b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

######2019
pattern2019 <- paste0("2019[0-9]+.tif")
rainfall_2019b <- list.files(file.path(RainfallPlus), pattern = pattern2019, full.names = TRUE)

rainfall_data19b = lapply(seq_along(rainfall_2019b), 
                          function(x) raster::raster(rainfall_2019b[[x]]))
raindata19b = rainfall_data19b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain19b <- rowMeans(raindata19b, na.rm=TRUE)

rainfall_plotdata19b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain19b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain19b
Summary$avgrain2019b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

######2020
pattern2020 <- paste0("2020[0-9]+.tif")
rainfall_2020b <- list.files(file.path(RainfallPlus), pattern = pattern2020, full.names = TRUE)

rainfall_data20b = lapply(seq_along(rainfall_2020b), 
                          function(x) raster::raster(rainfall_2020b[[x]]))
raindata20b = rainfall_data20b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain20b <- rowMeans(raindata20b, na.rm=TRUE)

rainfall_plotdata20b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain20b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain20b
Summary$avgrain2020b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)


######2021
pattern2021 <- paste0("2021[0-9]+.tif")
rainfall_2021b <- list.files(file.path(RainfallPlus), pattern = pattern2021, full.names = TRUE)

rainfall_data21b = lapply(seq_along(rainfall_2021b), 
                          function(x) raster::raster(rainfall_2021b[[x]]))
raindata21b = rainfall_data21b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain21b <- rowMeans(raindata21b, na.rm=TRUE)

rainfall_plotdata21b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain21b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain21b
Summary$avgrain2021b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)


######2022
pattern2022 <- paste0("2022[0-9]+.tif")
rainfall_2022b <- list.files(file.path(RainfallPlus), pattern = pattern2022, full.names = TRUE)

rainfall_data22b = lapply(seq_along(rainfall_2022b), 
                          function(x) raster::raster(rainfall_2022b[[x]]))
raindata22b = rainfall_data22b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain22b <- rowMeans(raindata22b, na.rm=TRUE)

rainfall_plotdata22b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain22b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain22b
Summary$avgrain2022b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

######2023
pattern2023 <- paste0("2023[0-9]+.tif")
rainfall_2023b <- list.files(file.path(RainfallPlus), pattern = pattern2023, full.names = TRUE)

rainfall_data23b = lapply(seq_along(rainfall_2023b), 
                          function(x) raster::raster(rainfall_2023b[[x]]))
raindata23b = rainfall_data23b %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))

df_abidjan1$avgrain23b <- rowMeans(raindata23b, na.rm=TRUE)

rainfall_plotdata23b <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(avgrain23b, c(0, 0.05, 0.1, 0.16, 0.2,
                                   0.25, 0.3, 0.4), include.lowest = T))

Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
selected_column <- df_abidjan1$avgrain23b
Summary$avgrain2023b <- selected_column
write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)

ggplot(data = df_abidjan1[1:10, ]) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1[1:10, ], aes(fill = avgrain23b)) + 
  scale_fill_continuous(name = "Average Rainfall mm", low = "grey", high = "darkblue") +
  geom_sf_text(data = rainfall_plotdata23b[1:10, ], aes(geometry = geometry, label = round(avgrain23b, 3)))+
  labs(title = "Average rainfall in Abidjan (2023)", fill = "", x = NULL, y = NULL) +
  map_theme()

#####COMBINED AVERAGE
rainfall_data <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
rainfall_data$combined_avgrainfall <- rowMeans(rainfall_data[, 7:17], na.rm = TRUE)
write.csv(rainfall_data, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)
df_abidjan1$combined_avgrainfall <- rainfall_data$combined_avgrainfall

##### addd new column to df abidjan 1 before plotting
###clean up code
df_abidjan1$avgrain23b <- rowMeans(raindata23b, na.rm=TRUE)
ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1, aes(fill = combined_avgrainfall)) + 
  scale_fill_continuous(name = "Average Rainfall", low = "grey", high = "darkblue") +
  geom_sf_text(data = rainfall_data [1:10, ], aes(label = round(combined_avgrainfall, 2))) +
  labs(title = "Average Rainfall (2013-2023)", fill = "", x = NULL, y = NULL) +
  map_theme()

ggplot(data = df_abidjan1[1:10, ]) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = df_abidjan1[1:10, ], aes(fill = combined_avgrainfall)) + 
  scale_fill_continuous(name = "Average Rainfall mm", low = "grey", high = "darkblue") +
  #geom_sf_text(data = rainfall_plotdata23b[1:10, ], aes(geometry = geometry, label = round(avgrain23b, 3)))+
  labs(title = "Average rainfall in Abidjan (2013-2023)", fill = "", x = NULL, y = NULL) +
  map_theme()

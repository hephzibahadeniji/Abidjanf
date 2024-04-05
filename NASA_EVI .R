source("load_path.R", echo=FALSE) 



##############################################################################################################################################################
# EVI and NDVI Analysis (Enhanced Vegetation Index and Normalized Difference Vegetation Index)
###############################################################################################################################################################

####### combined 1km EVI values from 2013-2023

files_names10  = list.files( file.path(EVIkm), 
                           pattern = ".tif", full.names = TRUE)

raster_data10 = lapply(seq_along(files_names10), 
                     function(x) raster::raster(files_names10[[x]]))

EVI_data10 = raster_data10 %>%
  purrr::map(~raster::extract(., df_abidjan1,
                              buffer = buffer,
                              fun = mean, df =TRUE)) %>%
  purrr::reduce(left_join, by = c("ID"))



#all the EVI data summary
df_abidjan1$meanEVI <- rowMeans(EVI_data10[, 2:133], na.rm=TRUE)

evi_plottingdata10 <- df_abidjan1 %>%
  sf::st_as_sf() %>%
  mutate(class = cut(meanEVI, c(0, 0.05, 0.1, 0.16, 0.2,
                                0.25, 0.3, 0.4), include.lowest = T ))

ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = evi_plottingdata10, aes(geometry = geometry, fill = meanEVI)) +
  scale_fill_continuous(name="enhance vegetation index", low = "#F6E0b3", high = "darkgreen") +
  labs(subtitle = '', fill = "", x = NULL, y = NULL) +
  map_theme() 


combined_data <- df_abidjan1 %>% 
  st_drop_geometry() %>% 
  dplyr::select(NOM, meanEVI)



# write.csv(combined_data, file.path("Abidjan Data Variables.csv"), row.names = FALSE)


##########################################################################################
####### Analysis
##########################################################################################

column_names <- expand.grid(mon = month.abb, yr = 2013:2023) %>% 
  mutate(column_name = paste0(mon, "_", yr))
  


names(EVI_data10) <- c("ID", column_names$column_name)

EVI_data <- combined_data %>% 
  cbind(EVI_data10) %>% 
  reshape::melt(id = c("NOM", "ID")) %>% 
  filter(variable != "meanEVI") %>% 
  tidyr::separate(variable, into = c("month", "year"), sep = "_") %>% 
  group_by(NOM, year) %>% 
  mutate(yearly_meanEVI = mean(value, na.rm = T)) %>% 
  ungroup() %>% 
  group_by(NOM) %>%
  mutate(overall_meanEVI = mean(value, na.rm = T))
  

# write.csv(EVI_data, file.path(EVIkm , "overall_EVI_data.csv"), row.names = FALSE)

EVI_plottingdata <- inner_join(df_abidjan1, EVI_data )

##########################################################################################
####### Plots
##########################################################################################


ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = EVI_plottingdata, aes(geometry = geometry, fill = yearly_meanEVI )) +
  facet_wrap(~year)+
  scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
  labs(title = "EVI (1KM)", fill = "", x = NULL, y = NULL) +
  map_theme() 



ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = EVI_plottingdata, aes(geometry = geometry, 
                                       fill = overall_meanEVI )) +
  scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
  labs(title = "enhanced vegetation index (1KM)", fill = "", x = NULL, y = NULL) +
  map_theme()




# EVI_data
# 
# 
# 
# pattern2013 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2013", "..._aid0001.tif")
# rasters_2013 <- list.files(file.path(EVIkm), pattern = pattern2013, full.names = TRUE)
# print(rasters_2013)
# raster_data13 = lapply(seq_along(rasters_2013), 
#                        function(x) raster::raster(rasters_2013[[x]]))
# EVI_data13 = raster_data13 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI13 <- rowMeans(EVI_data13, na.rm=TRUE)
# 
# evi_plottingdata13 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI13, c(0, 0.05, 0.1, 0.16, 0.2,
#                                 0.25, 0.3, 0.4), include.lowest = T))

# 
# 
# #### Write to Summary
# Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
# selected_column <- df_abidjan1$meanEVI13
# Summary$meanEVI2013 <- selected_column
# write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)
# 
# ###2014
# 
# pattern2014 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2014", "..._aid0001.tif")
# rasters_2014 <- list.files(file.path(EVIkm), pattern = pattern2014, full.names = TRUE)
# print(rasters_2014)
# raster_data14 = lapply(seq_along(rasters_2014), 
#                        function(x) raster::raster(rasters_2014[[x]]))
# EVI_data14 = raster_data14 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# 
# df_abidjan1$meanEVI14 <- rowMeans(EVI_data14, na.rm=TRUE)
# 
# evi_plottingdata14 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI14, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata14, aes(geometry = geometry, fill = meanEVI14)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2014 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# 
# ###2015
# pattern2015 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2015", "..._aid0001.tif")
# rasters_2015 <- list.files(file.path(EVIkm), pattern = pattern2015, full.names = TRUE)
# print(rasters_2015)
# raster_data15 = lapply(seq_along(rasters_2015), 
#                        function(x) raster::raster(rasters_2015[[x]]))
# EVI_data15 = raster_data15 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI15 <- rowMeans(EVI_data15, na.rm=TRUE)
# 
# evi_plottingdata15 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI15, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata15, aes(geometry = geometry, fill = meanEVI15)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2015 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# ####2016
# pattern2016 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2016", "..._aid0001.tif")
# rasters_2016 <- list.files(file.path(EVIkm), pattern = pattern2016, full.names = TRUE)
# print(rasters_2016)
# raster_data16 = lapply(seq_along(rasters_2016), 
#                        function(x) raster::raster(rasters_2016[[x]]))
# EVI_data16 = raster_data16 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI16 <- rowMeans(EVI_data16, na.rm=TRUE)
# 
# evi_plottingdata16 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI16, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata16, aes(geometry = geometry, fill = meanEVI16)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2016 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# ########2017
# pattern2017 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2017", "..._aid0001.tif")
# rasters_2017 <- list.files(file.path(EVIkm), pattern = pattern2017, full.names = TRUE)
# print(rasters_2017)
# raster_data17 = lapply(seq_along(rasters_2017), 
#                        function(x) raster::raster(rasters_2017[[x]]))
# EVI_data17 = raster_data17 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI17 <- rowMeans(EVI_data17, na.rm=TRUE)
# 
# evi_plottingdata17 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI17, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata17, aes(geometry = geometry, fill = meanEVI17)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2017 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# ######2018
# pattern2018 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2018", "..._aid0001.tif")
# rasters_2018 <- list.files(file.path(EVIkm), pattern = pattern2018, full.names = TRUE)
# print(rasters_2018)
# raster_data18 = lapply(seq_along(rasters_2018), 
#                        function(x) raster::raster(rasters_2018[[x]]))
# EVI_data18 = raster_data18 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI18 <- rowMeans(EVI_data18, na.rm=TRUE)
# 
# evi_plottingdata18 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI18, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata18, aes(geometry = geometry, fill = meanEVI18)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2018 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# #####2019
# pattern2019 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2019", "..._aid0001.tif")
# rasters_2019 <- list.files(file.path(EVIkm), pattern = pattern2019, full.names = TRUE)
# print(rasters_2019)
# raster_data19 = lapply(seq_along(rasters_2019), 
#                        function(x) raster::raster(rasters_2019[[x]]))
# EVI_data19 = raster_data19 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI19 <- rowMeans(EVI_data19, na.rm=TRUE)
# 
# evi_plottingdata19 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI19, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata19, aes(geometry = geometry, fill = meanEVI19)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2019 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# #######2020
# pattern2020 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2020", "..._aid0001.tif")
# rasters_2020 <- list.files(file.path(EVIkm), pattern = pattern2020, full.names = TRUE)
# print(rasters_2020)
# raster_data20 = lapply(seq_along(rasters_2020), 
#                        function(x) raster::raster(rasters_2020[[x]]))
# EVI_data20 = raster_data20 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI20 <- rowMeans(EVI_data20, na.rm=TRUE)
# 
# evi_plottingdata20 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI20, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata20, aes(geometry = geometry, fill = meanEVI20)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2020 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# 
# 
# #############2021
# pattern2021 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2021", "..._aid0001.tif")
# rasters_2021 <- list.files(file.path(EVIkm), pattern = pattern2021, full.names = TRUE)
# print(rasters_2021)
# raster_data21 = lapply(seq_along(rasters_2021), 
#                        function(x) raster::raster(rasters_2021[[x]]))
# EVI_data21 = raster_data21 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI21 <- rowMeans(EVI_data21, na.rm=TRUE)
# 
# evi_plottingdata21 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI21, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata21, aes(geometry = geometry, fill = meanEVI21)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2021 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# 
# #######2022
# pattern2022 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2022", "..._aid0001.tif")
# rasters_2022 <- list.files(file.path(EVIkm), pattern = pattern2022, full.names = TRUE)
# print(rasters_2022)
# raster_data22 = lapply(seq_along(rasters_2022), 
#                        function(x) raster::raster(rasters_2022[[x]]))
# EVI_data22 = raster_data22 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI22 <- rowMeans(EVI_data22, na.rm=TRUE)
# 
# evi_plottingdata22 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI22, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata22, aes(geometry = geometry, fill = meanEVI22)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2022 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# #######2023
# pattern2023 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2023", "..._aid0001.tif")
# rasters_2023 <- list.files(file.path(EVIkm), pattern = pattern2023, full.names = TRUE)
# print(rasters_2023)
# raster_data23 = lapply(seq_along(rasters_2023), 
#                        function(x) raster::raster(rasters_2023[[x]]))
# EVI_data23 = raster_data23 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# df_abidjan1$meanEVI23 <- rowMeans(EVI_data23, na.rm=TRUE)
# 
# evi_plottingdata23 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI23, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plottingdata23, aes(geometry = geometry, fill = meanEVI23)) +
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2023 EVI (1KM)", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# #### Write to summary
# Summary <- read.csv("C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv")
# selected_column <- df_abidjan1$meanEVI23
# Summary$meanEVI2023 <- selected_column
# write.csv(Summary, "C:/Users/hp/Urban Malaria Proj Dropbox/urban_malaria/data/abidjan/Abidjan Data Variables.csv", row.names = FALSE)
# 
# ###########################################################################################################################################
# ######EVI for Built Areas 2023
# #########################################################################################################################
# BuiltupDir <-  file.path(AbidjanDir, "Built up area")
# Built_areas <- st_read(file.path(BuiltupDir, "Built up area.shp"))
# view(Built_areas)
# 
# pattern2023 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2023", "..._aid0001.tif")
# rasters_2023 <- list.files(file.path(EVIkm), pattern = pattern2023, full.names = TRUE)
# print(rasters_2023)
# raster_data23 = lapply(seq_along(rasters_2023), 
#                        function(x) raster::raster(rasters_2023[[x]]))
# EVI_data_built23 = raster_data23 %>%
#   purrr::map(~raster::extract(., Built_areas,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# view(EVI_data_built23)
# Built_areas$meanEVI23 <- rowMeans(EVI_data_built23, na.rm=TRUE)
# 
# evi_plotbuilt23 <- Built_areas %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI23, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot()+
#   geom_sf(data = df_abidjan1, aes(), color= "black", fill = "#ece9f7")+
#   geom_sf(data = Built_areas) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plotbuilt23, aes(geometry = geometry, fill = meanEVI23)) +
#   geom_sf_text(data = evi_plotbuilt23, aes(geometry = geometry, label = meanEVI23,))+
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") + # Uncomment if you want to label the slums  scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2023 EVI (1KM) IN BUILT AREAS", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# #################
# #####EVI INVERSE OF BUILT AREAS
# ##########
# 
# builtfile <- st_read(file.path(BuiltupDir, "Built up area.shp"))
# abidjanfile <- st_read(Abidjanmap1)
# 
# if (!identical(st_crs(builtfile), st_crs(abidjanfile))) {
#   builtfile <- st_transform(builtfile, st_crs(abidjanfile))
# }
# st_write(abidjanfile, file.path("~/abidjan.shp"), append=FALSE)
# citymap <- st_read(file.path("~/abidjan.shp"))
# 
# minus_built<- st_difference(citymap, builtfile)
# st_write(minus_built, "~/minus_built.shp", append = FALSE)
# non_built_areas <- st_read(file.path("~/minus_built.shp"))
# view(non_built_areas)
# 
# pattern2023 <- paste0("MOD13A3.061__1_km_monthly_EVI_doy", "2023", "..._aid0001.tif")
# rasters_2023 <- list.files(file.path(EVIkm), pattern = pattern2023, full.names = TRUE)
# print(rasters_2023)
# raster_data23 = lapply(seq_along(rasters_2023), 
#                        function(x) raster::raster(rasters_2023[[x]]))
# 
# EVI_data_inverse_built23 = raster_data23 %>%
#   purrr::map(~raster::extract(., non_built_areas,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# 
# view(EVI_data_inverse_built23)
# 
# non_built_areas$meanEVI23 <- rowMeans(EVI_data_inverse_built23, na.rm=TRUE)
# 
# evi_plotinversebuilt23 <- non_built_areas %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanEVI23, c(0, 0.05, 0.1, 0.16, 0.2,
#                                   0.25, 0.3, 0.4), include.lowest = T))
# ggplot()+
#   #geom_sf(data = df_abidjan1, aes(), color= "black", fill = "#ece9f7")+
#   geom_sf(data = citymap, aes(), color= "black", fill = "#ece9f7")+
#   geom_sf(data = non_built_areas) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = evi_plotinversebuilt23, aes(geometry = geometry, fill = meanEVI23)) +
#   geom_sf_text(data = evi_plotinversebuilt23, aes(geometry = geometry, label = meanEVI23))+ 
#   scale_fill_continuous(name="enhanced vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(title = "2023 EVI (1KM) IN NON BUILT AREAS", fill = "", x = NULL, y = NULL) +
#   map_theme()
# 
# 
# 
# 
# 
# 
# #######################################################################################################################
# ###combined NDVI values 2013-2023
# 
# ndvifiles_names10  = list.files( file.path(NDVIkm), 
#                            pattern = ".tif", full.names = TRUE)
# 
# ndviraster_data10 = lapply(seq_along(ndvifiles_names10), 
#                      function(x) raster::raster(ndvifiles_names10[[x]]))
# 
# NDVI_data10 = ndviraster_data10 %>%
#   purrr::map(~raster::extract(., df_abidjan1,
#                               buffer = buffer,
#                               fun = mean, df =TRUE)) %>%
#   purrr::reduce(left_join, by = c("ID"))
# 
# df_abidjan1$meanNDVI <- rowMeans(NDVI_data10, na.rm=TRUE)
# 
# ndvi_plottingdata10 <- df_abidjan1 %>%
#   sf::st_as_sf() %>%
#   mutate(class = cut(meanNDVI, c(0, 0.05, 0.1, 0.16, 0.2,
#                                 0.25, 0.3, 0.4), include.lowest = T ))
# 
# ggplot(data = df_abidjan1) +
#   geom_sf(color = "black", fill = "white") +
#   geom_sf(data = ndvi_plottingdata10, aes(geometry = geometry, fill = meanNDVI)) +
#   scale_fill_continuous(name="normalized difference vegetation index", low = "#F6E0b3", high = "darkgreen") +
#   labs(subtitle = '', fill = "", x = NULL, y = NULL) +
#   map_theme() 
# 
# 

#source("~/Abidjan/load_path.R", echo=FALSE)
source("C:/Users/hp/Abidjan/load_path.R", echo=FALSE)

NASAdata <- file.path(AbidjanDir, "Autonome D_Abidjan")
Abidjan = Abi_shapefile[[3]] %>%
  filter(NAME_1 == "Abidjan")

df_abidjan1 = st_intersection(Abi_shapefile[[7]], Abidjan)

names(Abi_shapefile)

ggplot(data = Abi_shapefile[[7]])+ #health_district - 113
  geom_sf(color = "black", fill = 	"#ece9f7")+
  # geom_text_repel(
  #   data = Abi_shapefile[[7]],
  #   aes(label =  NOM, geometry = geometry),color ='black',
  #   stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 113 health districts of Cote d' Ivoire", 
       fill = "", x = NULL, y = NULL)+
  map_theme()

#get Abidjan health district from the first file                                                                                                                                                  
Abidjan = Abi_shapefile[[3]] %>% filter(NAME_1 == "Abidjan")
df_abidjan1 = st_intersection(Abi_shapefile[[7]], Abidjan)
ggplot(data = Abidjan)+
  geom_sf(data = df_abidjan1, color = "black", fill = 	"#ece9f7")+
  geom_text_repel(
    data = df_abidjan1,
    aes(label = str_to_sentence(NOM), geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 15 health districts of Abidjan", 
       fill = "", x = NULL, y = NULL)+
  map_theme()

#layer with small settlements: Small settlements are likely rural/suburban areas
SmallsetDir <-  file.path(AbidjanDir, "Small settlement area")
small_set <- st_read(file.path(SmallsetDir, "Small settlement area.shp"))
view(small_set)

ggplot()+
  geom_sf(data = df_abidjan1)+
  geom_sf(color = "black", fill = "#ece9f7") +
  geom_sf(data = small_set, color = "red", fill = "transparent", size = 1) +  
  labs(title = "Abidjan Health Districts with Small Settlements", fill = "", x = NULL, y = NULL) +
  map_theme()
 

#plot Abidjan slums
slum_data <- read.csv(file.path(AbidjanDir, "Abidjan slums.csv"))
slum_data <- slum_data[complete.cases(slum_data$Longitude, slum_data$Latitude), ]
slum_sf <-  st_as_sf(slum_data, coords = c("Longitude", "Latitude"), crs = 4326)
view(slum_sf)

ggplot()+
  geom_sf(data = df_abidjan1)+
  geom_sf(data = slum_sf, color="purple", size =1)+
  geom_sf(color = "black", fill ="#ece9f7")+
  labs(title = "Slums in Abidjan", x = "Longitude", y = "Latitude") +
  map_theme()

#plot built up areas
BuiltupDir <-  file.path(AbidjanDir, "Built up area")
Built_areas <- st_read(file.path(BuiltupDir, "Built up area.shp"))
view(Built_areas)

ggplot()+
  geom_sf(data = df_abidjan1)+ 
  geom_sf(color = "black", fill = "#ece9f7") +
  geom_sf(data = Built_areas, color = "green", fill = "transparent", size = 1) +  
  labs(title = "Abidjan Health Districts with Built up Areas", fill = "", x = NULL, y = NULL) +
  map_theme()


#plot settlement types in Abidjan
descriptive_text <- paste("The slum communities identified and included in this map are:",
                          toString(slum_data[, "Slum.Name"]))
wrapped_text <- strwrap(descriptive_text, width = 50)  
wrapped_text <- paste(wrapped_text, collapse = "\n")

ggplot()+
  geom_sf(data = df_abidjan1, color = "black", fill = "#ece9f7" )+ 
  geom_sf(data = small_set, color = "red", fill = "transparent", size = 0.5) +
  geom_sf(data = slum_sf, color="purple", size = 1.2)+
  geom_sf(data = Built_areas, color = "green", fill = "transparent", size = 0.5) + 
  labs(title = "Housing Structure in Abidjan", fill = "", x = "Longitude", y = "Latitude", caption = wrapped_text)+
  theme(plot.caption = element_text(hjust = 0.5, margin = margin(t = 10, b = 10, unit = "pt")))+
  map_theme()

####alternate, will clean

#ggplot() +
 # geom_sf(data = df_abidjan1, aes(fill = "Health Districts"), color = "black") +
  #geom_sf(data = Built_areas, aes(fill = "Built-up Areas"), color = "green", size = 0.5) +
  #geom_sf(data = small_set, aes(fill = "Small Settlements"), color = "red", size = 0.5) +
  #geom_sf(data = slum_sf, aes(fill = "Slums"), color = "purple", size = 1.2) +
  #labs(title = "Housing Structure in Abidjan", fill = "", x = "Longitude", y = "Latitude", caption = wrapped_text) +
#  theme(plot.caption = element_text(hjust = 0.5, margin = margin(t = 10, b = 10, unit = "pt"))) +
#  guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
#  scale_fill_manual(values = c("Health Districts" = "#ece9f7", "Small Settlements" = "red", "Slums" = "purple", "Built-up Areas" = "green")) +
#  theme(legend.position = "right")

ggplot() +
  geom_sf(data = df_abidjan1, color = "black") +
  geom_sf(data = small_set, aes(geometry = geometry, fill = "small_set"), alpha = 0.2) +
  geom_sf(data = slum_sf, aes(geometry = geometry, color = "slum_sf"), size = 2) +
  geom_sf(data = Built_areas, aes(geometry = geometry, fill = "Built_areas"), alpha = 0.2) +
  scale_fill_manual(name = "",
                    values = c("small_set" = "red",  "Built_areas" = "green"),
                    labels = c("Small Settlements", "Built Areas")) +
  scale_color_manual(name = "",
                     values = c( "slum_sf" = "purple"),
                     labels = c("Slum")) +
  labs(title = "Housing Structure in Abidjan", # x = "Longitude", y = "Latitude",
       caption = wrapped_text) +
  theme(plot.caption = element_text(hjust = 0.5, margin = margin(t = 10, b = 10, unit = "pt"))) +
  map_theme()


###########################
##########Building counts and Slums

######### BUILDING COUNTS
Abi_grid <- file.path(NASAdata, "OB_Abidjan_WGS84_grid_with_building_counts", "OB_Abidjan_grid_with_building_counts.shp")
Abi_griddata <- st_read(Abi_grid)
print(Abi_griddata)


ggplot()+
  geom_sf(data = df_abidjan1, aes())+
  geom_sf(data= Abi_griddata, aes(fill = total_buil))+
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Building Counts in Abidjan") +
  map_theme()

Abi_build <- st_intersection(df_abidjan1, Abi_griddata)
ggplot()+
  geom_sf(data= Abi_build, aes(fill = total_buil))+
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Building Counts in Abidjan") +
  map_theme()


### Building counts with slums
ggplot() +
  #geom_sf(data = df_abidjan1, aes()) +
  #geom_sf(data = Abi_griddata, aes(fill = total_buil)) +
  geom_sf(data= Abi_build, aes(fill = total_buil))+
  geom_sf(data = slum_sf, aes(geometry = geometry), color = "black", size = 1) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Building Counts and Slums in Abidjan") +
  map_theme()


### slum count in each health district
slum_districts <- st_join(df_abidjan1, slum_sf, join = st_intersects)

slum_counts <- slum_districts %>%
  group_by(NOM) %>%
  summarise(Slum_Count = n())

ggplot() +
  geom_sf(data = df_abidjan1, aes()) +  # Base map
  geom_sf(data = slum_counts, aes(fill = Slum_Count), color = "black", size = 0.2) +  # Choropleth layer
  scale_fill_gradient(name = "Slum Count", low = "lightyellow", high = "brown") +  # Color scale
  labs(title = "Slum Count by Health District") +
  map_theme()
  

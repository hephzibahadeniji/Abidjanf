source("~/Abidjan/load_path.R", echo=FALSE)

##############################################################################################################################################################
# visualize shapefiles  
###############################################################################################################################################################
names(Abi_shapefile)

#note adm0 is map of Cote d'Ivoire

ggplot(data = Abi_shapefile[[2]])+  #Admin 1 - 14 
  geom_sf(color = "black", fill = "#e79a9a")+
  geom_text_repel(
    data = Abi_shapefile[[2]],
    aes(label =  NAME_1, geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 14 Districts of Cote d'Ivoire, 
       Abidjan and Yamoussoukro are autonomous", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_districts_CoteDIvoire.pdf'),  width = 8, height =5)

ggplot(data = Abi_shapefile[[3]])+ #Admin 2 - 33 
  geom_sf(color = "black", fill = "#7edfc4")+
  geom_text_repel(
    data = Abi_shapefile[[3]],
    aes(label =  NAME_2, geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 33 regions of Cote d' Ivoire , 
       Abidjan and Yamoussoukro are autonomous", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_regions_CoteDIvoire.pdf'),  width = 8, height =5)


ggplot(data = Abi_shapefile[[4]])+ #Admin 3 - 113 
  geom_sf(color = "black", fill = 	"#c08daa")+
  labs(title="All 113 departments of Cote d' Ivoire , 
       Abidjan and Yamoussoukro do not have departments", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_departments_CoteDIvoire.pdf'),  width = 8, height =5)


ggplot(data = Abi_shapefile[[5]])+ #Admin 4 - 191
  geom_sf(color = "black", fill = 	"#b4ebe8")+
  labs(title="All 191 sub-prefectures of Cote d' Ivoire , 
       Abidjan and Yamoussoukro do not have sub-prefectures", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_subprectures_CoteDIvoire.pdf'),  width = 8, height =5)


ggplot(data = Abi_shapefile[[6]])+ #facies - 11
  geom_sf(color = "black", fill = 	"#ece9f7")+
  geom_text_repel(
    data = Abi_shapefile[[6]],
    aes(label =  facies, geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 11 facies of Cote d' Ivoire", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_facies_CoteDIvoire.pdf'),  width = 8, height =5)



ggplot(data = Abi_shapefile[[7]])+ #health_district - 113
  geom_sf(color = "black", fill = 	"#ece9f7")+
  # geom_text_repel(
  #   data = Abi_shapefile[[7]],
  #   aes(label =  NOM, geometry = geometry),color ='black',
  #   stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 113 health districts of Cote d' Ivoire", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_health_district113_CoteDIvoire.pdf'),  width = 8, height =5)

ggplot(data = Abi_shapefile[[8]])+ #health district coarse - 109
  geom_sf(color = "black", fill = 	"#ece9f7")+
  # geom_text_repel(
  #   data = Abi_shapefile[[7]],
  #   aes(label =  NOM, geometry = geometry),color ='black',
  #   stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 109 health district coarse of Cote d' Ivoire", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_health_district109_CoteDIvoire.pdf'),  width = 8, height =5)

ggplot(data = Abi_shapefile[[9]])+ #health regions - 33
  geom_sf(color = "black", fill = 	"#ffd6c2")+
  geom_text_repel(
    data = Abi_shapefile[[9]],
    aes(label =   str_to_sentence(health_region), geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 33 health regions of Cote d' Ivoire", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_health_regions33_CoteDIvoire.pdf'),  width = 8, height =5)


##############################################################################################################################################################
# obtain health districts shapefiles for Abidjan 
###############################################################################################################################################################

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
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_health_districts15_Abidjan.pdf'),  width = 8, height =5)

#get Abidjan health district from the second file 
df_abidjan2 = st_intersection(Abi_shapefile[[8]], Abidjan)
ggplot(data = Abidjan)+
  geom_sf(data = df_abidjan2, color = "black", fill = 	"#ece9f7")+
  geom_text_repel(
    data = df_abidjan2,
    aes(label = str_to_sentence(NOM), geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 13 health districts of Abidjan", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_health_districts13_Abidjan.pdf'),  width = 8, height =5)


##############################################################################################################################################################
# generate map of Abidjan sub-prefecture 
###############################################################################################################################################################
df_abidjan = st_intersection(Abi_shapefile[[5]], Abidjan)
ggplot(data = Abidjan)+
  geom_sf(data = df_abidjan, color = "black", fill = 	"#ece9f7")+
  geom_text_repel(
    data = df_abidjan,
    aes(label = NAME_4, geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(title="All 4 sub-prefectures of Abidjan", 
       fill = "", x = NULL, y = NULL)+
  map_theme()
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_sub_prefectures_Abidjan.pdf'),  width = 6, height =4)


##############################################################################################################################################################
# nets distribution 
####################################################################################################################################################
net_df <- left_join(df_abidjan1, campign_dat, by = c("NOM" = "district_name")) %>%  filter(!is.na(LLINs_distributed)) %>% 
  mutate(name_excess = paste0(str_to_sentence(NOM),", ", excess_LLINs_prop_available ))

p<- ggplot(net_df, aes(x=fct_reorder(str_to_sentence(NOM), LLINs_distributed), y=LLINs_distributed/1000, fill= Type_insecticide)) + 
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_manuscript()+
  scale_fill_manual(values= c( "#a17eac", "#ebadb2")) +
  theme(legend.title = element_blank())+
  labs(x ="", y = "Number of bets nets distributed in Abidjan in 2021 campaign (in thousands)")

p1<-ggplot(net_df, aes(fill= excess_LLINs_prop_available)) +
  geom_sf()+
  scale_fill_gradient(low ="#ffecc6" , high = "#f73b3b") +
  geom_text_repel(
    data = net_df,
    aes(label = name_excess, geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs( fill = "", x = NULL, y = "Left over nets after campaign as a percentage of estimated need")+
  map_theme()

p/p1 + plot_annotation(tag_levels = 'A')
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_nets_distributed_Left_over_2021_Abdijan.pdf'),  width = 8, height =7)
##############################################################################################################################################################
# routine data for Abidjan 
###############################################################################################################################################################
#tpr 
head(routine_dat)
glimpse(routine_dat)
table(routine_dat$health_region)
df <- routine_dat %>%  filter(grepl("ABIDJAN", health_region))


ggplot(df, aes(x=month, y =tpr, color =health_district))+
  geom_point()+
  geom_line()+
  scale_color_brewer(palette = "Paired")+
  facet_wrap(~year)+
  theme_manuscript()+
  theme(legend.position = "bottom")
  
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_TPR_health_districts_Abidjan.pdf'),  width = 11, height =7)


df2 <- df %>%  group_by(month, health_district) %>% 
  summarise(mean(tpr))

ggplot(df2, aes(x=month, y =`mean(tpr)`, color =health_district))+
  geom_point()+
  geom_line()+
  scale_color_brewer(palette = "Paired")+
  theme_manuscript()+
  theme(legend.position = "bottom")
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_TPR_health_districts_Abidjan_all_years.pdf'),  width = 11, height =7)


df3 <- df %>%  filter(year == '2022')

ggplot(df3, aes(x=month, y =tpr, color =health_district))+
  geom_point()+
  geom_line()+
  scale_color_brewer(palette = "Paired")+
  theme_manuscript()+
  theme(legend.position = "bottom")
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_TPR_health_districts_Abidjan_2022.pdf'),  width = 11, height =7)

#incidence
check <- df %>%  dplyr::select(month, incidence_adjusted3, year, health_district) %>% filter(month == 1)
ggplot(check, aes(x=year, y =incidence_adjusted3, color =health_district))+
  geom_point()+
  geom_line()+
  scale_color_brewer(palette = "Paired")+
  theme_manuscript()+
  theme(legend.position = "bottom")
ggsave(paste0(plots, "/", 'Jan_18_2024', "/", Sys.Date(), '_incidence_adjusted_Abidjan_2022.pdf'),  width = 11, height =7)
# 
# abidjan_malaria <- readRDS("~/Abidjan/ts_retro_civ.rds")
# shapefilesCIV <- readRDS("~/shapefilesCIV.rds")
# abidjan_dhs <- readRDS("~/dhs_data.rds")
# View(abidjan_malaria)
# View(shapefilesCIV)
# view(abidjan_dhs)
# 
# library(sf)
# library(ggplot2) 
# library(ggrepel) 
# 
# admin0_shp <- shapefilesCIV[["Admin0_shp"]]
# admin0_sf <- st_as_sf(admin0_shp)
# ggplot() +
#   geom_sf(data = admin0_sf) +
#   theme_minimal()
# 
# admin1_shp <- shapefilesCIV[["Admin1_shp"]]
# admin1_sf <- st_as_sf(admin1_shp)
# ggplot() +
#   geom_sf(data = admin1_shp) +
#   theme_minimal()
# View(admin1_shp)
# 
# admin2_shp <- shapefilesCIV[["Admin2_shp"]]
# admin2_sf <- st_as_sf(admin2_shp)
# ggplot() +
#   geom_sf(data = admin2_shp) +
#   theme_minimal()
# View(admin2_shp)
# #result is 31 regions in 12 districts and 2 districts.
# 
# admin3_shp <- shapefilesCIV[["Admin3_shp"]]
# admin3_sf <- st_as_sf(admin3_shp)
# ggplot() +
#   geom_sf(data = admin3_shp) +
#   theme_minimal()
# View(admin3_shp)
# #result is further broken into departments
# 
# admin4_shp <-shapefilesCIV[["Admin4_shp"]]
# admin4_sf <- st_as_sf(admin4_shp)
# ggplot() +
#   geom_sf(data = admin4_shp) +
#   theme_minimal() +
#   ggtitle("Cote d'Ivoire Sub-perfectures")
# 
# View(admin4_shp)
# #result is further broken into sub-perfectures
# 
# 
# admin4_shp <- shapefilesCIV[["Admin4_shp"]]
# admin4_sf <- st_as_sf(admin4_shp)
# target_district <- "Abidjan"  
# abidjan_data <- admin4_sf[admin4_sf$NAME_1 == target_district, ]
# ggplot() +
#   geom_sf(data = abidjan_data) +
#   theme_minimal() +
#   ggtitle(paste("Abidjan Autonomous District and Sub-perfectures"))
# #result is Abidjan and its sub-perfectures
# 
# facies_shp <- shapefilesCIV[["facies_shp"]]
# facies_sf <- st_as_sf(facies_shp)
# ggplot() +
#   geom_sf(data = facies_shp) +
#   theme_minimal()
# View(facies_shp)
# 
# healthdis_shp <- shapefilesCIV[["health_districts_shp"]]
# healthdis_sf <- st_as_sf(healthdis_shp)
# ggplot() +
#   geom_sf(data = healthdis_shp) +
#   theme_minimal()
# View(healthdis_shp)
# #result is healthdistricts names and shape
# 
# healthdis_shp2 <- shapefilesCIV[["health_districts_coarse_shp"]]
# healthdis_sf2 <- st_as_sf(healthdis_shp2)
# ggplot() +
#   geom_sf(data = healthdis_shp2) +
#   theme_minimal()
# View(healthdis_shp2)
# #result is healthdistricts names and shape
# 
# 
# healthreg_shp <- shapefilesCIV[["health_regions_shp"]]
# healthreg_sf <- st_as_sf(healthreg_shp)
# ggplot() +
#   geom_sf(data = healthreg_shp) +
#   theme_minimal()
# View(healthreg_shp)
# #result is health regions list: only 2 are Abidjan
# 
# healthreg_shp <- shapefilesCIV[["health_regions_shp"]]
# healthreg_sf <- st_as_sf(healthreg_shp)
# regions <- c("ABIDJAN 1", "ABIDJAN 2")
# abidjan_healthmap <- healthreg_sf[healthreg_sf$health_region %in% regions, ]
# ggplot() +
#   geom_sf(data = abidjan_healthmap) +
#   theme_minimal() +
#   ggtitle("Abidjan health regions")
# 
# 
# 
# healthdis_shp <- shapefilesCIV[["health_districts_shp"]]
# healthdis_sf <- st_as_sf(healthdis_shp)
# abidjan_districts <- c("ABOBO EST", "ABOBO OUEST", "ANYAMA", "ADJAME-PLATEAU-ATTECOUBE", "COCODY BINGERVILLE", "KOUMASSI", "PORT BOUET-VRIDI","YOPOUGON-EST", "YOPOUGON-OUEST-SONGON", "TREICHVILLE-MARCORY")
# abj_districts_map<- healthdis_sf[healthdis_sf$NOM %in% abidjan_districts, ]
# View(abj_districts_map)
# 
# map_theme <- function() {
#   theme(axis.text.x = ggplot2::element_blank(),
#         axis.text.y = ggplot2::element_blank(),
#         axis.ticks = ggplot2::element_blank(),
#         rect = ggplot2::element_blank(),
#         plot.background = ggplot2::element_rect(fill = "white", colour = NA), 
#         plot.title = element_text(hjust = 0.5),
#         legend.title.align = 0.5,
#         legend.title = element_text(size = 8, colour = 'black'), 
#         legend.text = element_text(size = 8, colour = 'black'),
#         legend.key.height = unit(0.65, "cm"))
# }
# con_gplot <- function(df) {
#   ggplot() +
#     geom_sf(data = df) +
#     map_theme() +
#     geom_label_repel(
#       data = df,
#       aes(label = NOM, x = st_coordinates(df)$X, y = st_coordinates(df)$Y),
#       box.padding = 0.5, # Adjust as needed
#       point.padding = 0.5, # Adjust as needed
#       min.segment.length = 0,
#       size = 3, # Adjust label size as needed
#       color = 'black',
#       force = 1
#     ) +
#     xlab('') +
#     ylab('')
# }
#   
# con_gplot(abj_districts_map) +
#     ggtitle("Map of Abidjan Health Districts")
#   
# 
# 
# 
# 
# healthdis_shp <- shapefilesCIV[["health_districts_shp"]]
# healthdis_sf <- st_as_sf(healthdis_shp)
# abidjan_districts <- c("ABOBO EST", "ABOBO OUEST", "ANYAMA", "ADJAME-PLATEAU-ATTECOUBE", "COCODY BINGERVILLE", "KOUMASSI", "PORT BOUET-VRIDI","YOPOUGON-EST", "YOPOUGON-OUEST-SONGON", "TREICHVILLE-MARCORY")
# abj_districts_map<- healthdis_sf[healthdis_sf$NOM %in% abidjan_districts, ]
# map_theme <- function() {
#   theme(axis.text.x = ggplot2::element_blank(),
#         axis.text.y = ggplot2::element_blank(),
#         axis.ticks = ggplot2::element_blank(),
#         rect = ggplot2::element_blank(),
#         plot.background = ggplot2::element_rect(fill = "white", colour = NA), 
#         plot.title = element_text(hjust = 0.5),
#         legend.title.align = 0.5,
#         legend.title = element_text(size = 8, colour = 'black'), 
#         legend.text = element_text(size = 8, colour = 'black'),
#         legend.key.height = unit(0.65, "cm"))
# }
# 
# con_gplot <- function(df, label) {
#   ggplot() +
#     geom_sf(data = df) +
#     map_theme() +
#     geom_text_repel(
#       data = df,
#       aes(label = !!label, geometry = geometry),
#       color = 'black',
#       stat = "sf_coordinates", 
#       min.segment.length = 0, size = 1.5, force = 1, max.overlaps = Inf
#     ) +
#     xlab('') +
#     ylab('')
# }
# 
# con_gplot(abj_districts_map, label = "NOM") +
#   ggtitle("Map of Abidjan Health Districts")
#  
# 
# 
# library(dplyr)
# 
# abidjan_oct22 <- abidjan_malaria%>%
#   filter(health_district %in% abidjan_districts, date == '2022-10-01')
# print(abidjan_oct22)
# 
# 
# ggplot(abidjan_oct22, aes(x = health_district, y = tpr)) +
#   geom_bar(stat = "identity", fill = "skyblue") +
#   theme_minimal() +
#   ggtitle("Test Positivity Rate in Abidjan Districts (October 2022)") +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))
# 
# healthdis_shp <- shapefilesCIV[["health_districts_shp"]]
# healthdis_sf <- st_as_sf(healthdis_shp)
# abidjan_districts <- c("ABOBO EST", "ABOBO OUEST", "ANYAMA", "ADJAME-PLATEAU-ATTECOUBE", "COCODY BINGERVILLE", "KOUMASSI", "PORT BOUET-VRIDI","YOPOUGON-EST", "YOPOUGON-OUEST-SONGON", "TREICHVILLE-MARCORY")
# abj_districts_map<- healthdis_sf[healthdis_sf$NOM %in% abidjan_districts, ]
# View(abj_districts_map)
# 
# map <- left_join(abj_districts_map, abidjan_oct22, by = c("NOM"= "health_region"))
# ggplot(map) +
#   geom_sf(aes(fill="tpr")) +
#   theme_minimal()+
#   ggtitle("Map of Abidjan Health Districts and TPR")
# 
# 
# 

rm(list=ls())

source("load_path.R", echo=FALSE) 

#read files function 
read.files <- function(path, general_pattern, specific_pattern, fun) {
  files <- list.files(path = path , pattern = general_pattern, full.names = TRUE, recursive = TRUE)
  files<- files[(grep(specific_pattern, files))]
  sapply(files, fun, simplify = F)
}


options(survey.lonely.psu="adjust") 

# Read in PR and KR data files and rename state variable
pr_files <- read.files(DHS_data, "*CIPR.*\\.DTA", 'CIPR62FL|CIPR81FL', read_dta)
# kr_files <- read.files(dhsdhs, "*NGKR.*\\.DTA", 'NGKR4BFL|NGKR53FL|NGKR61FL|NGKR6AFL|NGKR71FL|NGKR7AFL|NGKR81FL', read_dta)


# pr_files[[5]]$state <- as_label(pr_files[[5]]$shstate)
# pr_files[[6]]$state <- as_label(pr_files[[6]]$shstate)
# pr_files[[7]]$state <- as_label(pr_files[[7]]$hv024)
pr_data <- bind_rows(pr_files)



lapply(pr_files, function(x) table(x$hml32))
lapply(pr_files, function(x) table(x$hv006))


# kr_files[[5]]$state <- as_label(kr_files[[5]]$sstate)
# kr_files[[6]]$state <- as_label(kr_files[[6]]$sstate)
# kr_files[[7]]$state <- as_label(kr_files[[7]]$v024)
# kr_data <- bind_rows(kr_files)


#load spatial points
sf12 = sf::st_read(file.path(DHS_data, "2012_CI", "CIGE61FL", "CIGE61FL.shp"),)

sf21 = sf::st_read(file.path(DHS_data, "2021_CI", "CIGE81FL", "CIGE81FL.shp"),) 


sf_all = rbind(sf12, sf21) %>%  
  rename(cluster = DHSCLUST)



malaria_prev <- pr_data %>%
  filter(hv042 == 1 & hv103 == 1 & hc1 %in% c(6:59) ) %>%
  filter(hml32 <= 1) %>% 
  mutate(malaria = ifelse(hml32 == 1, 1, 0), wt = hv005/1000000, id  = hv021, strat=hv022) %>% 
  srvyr:: as_survey_design(., ids= id,strata=strat,nest=T,weights= wt) %>%
  group_by(cluster = hv001, year = hv007) %>% 
  summarize( prev =round(survey_mean(malaria),2) * 100,
             total_malaria = survey_total(), first_month_survey = as.character(first(hv006))) %>%
  mutate(class= cut(prev,  c(seq(0, 20, 5),30,50, 100), include.lowest = T)) %>% 
  inner_join(sf_all, by = c("year" = "DHSYEAR","cluster" = "cluster" )) %>%
  drop_na(prev)


##############################################################################################################################################################
# obtain health districts shapefiles for Abidjan 
###############################################################################################################################################################
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


#######################################################################################
#plot DHS data on Abidjan file 
##########################################################################################

new_plottingdata <- sf::st_as_sf(malaria_prev, coords = c("LONGNUM", "LATNUM"))

sf::st_crs(new_plottingdata) <- 4326
sf::st_crs(df_abidjan1) <- 4326

sf::st_crs(new_plottingdata) <-  sf::st_crs(df_abidjan1)

new_plotd <- st_intersection(df_abidjan1, new_plottingdata)  %>%  mutate(first_month_survey_char = case_when(
  first_month_survey = "4" ~ "April",
  first_month_survey = "9" ~ "September",
  first_month_survey = "10" ~ "October",
  first_month_survey = "12" ~ "December",
  TRUE ~ as.character(first_month_survey)
))

discrete_palettes <- list(rev(RColorBrewer::brewer.pal(7, "RdYlBu")))

ggplot(data = df_abidjan1) +
  geom_sf(fill = "white", color = "black") +
  geom_sf(data = new_plotd, aes(color = class, geometry =geometry, shape=first_month_survey), size = 3)+
  geom_text_repel(
    data = df_abidjan1,
    aes(label = str_to_sentence(NOM), geometry = geometry),color ='black',
    stat = "sf_coordinates", min.segment.length = 0, size = 3.5, force = 1)+
  labs(subtitle = '', fill = "TPR ", x = "", y = "", color = "") +
  facet_grid(col = vars(year))+
  scale_fill_discrete(drop=FALSE, name="TPR", type = discrete_palettes)+
  scale_color_discrete(drop=FALSE, name="TPR", type = discrete_palettes)+
  map_theme()


ggsave(file.path(result_plots,"dhs_map_with_points.pdf"),
       width = 12, height = 9, dpi = 300)

ggsave(file.path(result_plots,"dhs_map_with_points.png"),
       width = 12, height = 9, dpi = 300)




##############################################LGA#########################
############################## LGA ESTIMATE ##############################
data_PR <- pr_data %>%
  filter(hv042 == 1 & hv103 == 1 & hc1 %in% c(6:59) ) %>%
  filter(hml32 < 6) %>% 
  mutate(malaria = ifelse(hml32 == 1, 1, 0), wt = hv005/1000000, id  = hv021, strat=hv022) %>%
  select(cluster = hv001, year = hv007, malaria, wt, strat=hv022, id=hv021) %>%
  # no LGA column so I added sf_all get LGA 
  inner_join(sf_all, by = c("year" = "DHSYEAR", "cluster" = "cluster" )) %>%
  drop_na(malaria)


data_PR <- sf::st_as_sf(data_PR, coords = c("LONGNUM", "LATNUM"))

sf::st_crs(data_PR) <-  sf::st_crs(ilorin_shapefile)

new_pr_data = st_intersection(data_PR, ilorin_shapefile)

malaria_prev_lga <- new_pr_data %>%
  srvyr:: as_survey_design(., ids= id,strata=strat,nest=T,weights= wt) %>%
  group_by(LGA, year) %>%
  summarize(malaria_prev =round(survey_mean(malaria),2)*100,
            total_malaria = survey_total()) %>%
  mutate(class= cut(malaria_prev,  c(seq(0, 20, 5),30,50, 100), include.lowest = T))

######################################scatter plot##############################

LGA_prev <- malaria_prev_lga %>% 
  select(LGA, year, lga_estimates = malaria_prev )  


cluster_prev <- malaria_prev %>% 
  select(c(year, cluster_estimates = prev ))


state_data <-  data.frame(year = c(2015,2018,2021),
                          state_estimates = c(26.4, 20.2, 5.6))



ggplot() +
  geom_point(data = LGA_prev, aes(x = year, y = lga_estimates, color = "LGA")) +
  geom_point(data = cluster_prev, aes(x = year, y = cluster_estimates *100, color = "Cluster")) +
  geom_point(data = state_data, aes(x = year, y = state_estimates, color = "State")) +
  scale_color_manual(values = c("LGA" = "#2C7BB6", "Cluster" ="#FDAE61", "State" = "#D7191C")) +
  labs(x = "Year", y = "Prevalence", color = "Administration level") +
  theme_manuscript() 

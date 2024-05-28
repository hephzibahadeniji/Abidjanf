#### PRELIMINARY SCORING ALGORITHM

rm(list=ls())
source("~/Abidjan/load_path.R", echo=FALSE)

# colour palettes for the map 
palettes_00 <- list(rev(RColorBrewer::brewer.pal(5, "OrRd")))[[1]][5:1]
palettes <- list(rev(RColorBrewer::brewer.pal(5, "RdYlBu")))

#data files 
scoring_dataset <- read.csv(file.path(AbidjanDir, "Abidjan Data Variables.csv"))


####model permutations with 5 variables
model <- c("avg_tpr_normal_score + mean_WF_normal_score_normal_score",
           "meanEVI2013_23_normal_score + mean_WF_normal_score",
           "Slum_Count_normal_score + mean_WF_normal_score",
           "avg_rainfall_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score",
           "avg_tpr_normal_score + Slum_Count_normal_score",
           "avg_tpr_normal_score + avg_rainfall_normal_score",
           "meanEVI2013_23_normal_score + Slum_Count_normal_score",
           "meanEVI2013_23_normal_score + avg_rainfall_normal_score",
           "Slum_Count_normal_score + avg_rainfall_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + Slum_Count_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "meanEVI2013_23_normal_score + Slum_Count_normal_score + mean_WF_normal_score",
           "meanEVI2013_23_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + avg_rainfall_normal_score",
           "avg_tpr_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score",
           "meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score",
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score")


# variable names 
new_names = c("enhanced vegetation index",
              "slum concentration",
              "rainfall", 
              "test positivity rate",
              "water frequency")

names(new_names) = c("meanEVI2013_23_normal_score",
                     "Slum_Count_normal_score",
                     "avg_rainfall_normal_score", 
                     "avg_tpr_normal_score",
                     "mean_WF_normal_score")



####Assign mean values to cells with NA values (optional)

column_means <- colMeans(scoring_dataset [, -c(1, 2)], na.rm = TRUE)
print(column_means)
for (col in names(scoring_dataset)) {
  if (col %in% names(column_means)) {
    scoring_dataset[[col]] <- ifelse(is.na(scoring_dataset[[col]]), column_means[[col]], scoring_dataset[[col]])
  }
}

# ###reshape non-normalized data for plotting (Optional)
# plotting_data2 <- scoring_dataset %>%
#   dplyr::select(HealthDistrict, 
#                 meanEVI2013_23, 
#                 avg_rainfall,
#                 avg_tpr,
#                 Slum_Count,
#                 mean_WF) %>% 
#   reshape::melt(id.vars = c("HealthDistrict")) %>% 
#   mutate(class = cut(value, seq(0,1, length.out = 6), include.lowest = T)) %>% 
#   inner_join(df_abidjan1, by = c("HealthDistrict" = "NOM"))


# Data normalization, Scoring, and manipulations 

normalize <- function(x) {
  ifelse(is.na(x), NA, (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
}

#Normalize variables
df_normalized <- scoring_dataset %>%
  mutate(
    meanEVI2013_23_normal_score = normalize(meanEVI2013_23),
    avg_rainfall_normal_score = normalize(avg_rainfall),
    avg_tpr_normal_score = normalize(avg_tpr),
    Slum_Count_normal_score = normalize(Slum_Count),
    mean_WF_normal_score = normalize(mean_WF)
  )

# Data selection and model creation
scoring_dataset2 <- df_normalized %>%
  dplyr::select(ID, 
                HealthDistrict, 
                meanEVI2013_23_normal_score,
                avg_rainfall_normal_score,
                avg_tpr_normal_score,
                Slum_Count_normal_score,
                mean_WF_normal_score
                )%>%
  mutate (
  model01 = avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model02 = avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score,
  model03 = meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model04 = avg_tpr_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model05 = avg_tpr_normal_score + meanEVI2013_23_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model06 = avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score + mean_WF_normal_score,
  model07 = meanEVI2013_23_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score,
  model08 = avg_tpr_normal_score + Slum_Count_normal_score + avg_rainfall_normal_score,
  model09 = avg_tpr_normal_score + meanEVI2013_23_normal_score + avg_rainfall_normal_score,
  model10 = avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score,
  model11 = Slum_Count_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model12 = meanEVI2013_23_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model13 = meanEVI2013_23_normal_score + Slum_Count_normal_score + mean_WF_normal_score,
  model14 = avg_tpr_normal_score + avg_rainfall_normal_score + mean_WF_normal_score,
  model15 = avg_tpr_normal_score + Slum_Count_normal_score + mean_WF_normal_score,
  model16 = avg_tpr_normal_score + meanEVI2013_23_normal_score + mean_WF_normal_score,
  model17 = Slum_Count_normal_score + avg_rainfall_normal_score,
  model18 = meanEVI2013_23_normal_score + avg_rainfall_normal_score,
  model19 = meanEVI2013_23_normal_score + Slum_Count_normal_score,
  model20 = avg_tpr_normal_score + avg_rainfall_normal_score,
  model21 = avg_tpr_normal_score + Slum_Count_normal_score,
  model22 = avg_tpr_normal_score + meanEVI2013_23_normal_score,
  model23 = avg_rainfall_normal_score + mean_WF_normal_score,
  model24 = Slum_Count_normal_score + mean_WF_normal_score,
  model25 = meanEVI2013_23_normal_score + mean_WF_normal_score,
  model26 = avg_tpr_normal_score + mean_WF_normal_score
)

# data reshaping 
plotting_scoring_data <- scoring_dataset2 %>%
  dplyr::select(HealthDistrict, 
         meanEVI2013_23_normal_score, 
         avg_rainfall_normal_score,
         avg_tpr_normal_score,
         Slum_Count_normal_score,
         mean_WF_normal_score) %>% 
  reshape::melt(id.vars = c("HealthDistrict")) %>% 
  mutate(class = cut(value, seq(0,1, length.out = 6), include.lowest = T)) %>% 
  inner_join(df_abidjan1, by = c("HealthDistrict" = "NOM"))


plottingdata <- scoring_dataset2 %>% 
  dplyr::select(HealthDistrict, model01:model26 ) %>% 
  reshape2::melt(id.vars = c("HealthDistrict")) %>% 
  inner_join(df_abidjan1, by = c("HealthDistrict" = "NOM")) %>% 
  group_by(variable) %>%
  mutate(new_value = (value - min(value))/(max(value) - min(value)),
         class = cut(new_value, seq(0, 1, 0.2), include.lowest = T)) %>%
  arrange(value) %>%
  mutate(rank = 1:n())


###################PLOTS#####################################################
# - Increasing risk map plots based on normalized variables only
#all <-
ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = plotting_scoring_data, 
          aes(geometry = geometry, fill = class), color = "gray") +
  facet_wrap(~variable, labeller = labeller(variable = new_names)) +  
  scale_fill_discrete(drop=FALSE, name="Class(Increasing risk)", type = palettes_00)+
  labs(title = 'Malaria Risk Map by Normalized Variables', fill = "") +
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()

##continuous legend
ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = plotting_scoring_data, 
          aes(geometry = geometry, fill = value)) +
  facet_wrap(~variable, labeller = labeller(variable = new_names)) +  
  #scale_fill_continuous(drop=FALSE, name="", type = gradient_color("red"))+ edit scale colour
  labs(subtitle = '', fill = "") +
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()

###### ECDF 
###pre normalization
ggplot(data = scoring_dataset, aes(x = meanEVI2013_23))+ ##change variable of interest
  stat_ecdf(geom = "step", color = "brown", linewidth = 1)+
  #facet_wrap(~variable, labeller = labeller(variable = new_names), scales = "free") + 
  labs(title = "EVI Before Normalization",
       x = "")+
  theme_manuscript() +
  theme(panel.border = element_blank())

### post normalization
ggplot(data = plotting_scoring_data, aes(x = value))+
  stat_ecdf(geom = "step", color = "brown", linewidth = 1)+
  facet_wrap(~variable, labeller = labeller(variable = new_names), scales = "free") + 
  labs(title = "After Normalization",
       x = "")+
  theme_manuscript() +
  theme(panel.border = element_blank())


###side by side comparison (pre vs post normalization for each variable)
library(gridExtra)
plot1 <- ggplot(data = scoring_dataset, aes(x = mean_WF))+ ##change variable of interest
  stat_ecdf(geom = "step", color = "brown", linewidth = 1)+
  labs(title = "Water Frequency Before Normalization",
       x = "water frequency")+
  theme_manuscript() +
  theme(panel.border = element_blank())

filtered_data <- plotting_scoring_data %>%
  filter(variable == "mean_WF_normal_score") ##change variable of interest
plot2 <- ggplot(data = filtered_data, aes(x = value))+
  stat_ecdf(geom = "step", color = "brown", linewidth = 1)+
  labs(title = "WF After Normalization",
       x = "normalized WF")+
  theme_manuscript() +
  theme(panel.border = element_blank())

grid.arrange(plot1, plot2, ncol=2)


#########Ranked maps using all models
palettes <- list(RColorBrewer::brewer.pal(5, "YlOrRd"))

# ranking with normalized variables, ranking 2
ggplot(data = df_abidjan1)+
  geom_sf(color = "black", fill = "white")+
  geom_sf(data = plottingdata, aes(geometry = geometry, fill = class))+  #class is NA, when there are NA values
  geom_sf_text(data = plottingdata, aes(geometry = geometry, label =  rank), size = 3 )+ 
  facet_wrap(~variable, labeller = label_parsed, ncol = 3) +
  scale_fill_discrete(drop=FALSE, name="Rank(Increasing Risk)", type = palettes_00)+
  #scale_fill_manual(values = palettes)+
  labs(subtitle='', title='Health District Ranking of Malaria Risks',
       fill = "Rank(Increasing Risk)")+
  theme(panel.background = element_blank(), size = 20)+
  theme_void()+
  map_theme()

###ranking with normalized values- 3
#plot1 <-
  ggplot(data = df_abidjan1)+
  geom_sf(color = "black", fill = "white")+
  geom_sf(data = plottingdata, aes(geometry = geometry, fill = rank))+  #class is NA, when there are NA values
  geom_sf_text(data = plottingdata, aes(geometry = geometry, label =  rank), size = 3 )+ 
  facet_wrap(~variable, labeller = label_parsed, ncol = 5) +
  scale_fill_gradient(low = palettes_00[1], high = palettes_00[length(palettes_00)], 
                      name="Rank(Increasing Risk)")+
  labs(subtitle='', title='Health District Ranking of Malaria Risks',
       fill = "Rank(Increasing Risk)")+
  theme(panel.background = element_blank(), 
        plot.title = element_text(size = 20, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) +
  #theme(panel.background = element_blank(), size = 20)+
  theme_void()+
  map_theme()


##health district ranking, model
plottingdata_filtered <- plottingdata %>%
  filter(variable == "model01")
ggplot()+
  geom_sf(data = plottingdata_filtered, aes(geometry =geometry, fill =rank))+
  geom_text_repel(data =plottingdata_filtered, 
                  aes(label=rank, geometry=geometry), color ='black',
                  stat = "sf_coordinates", min.segment.length = 0, size = 3, force = 1)+
  # geom_text_repel(data =df_abidjan1, 
  #                 aes(label=str_to_sentence(NOM), geometry=geometry), color ='black',
  #                 stat = "sf_coordinates", min.segment.length = 0, size = 3, force = 1)+
  scale_fill_gradient(low = palettes_00[1], high = palettes_00[length(palettes_00)], 
                      name="Rank(Increasing Risk)")+
  labs(title = "Malaria Risk Map in Abidjan", fill = "Rank(Increasing Risk)")+
  theme(panel.background = element_blank(), 
        plot.title = element_text(size = 20, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) +
  theme_void()+
  map_theme()
  


######################## VARIABLE MODEL MAPS
###MAPS with NA values (no extrapolation), remember to run first, when mean hasn't been calculated
##non normalized
plot1 <- ggplot()+
  geom_sf(data = plotting_data2, aes(geometry=geometry, fill =class), color = "gray")+
  facet_wrap(~variable, labeller = labeller(variable = new_names))+
  scale_fill_discrete(drop = FALSE, name = "Class(Increased values)", type = palettes_00)+
  labs(title = "Malaria risk with non-normalized variables", fill = "")+
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()

## normalized variables
plot2 <- ggplot()+
  geom_sf(data = plotting_scoring_data, aes(geometry=geometry, fill=class), color = "gray")+
  facet_wrap(~variable, labeller = labeller(variable = new_names))+
  scale_fill_discrete(drop = FALSE, name = "Class(Increased values)", type = palettes_00)+
  labs(title = "Malaria risk with normalized variables", fill = "")+
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()


#### with extrapolated values
#non-normalized
plot3 <- ggplot()+
  geom_sf(data = plotting_data2, aes(geometry=geometry, fill =class), color = "gray")+
  facet_wrap(~variable, labeller = labeller(variable = new_names))+
  scale_fill_discrete(drop = FALSE, name = "Class(Increased values)", type = palettes_00)+
  labs(title = "Malaria risk with non-normalized variables + imputed mean", fill = "")+
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()
  

#normalized
plot4 <- ggplot()+
  geom_sf(data = plotting_scoring_data, aes(geometry=geometry, fill=class), color = "gray")+
  facet_wrap(~variable, labeller = labeller(variable = new_names))+
  scale_fill_discrete(drop = FALSE, name = "Class(Increased risk)", type = palettes_00)+
  labs(title = "Malaria risk with normalized variables + imputed mean", fill = "")+
  theme(panel.background = element_blank(), size = 20) +
  theme_void()+
  map_theme()

grid.arrange(plot1, plot2, plot4, ncol=2) 
  
  
  
  













#####doesn't work
ggplot(data = df_abidjan1)+
  geom_sf(color = "black", fill = "white")+
  geom_sf(data = plottingdata, aes(geometry = geometry, fill = rank))+  #class is NA, when there are NA values
  geom_text(data = plottingdata, aes(geometry = geometry, label =  rank), 
            size = 3, color = "black", fontface = "bold")+ 
  facet_wrap(~variable, labeller = label_parsed, ncol = 3) +
  scale_fill_gradient(low = "lightyellow", high = "maroon", 
                      name = "Rank", na.value = "grey80") +
  #scale_fill_discrete(drop=FALSE, name="Rank(Increasing Risk)", type = palettes_00)+
  #scale_fill_manual(values = palettes)+
  labs(subtitle='', 
       title='Health District Ranking of Malaria Risks',
       fill = "Rank(Increasing Risk)")+
  theme(panel.background = element_blank(), 
        plot.title = element_text(size = 20, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) +
  #theme(panel.background = element_blank(), size = 20)+
  #theme_void()+
  map_theme()
  
  
  







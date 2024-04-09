#### PRELIMINARY SCORING ALGORITHM

rm(list=ls())

source("~/Abidjan/load_path.R", echo=FALSE)

# colour palettes for the map 
palettes_00 <- list(rev(RColorBrewer::brewer.pal(5, "OrRd")))[[1]][5:1]
palettes <- list(rev(RColorBrewer::brewer.pal(5, "RdYlBu")))

#data files 
scoring_dataset <- read.csv(file.path(AbidjanDir, "Abidjan Data Variables.csv"))

# model permutations
model <- c("avg_tpr_normal_score + Slum_Count_normal_score", 
           "restructured_ds + Slum_Count_normal_score", 
           "meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "avg_tpr_normal_score + restructured_ds + Slum_Count_normal_score", 
           "avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "avg_tpr_normal_score + restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "avg_tpr_normal_score + 0.5 * restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "avg_tpr_normal_score + restructured_ds + 0.5 * meanEVI2013_23_normal_score + Slum_Count_normal_score", 
           "avg_tpr_normal_score + 0.5 * restructured_ds + 0.5 * meanEVI2013_23_normal_score + Slum_Count_normal_score")


# variable names 
new_names = c("enhanced vegetation index",
              "slum concentration",
              "rainfall", 
              "test positivity rate" )

names(new_names) = c("meanEVI2013_23_normal_score",
                     "Slum_Count_normal_score",
                     "normal_score_avgrain", 
                     "avg_tpr_normal_score")


# Data normalization, Scoring, and manipulations  

scoring_data <- scoring_dataset %>% 
  #mutate_if(is.numeric, list(normalized_value = ~ifelse(is.na(.), NA, (. - min(., na.rm = TRUE)) / (max(., na.rm = TRUE) - min(., na.rm = TRUE)))))
  mutate(meanEVI2013_23_normal_score = (meanEVI2013_23 - min(meanEVI2013_23 ))/(max(meanEVI2013_23 ) - min(meanEVI2013_23 )),
         Slum_Count_normal_score = (Slum_Count - min(Slum_Count))/
           (max(Slum_Count) - min(Slum_Count)),
         normal_score_avgrain = (avg_rainfall - min(avg_rainfall ))/(max(avg_rainfall ) - min(avg_rainfall)),
        # normal_score_dwater = (min(distance) - distance)/(max(distance) - min(distance)),
         avg_tpr_normal_score = (avg_tpr - min(avg_tpr))/(max(avg_tpr) - min(avg_tpr))
  ) #%>% 
  #mutate(restructured_ds = (normal_score_dwater - min(normal_score_dwater))/(max(normal_score_dwater) - min(normal_score_dwater)))


df_normalized <- scoring_dataset %>%
  mutate_if(is.numeric, list(normal_score = ~ifelse(is.na(.), NA, (. - min(., na.rm = TRUE)) / (max(., na.rm = TRUE) - min(., na.rm = TRUE)))))
print(df_normalized)

scoring_data_zet <- df_normalized %>%
  select(HealthDistrict, 
         meanEVI2013_23_normal_score,
         Slum_Count_normal_score,
         avg_tpr_normal_score,
         avg_rainfall_normal_score,
         #restructured_ds,
         ) %>% 
  mutate(
    model01 = avg_tpr_normal_score + Slum_Count_normal_score,
    #model02 = restructured_ds + Slum_Count_normal_score,
    model03 = meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model04 = avg_tpr_normal_score + restructured_ds + Slum_Count_normal_score,
    model05 = avg_tpr_normal_score + meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model06 = restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model07 = avg_tpr_normal_score + restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model08 = avg_tpr_normal_score + 0.5 * restructured_ds + meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model09 = avg_tpr_normal_score + restructured_ds + 0.5 * meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model10 = avg_tpr_normal_score + 0.5 * restructured_ds + 0.5 * meanEVI2013_23_normal_score + Slum_Count_normal_score,
    #model11 = avg_tpr_normal_score + meanEVI2013_23_normal_score +  restructured_ds,
    #model12 = avg_tpr_normal_score +  restructured_ds,
    model13 = avg_tpr_normal_score + meanEVI2013_23_normal_score,
    #model14 =  meanEVI2013_23_normal_score +  restructured_ds,
  )


# data reshaping 
plotting_scoring_data <- scoring_data_zet %>%
  select(HealthDistrict, 
         meanEVI2013_23_normal_score, 
         Slum_Count_normal_score, 
         avg_rainfall_normal_score,
         avg_tpr_normal_score) %>% 
  reshape::melt(id.vars = c("HealthDistrict")) %>% 
  mutate(class = cut(value, seq(0,1, length.out = 6), include.lowest = T)) %>% 
  inner_join(df_abidjan1, by = c("HealthDistrict" = "NOM"))

##

plottingdata <- scoring_data_zet %>% 
  select(HealthDistrict, model01:model13 ) %>% # 
  #  model01, model02,  model03, model04,  model05, model06, model07, model08, model09, model10
  reshape2::melt(id.vars = c("HealthDistrict")) %>% 
  inner_join(df_abidjan1, by = c("HealthDistrict" = "NOM")) %>% 
  group_by(variable) %>%
  mutate(new_value = (value - min(value))/(max(value) - min(value)),
         class = cut(new_value, seq(0, 1, 0.2), include.lowest = T)) %>%
  arrange(value) %>%
  mutate(rank = 1:n())

# df <- left_join(df_abidjan1,scoring_data_zet) %>%  arrange(model03) %>%  mutate(rank = 1:n())
# ggplot()+
#   geom_sf(data = df, aes(geometry = geometry, fill = model03))+
#   geom_sf_text(data =df, aes(geometry = geometry, label =  rank), 
#                size = 3 )+ 
#   scale_fill_distiller(palette = "RdYlBu")+
#   labs(subtitle='', 
#        title='',
#        fill = "ranking score")+
#   theme(panel.background = element_blank(), size = 20)+
#   theme_void()

# - map plot for normalized variables 
all=ggplot(data = df_abidjan1) +
  geom_sf(color = "black", fill = "white") +
  geom_sf(data = plotting_scoring_data, 
          aes(geometry = geometry, fill = class), color = "gray") +
  facet_wrap(~variable, labeller = labeller(variable = new_names)) +  
  scale_fill_discrete(drop=FALSE, name="", type = palettes_00)+
  labs(subtitle = '', fill = "") +
  theme(panel.background = element_blank(), size = 20) +
  theme_void()

ggsave(paste0(plots, "/", Sys.Date(), '_normalized_variables.pdf'), all, width =10, height =6)






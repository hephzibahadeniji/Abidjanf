############LANDCOVER

source("load_path.R", echo=FALSE) 
#source ("C:/Users/hp/Abidjan/load_path.R", echo = FALSE) #leave commented

#install necessary packages

#install.packages("rgdal")
#library(rgdal)
install.packages("hdf5r") 
library(hdf5r) 
install.packages ("terra")
library("terra")
library(dplyr)

LandcoverDir <- file.path(Earthdata, "MODIS-TERRA_LandCoverType_Yearly_Global_500m_2013-2023")


landcover_files  = list.files( file.path(LandcoverDir), 
                               pattern = ".hdf", full.names = TRUE)


# Read the files

raster_data10  = lapply(seq_along(landcover_files), 
                        function(x) rast(landcover_files[x]))
# compute mode
compute_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

landcover_mode <- raster_data10 %>%
  purrr::map(~raster::extract(., df_abidjan1, fun = compute_mode))


##################  Dictionary###################################################
#### Rename column headings
new_column_names <- c("HealthDistrict", "IGBP Classification", "UMD Classification", 
                      "LAI Classification", "BGC Classification", "PFT Classification", 
                      "LCCS1 Layer confidence", "LCCS2 Layer confidence", 
                      "LCCS3 Layer confidence", "LCCS1 land cover layer", "LCCS2 land use layer",
                      "LCCS3 surface hydrology layer", "Quality", "Land/Water Mask")

#landcover_mode <- lapply(landcover_mode, function(df) {
 # names(df) <- new_column_names
  #return(df)
#})

# cell Value translations
translation_list <- list(
  `IGBP Classification` = c("1" = "Evergreen Needleleaf Forests", "2" = "Evergreen Broadleaf Forests", "3" = "Deciduous Needleleaf Forests", "4" = "Deciduous Broadleaf Forests", "5" = "Mixed Forests", "6" = "Closed Shrublands", "7" = "Open Shrublands", "8" = "Woody Savannas", "9" = "Savannas", "10" = "Grasslands", "11" = "Permanent Wetlands", "12" = "Croplands", "13" = "Urban and Built-up Lands", "14" = "Cropland/Natural Vegetation Mosaics", "15" = "Permanent Snow and Ice", "16" = "Barren", "17" = "Water Bodies", "255" = "Unclassified"),
  `UMD Classification` = c("0" = "Water Bodies", "1" = "Evergreen Needleleaf Forests", "2" = "Evergreen Broadleaf Forests", "3" = "Deciduous Needleleaf Forests", "4" = "Deciduous Broadleaf Forests", "5" = "Mixed Forests", "6" = "Closed Shrublands", "7" = "Open Shrublands", "8" = "Woody Savannas", "9" = "Savannas", "10" = "Grasslands", "11" = "Permanent Wetlands", "12" = "Croplands", "13" = "Urban and Built-up Lands", "14" = "Cropland/Natural Vegetation Mosaics", "15" = "Non-Vegetated Lands", "255" = "Unclassified"),
  `LAI Classification` = c("0" = "Water Bodies", "1" = "Grasslands", "2" = "Shrublands", "3" = "Broadleaf Croplands", "4" = "Savannas", "5" = "Evergreen Broadleaf Forests", "6" = "Deciduous Broadleaf Forests", "7" = "Evergreen Needleleaf Forests", "8" = "Deciduous Needleleaf Forests", "9" = "Non-Vegetated Lands", "10" = "Urban and Built-up Lands", "255" = "Unclassified"),
  `BGC Classification` = c("0" = "Water Bodies", "1" = "Evergreen Needleleaf Vegetation", "2" = "Evergreen Broadleaf Vegetation", "3" = "Deciduous Needleleaf Vegetation", "4" = "Deciduous Broadleaf Vegetation", "5" = "Annual Broadleaf Vegetation", "6" = "Annual Grass Vegetation", "7" = "Non-Vegetated Lands", "8" = "Urban and Built-up Lands", "255" = "Unclassified"),
  `PFT Classification` = c("0" = "Water Bodies", "1" = "Evergreen Needleleaf Trees", "2" = "Evergreen Broadleaf Trees", "3" = "Deciduous Needleleaf Trees", "4" = "Deciduous Broadleaf Trees", "5" = "Shrub", "6" = "Grass", "7" = "Cereal Croplands", "8" = "Broadleaf Croplands", "9" = "Urban and Built-up Lands", "10" = "Permanent Snow and Ice", "11" = "Barren", "255" = "Unclassified"),
  `LCCS1 land cover layer` = c("1" = "Barren", "2" = "Permanent Snow and Ice", "3" = "Water Bodies", "11" = "Evergreen Needleleaf Forests", "12" = "Evergreen Broadleaf Forests", "13" = "Deciduous Needleleaf Forests", "14" = "Deciduous Broadleaf Forests", "15" = "Mixed Broadleaf/Needleleaf Forests", "16" = "Mixed Broadleaf Evergreen/Deciduous Forests", "21" = "Open Forests", "22" = "Sparse Forests", "31" = "Dense Herbaceous", "32" = "Sparse Herbaceous", "41" = "Dense Shrublands", "42" = "Shrubland/Grassland Mosaics", "43" = "Sparse Shrublands", "255" = "Unclassified"),
  `LCCS2 land use layer` = c("1" = "Barren", "2" = "Permanent Snow and Ice", "3" = "Water Bodies", "9" = "Urban and Built-up Lands", "10" = "Dense Forests", "20" = "Open Forests", "25" = "Forest/Cropland Mosaics", "30" = "Natural Herbaceous", "35" = "Natural Herbaceous/Croplands Mosaics", "36" = "Herbaceous Croplands", "40" = "Shrublands", "255" = "Unclassified"),
  `LCCS3 surface hydrology layer` = c("1" = "Barren", "2" = "Permanent Snow and Ice", "3" = "Water Bodies", "10" = "Dense Forests", "20" = "Open Forests", "27" = "Woody Wetlands", "30" = "Grasslands", "40" = "Shrublands", "50" = "Herbaceous Wetlands", "51" = "Tundra", "255" = "Unclassified"),
  `Land/Water Mask`= c("1" = "Water", "2" = "Land"),
  `Quality` = c("0" = "Classified land", "1" = "Unclassified land", "2" = "Classified water", "3" = "Unclassified water", "4" = "Classified sea ice", "5" = "Misclassified water", "6" = "Omitted snow/ice", "7" = "Misclassified snow/ice", "8" = "Backfilled label", "9" = "Forest type changed", "10" = "No data")
)



# Rename columns in each dataframe
landcover_mode <- purrr::map(landcover_mode, ~ {
  names(.x) <- new_column_names
  .x
})

# Apply translations to each dataframe
landcover_mode <- purrr::map(landcover_mode, ~ {
  purrr::modify_at(.x, intersect(names(.x), names(translation_list)), ~ {
    ifelse(is.numeric(.x), translation_list[[.y]][as.character(.x)], .x)
  })
})



landcover_mode <- lapply(landcover_mode, function(df) {
  for (col_name in names(df)) {
    if (col_name %in% names(translation_list)) {
      df[[col_name]] <- ifelse(is.numeric(df[[col_name]]), 
                               translation_list[[col_name]][as.character(df[[col_name]])],
                               df[[col_name]])
    }
  }
  return(df)
})

##### see yearly information
landcover_2013 <- landcover_mode[[1]]
landcover_2014 <- landcover_mode[[2]]
landcover_2015 <- landcover_mode[[3]]
landcover_2016 <- landcover_mode[[4]]
landcover_2017 <- landcover_mode[[5]]
landcover_2018 <- landcover_mode[[6]]
landcover_2019 <- landcover_mode[[7]]
landcover_2020 <- landcover_mode[[8]]
landcover_2021 <- landcover_mode[[9]]
landcover_2022 <- landcover_mode[[10]]

all.equal(landcover_2014, landcover_2015) #landcover_2016, landcover_2017, landcover_2018, landcover_2019, landcover_2020, landcover_2021, landcover_2022)





############LANDCOVER

#source("load_path.R", echo=FALSE) 
source ("C:/Users/hp/Abidjan/load_path.R", echo = FALSE) #leave commented


install.packages("hdf5r") 
library(hdf5r) 

LandcoverDir <- file.path(Earthdata, "MODIS-TERRA_LandCoverType_Yearly_Global_500m_2013-2023")


data_2023 <- h5read(Landcover, "MCD12Q1.A2022001.h17v08.061.2023244152908.hdf")
landcover_2023 <- raster(data_2023)

####### Process list
hdf_files <- list.files(LandcoverDir, pattern = "\\.hdf$", full.names = TRUE)

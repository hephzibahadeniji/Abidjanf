# R Codebase for Abidjan Settlement Project

## Overview
Welcome to the `README.md` for the R codebase of the Abidjan urban malaria microstratification project. This sub-repository hosts a collection of R scripts to analyse settlement types, real estate dynamics, environmental factors, and spatial characteristics contributing to malaria in Abidjan. Our analyses leverage data on real estate, NASA-derived environmental indices like the Enhanced Vegetation Index (EVI) and rainfall, as well as raster-based spatial analyses. Additionally, we perform exploratory analyses focusing on the relationships between settlements, administrative boundaries, and road infrastructure.

## Overview of Scripts
Here's a concise guide to each script included in this codebase and their respective functionalities:

### 1. General data
- **Script Name:** `00-exploratory_analysis.R`
-  **Purpose:** Views administrative boundaries of Abidjan and analyses general malaria-related metrics in Abidjan e.g. test positivity rate.

## 2. NASA Environmental Variables Analysis
- **Script Name:** `01-NASA_EVI.R`
  - **Purpose:** Analyzes Enhanced Vegetation Index (EVI) and Normalized Difference Vegetation Index (NDVI) data to evaluate vegetation cover across different areas and its temporal changes.

 ### 3. Boundaries and Roads
- **Script Name:** `02-boundaries_roads.R`
- **Purpose:** Explores administrative boundaries and road networks in Abidjan.

### 4. Landcover
- **Script Name:** `03-landcover.R
- **Purpose:** Employs raster data for comprehensive environmental assessments of Abidjan health districts, focusing on land use and land cover classifications, topography  and hydrological features.
  
### 5. Population Size and density
- **Script Name:** `04-pop_denisty_and_size.R`
- **Purpose:** ...

### 6. Waterbodies
- **Script Name:** `05-waterbodies.R
- **Purpose:** ...

### 7. Demographic and Health Survey
- **Script Name:** `06-dhs_clusters.R`
- **Purpose:** ...

### 8. Malaria risk model
- **Script Name:** `07-scoring_algorithm.R`
- **Purpose:** Normalizes values retrieved from previous analyses to model malaria risks then score and rank health districts.

### 9. Housing Structure
Contains scripts that explore possible layout and housing structure in the Abidjan
a)**Script Name:** `00-real_estate.R`
- **Purpose:**  Investigates trends in the real estate market, including property prices, types, and their distribution across Abidjan. The script aims to correlate these trends with the types of settlements identified.
  
b)- **Script Name:** `01-settlements_types_areas.R`
- **Purpose:** Classifies and quantifies different types of buildings and slum settlements in the city

### 10. Rainfall
Contains scripts that explore precipitation in Abidjan
a) **Script Name:** `01-NASA_Rainfall.R`
- **Purpose:** Classifies and quantifies different types of settlements in Abidjan using satellite imagery and geospatial data analysis techniques.
  
b) **Script Name:** `02-NASA_Rainfall_02.R`
- **Purpose:** Extracts daily rainfall and flood frequency data from NASA-provided raster files and analyses rainfall patterns in various settlements.


## Getting Started
Ensure you have R and RStudio installed on your machine.
This codebase requires several R packages such as `sf`, `raster`, `ggplot2`, `dplyr`, and `rgdal`. The specific packages and datasets used are detailed within the script's documentation.

### Installation of Required Packages
You can install the required R packages using the following command in RStudio or R console:
```R
install.packages(c("sf", "raster", "ggplot2", "dplyr", "rgdal"))
```

### Running the Scripts
Open the desired script in RStudio and run it. Alternatively, you can run it from the R console with:

```R
source("Path/to/Your/Script.R")
```

## Contributions
Contributions to enhance the codebase are welcomed. Feel free to fork the repository, make your changes, and submit a pull request with a detailed description of your contributions.

## License
This project is released under the MIT License. See the LICENSE file in the repository for more details.

## Acknowledgments
Our gratitude goes out to NASA and other organizations for making environmental data accessible for research purposes.

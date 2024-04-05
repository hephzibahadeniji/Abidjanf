# Abidjan Settlements Analysis Codebase 

Welcome to the README for the R version of the Abidjan Settlements Analysis Codebase. This repository hosts a collection of R scripts aimed at analyzing settlement types, real estate dynamics, environmental factors, and spatial characteristics within Abidjan. Our analyses leverage data on real estate, NASA-derived environmental indices like the Enhanced Vegetation Index (EVI) and rainfall, as well as raster-based spatial analyses. Additionally, we perform exploratory analyses focusing on the relationships between settlements, administrative boundaries, and road infrastructure.

## Overview of Scripts

Here's a concise guide to each script included in this codebase and their respective functionalities:

### 1. Settlements Types and Areas in Abidjan
- **Script Name:** `Settlements_Types_and_Areas.R`
- **Purpose:** Classifies and quantifies different types of settlements in Abidjan using satellite imagery and geospatial data analysis techniques.

### 2. Real Estate Analysis
- **Script Name:** `real_estate.R`
- **Purpose:** Investigates trends in the real estate market, including property prices, types, and their distribution across Abidjan. The script aims to correlate these trends with types of settlements identified.

### 3. NASA Environmental Variables Analysis
- **Scripts:**
  - **EVI Analysis:** `NASA_EVI.R`
    - Analyzes Enhanced Vegetation Index (EVI) data to evaluate vegetation cover across different areas and its temporal changes.
  - **Monthly Rainfall Analysis:** `NASA_Rainfall.R`
    - Studies monthly rainfall patterns using NASA data to understand their effects on various settlements.


### 4. Raster Analysis for Environmental Assessment
- **Script Name:** `NASA_raster_analysis.R`
- **Purpose:** Employs raster data for comprehensive environmental assessments around settlements, focusing on land use, cover, and hydrological features.

### 5. Exploratory Analysis of Boundaries and Roads
- **Script Name:** `Exploratory_analysis_boundaries_and_roads.R`
- **Purpose:** Explores how administrative boundaries and road networks affect settlement development and classifications in Abidjan.

## Getting Started

Ensure you have R and RStudio installed on your machine. This codebase requires several R packages such as `sf`, `raster`, `ggplot2`, `dplyr`, and `rgdal`. The specific datasets used are detailed within each script's documentation.

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

## Contributing

Contributions to enhance the codebase are welcomed. Feel free to fork the repository, make your changes, and submit a pull request with a detailed description of your contributions.

## License

This project is released under the MIT License. See the LICENSE file in the repository for more details.

## Acknowledgments

Our gratitude goes out to NASA and other organizations for making environmental data accessible for research purposes.


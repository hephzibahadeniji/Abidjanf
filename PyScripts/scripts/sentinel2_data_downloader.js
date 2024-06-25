// Declare the areas of inerest (AOI) by providing the path to its shapfiles. 
var aoi = ee.FeatureCollection("projects/ee-ldjeutchouang/assets/aoi");

//=====================================================================//
//    Define a function to mask the cloud using Sentinel-2 QA band     //
//=====================================================================//
function maskS2clouds(image) {
  /**
    * Function to mask clouds using the Sentinel-2 QA band
    * @param {ee.Image} image Sentinel-2 image
    * @return {ee.Image} cloud masked Sentinel-2 image
  **/
  var qa = image.select('QA60');

  // Bits 10 and 11 are clouds and cirrus, respectively.
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  return image.updateMask(mask).divide(10000);
}

//=============================================//
//    Change the required parameters here      //
//=============================================//
var dataset = ee.ImageCollection('COPERNICUS/S2')
                .filterDate('2022-01-01', '2022-02-28')
                // Pre-filter to get less cloudy granules.
                .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 5)).filterBounds(aoi)
                .map(maskS2clouds)
                .map(function(image) {return image.clip(aoi)});

// Print the content of the dataset                
print(dataset)

// Select the required bands
var required_bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12']

// Take the median of the time series images - see filter dates
dataset = dataset.median().select(required_bands)

// Print the content of the processed dataset  
print(dataset)

// Set visualization parameters 
var visualization = {
  min: 0.0,
  max: 0.3,
  bands: ['B4', 'B3', 'B2'],
};

// Set the visualization of layer to the map
Map.centerObject(aoi, 9);
Map.addLayer(dataset, visualization, 'RGB');


// Export the downloaded image data to Drive at HR (10m)
Export.image.toDrive({
  image: dataset,
  description: 'S2_2023-01-01_2023-03-31',
  region: aoi,
  scale: 10,
});


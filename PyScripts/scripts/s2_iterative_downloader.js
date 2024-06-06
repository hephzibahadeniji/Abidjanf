// Declare the areas of inerest (AOI) by providing the path to its shapfiles. 
// var aoi = ee.FeatureCollection("projects/ee-ldjeutchouang/assets/aoi");

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
  var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                  .filterDate('2022-09-01', '2023-01-31')
                  // Pre-filter to get less cloudy granules.
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 50))
                  .filterBounds(aoi)
                  .sort('system:time_start')
                  .map(maskS2clouds)
                  .map(function(image) {return image.clip(aoi)});
  
  // Select the required bands
  var required_bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12']
  
  // Take the median of the time series images - see filter dates
  median_dataset = collection.median().select(required_bands)
  
  
  // Set visualization parameters 
  var visualization = {
    min: 0.0,
    max: 0.3,
    bands: ['B4', 'B3', 'B2'],
  };
  
  // Set the visualization of layer to the map
  Map.centerObject(aoi);
  Map.addLayer(median_dataset, visualization, 'RGB');
  
  
  // Export the downloaded image data to Drive at HR (10m)
  Export.image.toDrive({
    image: median_dataset,
    description: 'S2_ibadan_2022-09-01_2022-12-31',
    region: aoi,
    scale: 10,
  });

// Iterate over collection
var S2_list = collection.toList(collection.size());
var l = collection.size().getInfo();

for (var i = 0; i < l; i++) {
  var image = ee.Image(S2_list.get(i));
  var acquisitionDate1 = image.date().format('YYYY-MM-dd');

  var filename = ee.String('S2_').cat(acquisitionDate1);
  var imageToDownload = image.select(bands).toUint16();
  var bounds = imageToDownload.geometry().bounds();

  // Continue;
  Export.image.toDrive({
    image: imageToDownload,
    description: filename.getInfo(),
    folder: 'S2-Series', // Specify the folder in your Google Drive
    scale: 10, // Adjust the scale if needed
    maxPixels: 1e13,
    region: bounds,
    crs: 'EPSG:4326' // Adjust the CRS if needed
  });
};
  
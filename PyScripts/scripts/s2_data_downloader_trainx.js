var aoi = ee.FeatureCollection("projects/ee-ldjeutchouang/assets/train_aoi_wd");
/**
 * Function to mask clouds using the Sentinel-2 QA band
 * @param {ee.Image} image Sentinel-2 image
 * @return {ee.Image} cloud masked Sentinel-2 image
 */
function maskS2clouds(image) {
  var qa = image.select('QA60');

  // Bits 10 and 11 are clouds and cirrus, respectively.
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  return image.updateMask(mask).divide(10000);
}

var dataset = ee.ImageCollection('COPERNICUS/S2_SR')
                  .filterDate('2022-09-01', '2022-12-31')
                  // Pre-filter to get less cloudy granules.
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE',20))
                  .filterBounds(aoi)
                  .map(maskS2clouds)
                  .map(function (img) {return img.clip(aoi)})

// Print the content of the dataset                
print(dataset)

// Select the required bands
var required_bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12']

// Take the median of the time series images - see filter dates
dataset = dataset.median().select(required_bands)

// Print the content of the processed dataset  
print(dataset)

var visualization = {
  min: 0.0,
  max: 0.3,
  bands: ['B4', 'B3', 'B2'],
};

Map.centerObject(aoi)

Map.addLayer(dataset, visualization, 'RGB');

//export map
Export.image.toDrive({
  image: dataset,
  description: 'trainx_2023-01-01_2023-03-31',
  region: aoi,
  scale:10,
})

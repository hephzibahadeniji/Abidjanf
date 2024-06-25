<h1>
    <center>
        Deliverable I
    </center>
</h1>

<h2>
    <center>
        Sentinel-2A Images Acquisition & Preprocessing S2 
    </center>
</h2>


## Overview 

To process Sentinel-2A images, including reading data from a .tiff file, resizing the image, creating tiles or patches, and saving the preprocessed data to disk, you can follow these steps:

Reading Sentinel-2A Image: Use rasterio to read the multi-band Sentinel-2A image.
Preprocessing:
Resizing: Resize the image to a specified width and height using opencv.
Creating Patches: Split the image into smaller tiles or patches.
Saving Preprocessed Data: Save the resized image and patches to disk for further modeling.
Here is a detailed Python script to achieve these tasks:

## Step-by-Step Explanation of the Script

1. **Install Necessary Libraries**

Make sure you have the necessary libraries installed:
```batch
pip install rasterio opencv-python scikit-image numpy pandas matplotlib
```

2. **Reading the Sentinel-2A Image:**

The read_sentinel_image function reads the multi-band Sentinel-2A image from a .tiff file using rasterio. It returns the image data and its metadata.

3. **Resizing the Image:**

The resize_image function uses OpenCV to resize the image to the specified dimensions (target_height and target_width). The image is reshaped to (height, width, channels) format for resizing and then reshaped back to (bands, height, width) format.

4. **Creating Patches:**

The create_patches function splits the resized image into smaller patches of size patch_size x patch_size. It ensures patches are only created if they match the specified patch size.

5. **Saving the Image:**

The save_image function saves the image to a .tiff file using rasterio. It updates the metadata with the new image dimensions.

6. **Saving the Patches:**

The save_patches function saves each patch as a .tiff file in the specified output directory. It uses the save_image function for each patch.

## Example Usage

The runflow is as follows:
* file_path: Path to the Sentinel-2A image file.
* target_height, target_width: Dimensions to resize the image.
* patch_size: Size of each patch.
* output_dir: Directory to save the patches.

This script will read a Sentinel-2A image, resize it, create patches, and save both the resized image and the patches to disk for further modeling.
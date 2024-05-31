
############### Import Required Packages #############

import sys
sys.path.insert(0, "../scripts")

import numpy as np
import rasterio as rio
from skimage import exposure
import matplotlib.pyplot as plt
import spectral_indix_tools as spt

############### Data Access ###############

##### Raster file loader
def load_raster(input_file: str):
    """
    Returns a raster array which consists of its bands and
    transformation matrix parameters
    ----------
        input_file: str
            path directory to the raster file
    """
    with rio.open(input_file) as src:
        band = src.read()
        transform = src.transform
        crs = src.crs
        shape = src.shape
        profile = src.profile
        raster_img = np.rollaxis(band, 0, 1)

        output = {"band": band,
                  "raster_img": raster_img,
                  "transform": transform,
                  "crs": crs,
                  "shape": shape,
                  "profile": profile}

        return output

##### Raster file writer
def write_raster(raster, crs, transform, output_file):
    """
    Writes a raster array which consists of one band to the disc.
    ----------
        raster:
            raster array
        transform: 
            transformation matrix parameters
        output_file: str
            path directory to write the raster file
    """
    profile = {"driver": "GTiff",
               "compress": "lzw",
               "width": raster.shape[0],
               "height": raster.shape[1],
               "crs": crs,
               "transform": transform,
               "dtype": raster.dtype,
               "count": 1,
               "tiled": False,
               "interleave": 'band',
               "nodata": 0}

    profile.update(dtype=raster.dtype,
                   height=raster.shape[0],
                   width=raster.shape[1],
                   nodata=0,
                   compress="lzw")

    with rio.open(output_file, "w", **profile) as out:
        out.write_band(1, raster)
        

def arr_normalizer(array):
    """
    Normalizes numpy arrays into scale 0.0 - 1.0
    """
    array_min, array_max = array.min(), array.max()
    
    return ((array - array_min)/(array_max - array_min))

#### Sentinel 2 image processing level 1
def get_s2_processed_l1(filename):
    # # open image with rio
    raster = rio.open(filename)

    # Read the data
    data = raster.read()

    ### Change the axis from (band, x, y) to (x, y, band)
    data = np.transpose(data, (1, 2, 0))

    ## Preprocessing
    data_enhanced = np.zeros(data.shape)
    for i in range(data.shape[-1]):
        p2, p98 = np.percentile(data[:, :, i], (2, 98))
        data_enhanced[:, :, i] = exposure.rescale_intensity(data[:, :, i], in_range=(p2, p98))

    return raster, arr_normalizer(data), arr_normalizer(data_enhanced)

def enhance_s2_rgb(raster):
    # Read the data
    data = raster.read()

    ### Change the axis from (band, x, y) to (x, y, band)
    data = np.transpose(data, (1, 2, 0))

    ## Preprocessing
    data_enhanced = np.zeros(data.shape)
    for i in range(data.shape[-1]):
        p2, p98 = np.percentile(data[:, :, i], (2, 98))
        data_enhanced[:, :, i] = exposure.rescale_intensity(data[:, :, i], in_range=(p2, p98))
        data_enhanced[:, :, i] = arr_normalizer(data_enhanced[:, :, i])
        data[:, :, i] = arr_normalizer(data[:, :, i])

    return data, data_enhanced

def geo_enhance_s2_rgb(geo_data):
    ## Preprocessing
    geo_enhanced = np.zeros(geo_data.shape)
    for i in range(geo_data.shape[-1]):
        for j in range(geo_data.shape[0]):
            p1, p99 = np.percentile(geo_data[j, :, :, i], (1, 99))
            geo_enhanced[j, :, :, i] = exposure.rescale_intensity(geo_data[j, :, :, i], in_range=(p1, p99))
            geo_enhanced[:, :, i] = arr_normalizer(geo_enhanced[:, :, i])
            geo_data[j, :, :, i] = arr_normalizer(geo_data[j, :, :, i])

    return geo_data, geo_enhanced

def plot_msi_image(filename: str,
                   band_list: list,
                   ax: plt.Axes=None) -> None:
    """
    Creates image plots for 3 channels images.
    :param filename: path to the tif image file
    :param band_list: contains indices of bands to be used to create 3-channel images
    :param fig_size: contains dimensions of the 2D figure size
    """
    
    assert len(band_list) == 3, "Incorrect number of channels"
    img_data = rio.open(filename).read()
    img_data = np.transpose(img_data, axes=[1, 2, 0])
    rgb_img_data = img_data[:, :, band_list]
    rgb_img_data = np.sqrt(rgb_img_data)
    norm_rgb_img_data = arr_normalizer(rgb_img_data)

    if ax is None:
        fig, ax = plt.subplots(figsize=(6, 6), dpi=100)
    ax.imshow(norm_rgb_img_data[:, :, [0, 1, 2]])
    ax.imshow(norm_rgb_img_data)
    plt.show()

def plot_spectral_index(ax, fig, spindex_arr, spindex_name=""):
    
    if spindex_name=="NDWI":
        cmap = "YlGnBu"
    if spindex_name=="NDVI":
        cmap = "RdYlGn"
    if spindex_name=="DBI":
        cmap = "cividis"
    if spindex_name=="NDBI":
        cmap = "bone"
    
    img = ax.imshow(spindex_arr, cmap=cmap)
    ax.set_title(f"\n{spindex_name}")
    ax.axis("off")
    cbar = fig.colorbar(mappable=img, ax=ax, shrink=0.85, pad=0.05,
                        orientation="horizontal", extend="both")
    cbar.set_label(f"{spindex_name} range")
    
def plot_spectral_index1(ax, fig, spindex_arr, spindex_name=""):
    
    if spindex_name=="NDWI":
        cmap = "YlGnBu"
    if spindex_name=="NDVI":
        cmap = "RdYlGn"
    if spindex_name=="DBI":
        cmap = "cividis"
    if spindex_name=="NDBI":
        cmap = "bone"
    
    img = ax.imshow(spindex_arr, cmap=cmap)
    ax.axis("off")
    cbar = fig.colorbar(mappable=img, ax=ax, shrink=0.85, pad=0.035,
                        orientation="horizontal", extend="both")
    cbar.set_label(f"{spindex_name} range\n")

def plot_spectral_indices(input_file):
    """
    Plot the true color image (RGB) of the raster and its spectral indices. 
    
    parameters
    ----------
        input_file: str
            path directory to the raster file
    """
    ### Get data to plot
    spindices, RGB = spt.calc_spectral_indices(input_file)
    
    ### Normalize the bands and get the RGB image array
    red, green, blue = RGB
    redn = arr_normalizer(red)
    greenn = arr_normalizer(green)
    bluen = arr_normalizer(blue)
    rgb = np.dstack((redn, greenn, bluen))
    
    ##### Plotting
    fig, ax = plt.subplots(2, 3, figsize=(15, 12))
    ax = ax.reshape(-1)
    
    ### RGB natural color composite
    ax[0].imshow(rgb, cmap="terrain")
    ax[0].set_title("True Color Image (RGB Original)")
    ax[0].axis("off")
    ### Plot enhanced RGB imagery
    _, _, data_enhanced = get_s2_processed_l1(input_file)
    ax[1].imshow(data_enhanced[:, :, 0:3], cmap="terrain")
    ax[1].set_title("True Color Image (RGB Enhanced)")
    ax[1].axis("off")
    
    ### Visualize all spectral indices
    for i, key in enumerate(spindices.keys()):
        plot_spectral_index(ax[i+2], fig, spindices[key], key)
    
    # ax[-1].set_axis_off()
    # raster_id = input_file.split("/")[-1].split(".")[0]
    fig.suptitle(f"\nSentinel-2A Spectral Indices of Interest\nIbadan City",
                 fontsize=20, y=0.96)
    fig.tight_layout();
    
    return fig

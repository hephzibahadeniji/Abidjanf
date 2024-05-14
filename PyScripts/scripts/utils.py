
############### Import Required Packages #############

import sys
sys.path.insert(0, "../scripts")

import numpy as np
import rasterio as rio
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
    spindices, RGB = spt.spectral_indices(input_file)
    
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
    _, _, data_enhanced = spt.get_s2_processed_l1(input_file)
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

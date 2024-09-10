#!/usr/bin/env python

import pandas as pd
import rasterio as rio
from tqdm import tqdm
from pathlib import Path
import matplotlib.pyplot as plt

class CalculateSpectralIndices():
    def __init__(self, subdata) -> None:
        self.subdata = subdata
    
    def ndvi(self):
        return (self.subdata["B8"] - self.subdata["B4"]) / (self.subdata["B8"] + self.subdata["B4"])


    def ndbi(self):
        return (self.subdata["B11"] - self.subdata["B9"]) / (self.subdata["B11"] + self.subdata["B9"])


    def savi(self):
        return 1.5 * (self.subdata["B9"] - self.subdata["B4"]) / (self.subdata["B9"] + self.subdata["B4"] + 0.5)


    def mndwi(self):
        return (self.subdata["B3"] - self.subdata["B11"]) / (self.subdata["B3"] + self.subdata["B11"])

    def nmdi(self):
        return (self.subdata["B11"] - (self.subdata["B8A"] + self.subdata["B2"])) / (self.subdata["B11"] + (self.subdata["B8A"] + self.subdata["B2"]))

    def ndwi(self):
        return (self.subdata["B3"] - self.subdata["B8"]) / (self.subdata["B3"] + self.subdata["B8"])


    def ui(self):
        return (self.subdata["B7"] - self.subdata["B5"]) / (self.subdata["B7"] + self.subdata["B5"])


    def nbi(self):
        return self.subdata["B4"] * self.subdata["B11"] / self.subdata["B9"]


    def brba(self):
        return self.subdata["B4"] / self.subdata["B11"]


    def nbai(self):
        return (self.subdata["B11"] - self.subdata["B12"] / self.subdata["B3"]) / (self.subdata["B11"] + self.subdata["B12"] / self.subdata["B3"])


    def mbi(self):
        return (self.subdata["B12"] * self.subdata["B4"] - self.subdata["B9"] ** 2) / (self.subdata["B4"] + self.subdata["B9"] + self.subdata["B12"])


    def baei(self):
        return (self.subdata["B4"] + 0.3) / (self.subdata["B3"] + self.subdata["B11"])


    def ibi(self):
        """
        Calculates the index-based building index (IBI).
        Source: https://stats.stackexchange.com/questions/178626/how-to-normalize-data-between-1-and-1

        Args:
            area_dict (dict or pd.DataFrame) : A Python dictionary or Python DataFrame containing
                                            the 11 band values

        Returns:


        """

        # Threshold
        t = 0.05

        # Normalize to (-1,1)
        ndbi_t, savi_t, mndwi_t = self.ndbi(), self.savi(), self.mndwi()
        ndbi_n = 2 * (ndbi_t - ndbi_t.min()) / (ndbi_t.max() - ndbi_t.min()) - 1
        savi_n = 2 * (savi_t - savi_t.min()) / (savi_t.max() - savi_t.min()) - 1
        mndwi_n = (
            2 * (mndwi_t - mndwi_t.min()) / (mndwi_t.max() - mndwi_t.min()) - 1
        )

        # Remove outliers
        temp = (ndbi_n - (savi_n + mndwi_n) / 2) / (ndbi_n + (savi_n + mndwi_n) / 2)
        vv = pd.DataFrame({"col": temp.reshape(-1, 1)[:, 0]})
        cutoffs = list(vv["col"].quantile([t / 2, 1 - t / 2]))

        temp[temp <= cutoffs[0]] = cutoffs[0]
        temp[temp >= cutoffs[1]] = cutoffs[1]

        return temp


def read_bands_make_indices(image_list, aoi):
    """
    Reads the bands for each image of the area of interest (AOI) and calculates
    the derived spectral indices.

    Args:
        image_list (list): Python list containing the image file paths
        of the AOI.f interest.

    Returns:
        data (pd.DataFrame): The resulting pandas dataframe containing the raw spectral
                              bands and derived indices
    """

    bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12']
    data = []
    # Iterate over each year
    for image_file in image_list:
        
        # Read each band
        subdata = dict()
        raster = rio.open(image_file)
        
        for band_idx, band in enumerate(bands):
            band_data = raster.read(band_idx + 1).ravel()
            subdata[band] = band_data

        # Get derived indices
        spectral_indices = CalculateSpectralIndices(subdata)
        subdata["ndvi"] = spectral_indices.ndvi()
        subdata["ndbi"] = spectral_indices.ndbi()
        subdata["savi"] = spectral_indices.savi()
        subdata["mndwi"] = spectral_indices.mndwi()
        subdata["nmdi"] = spectral_indices.nmdi()
        subdata["ndwi"] = spectral_indices.ndwi()
        subdata["ui"] = spectral_indices.ui()
        subdata["nbi"] = spectral_indices.nbi()
        subdata["brba"] = spectral_indices.brba()
        subdata["nbai"] = spectral_indices.nbai()
        subdata["mbi"] = spectral_indices.mbi()
        subdata["baei"] = spectral_indices.baei()

        # Cast to pandas subdataframe
        subdata = pd.DataFrame(subdata).fillna(0)
        subdata.columns = [column + "_" + str(aoi) for column in subdata.columns]

        data.append(subdata)
        del subdata

    data = pd.concat(data, axis=1)

    return data


def calculate_all_spectral_indices(raster_image_file, indices_list):
    """
    Reads the bands for each image of the area of interest (AOI) and calculates
    the derived spectral indices and create the raster images.

    Args:
        image_list (list): Python list containing the image file paths
        of the AOI.f interest.
        indices_list (list): List of spectral indices to calculate.

    Returns:
        spectral_indices (dict): The resulting dictionary of requested spectral indices
        metadata (dict): The updated vesion of the metadata of the original image
    """
    bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12']
    
    # Read each band
    subdata = dict()
    raster = rio.open(raster_image_file)
    metadata = raster.meta
    for band_idx, band in enumerate(bands):
        band_data = raster.read(band_idx + 1)
        subdata[band] = band_data
    
    # Check if a function exists in CalculateSpectralIndices to calculate the spectral index
    spectral_indices = {}
    for index_name in indices_list:
        if hasattr(CalculateSpectralIndices, index_name.lower()) and callable(getattr(CalculateSpectralIndices, index_name.lower())):
            # Initialize CalculateSpectralIndices class
            indix_instance = CalculateSpectralIndices(subdata)
            
            # Get the method and call it
            index_method = getattr(indix_instance, index_name.lower())
            spectral_indices[index_name.upper()] = index_method()
            
        else:
            print(f"Warning: Spectral index '{index_name}' is not implemented.")
    
    return spectral_indices, metadata


def write_rasterized_spectral_index(index_image, output_path, metadata):
    """
    Writes the raster image to disk using rasterio.

    Parameters:
    index_image (np.ndarray): Image data to save.
    output_path (str): Path to save the raster file.
    metadata (dict): Metadata for the image.
    """
    # Update the metadata for the image      
    metadata.update({'dtype': 'float32',
                     'count': 1, 'compress': 'lzw'})
    
    with rio.open(output_path, 'w', **metadata) as dst:
        dst.write(index_image, 1)

def plot_spectral_indices(indices):
    """
    Plots the spectral indices.

    Parameters:
    indices (dict): Dictionary of calculated spectral indices.
    """
    num_indices = len(indices)
    fig, axes = plt.subplots(1, num_indices, figsize=(20, 5), dpi=150)
    
    if num_indices == 1:
        axes = [axes]
    
    for i, (index_name, index_data) in enumerate(indices.items()):
        ax = axes[i]
        cax = ax.imshow(index_data, cmap='viridis')
        ax.set_title(index_name.upper())
        ax.axis('off')
        fig.colorbar(cax, ax=ax, orientation='horizontal')
        
        fig.tight_layout()

    plt.show()
    
    return fig

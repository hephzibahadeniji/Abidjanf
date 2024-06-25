#!/usr/bin/env python

import os
import sys
import numpy as np
import pandas as pd

from skimage import exposure
import rasterio as rio
from rasterio.plot import reshape_as_image
import cv2

# Add local module to the path
src = os.path.abspath('../scripts')
if src not in sys.path:
    sys.path.append(src)
    # sys.path.insert(0, src)
    
from mkdir import check_create_dir


def read_sentinel_image(file_path):
    """
    Reads a Sentinel-2A image from a .tiff file using rasterio.

    Args:
        file_path (str): Path to the .tiff file.

    Returns:
        np.ndarray: Multispectral image data.
        rasterio.profiles.Profile: Metadata of the image.
    """
    with rio.open(file_path) as src:
        image_data = src.read()
        metadata = src.profile

    return image_data, metadata

def resize_image(image, target_height, target_width):
    """
    Resizes the image to the specified width and height.

    Args:
        image (np.ndarray): Multispectral image data.
        target_height (int): Target height for resizing.
        target_width (int): Target width for resizing.

    Returns:
        np.ndarray: Resized image data.
    """
    # Reshape the image to (height, width, channels) format
    image_reshaped = reshape_as_image(image)
    resized_image = cv2.resize(image_reshaped, (target_width, target_height), interpolation=cv2.INTER_LINEAR)
    
    # Reshape back to (bands, height, width) format
    resized_image = np.transpose(resized_image, (2, 0, 1))

    return resized_image

def create_patches(image, patch_size):
    """
    Splits the image into smaller patches.

    Args:
        image (np.ndarray): Resized image data.
        patch_size (int): Size of each patch (patch_size x patch_size).

    Returns:
        List[np.ndarray]: List of image patches.
    """
    patches = []
    bands, height, width = image.shape
    for i in range(0, height, patch_size):
        for j in range(0, width, patch_size):
            patch = image[:, i:i + patch_size, j:j + patch_size]
            if patch.shape[1] == patch_size and patch.shape[2] == patch_size:
                patches.append(patch)
    return patches

def save_image(image, file_path, metadata):
    """
    Saves the image to a .tiff file.

    Args:
        image (np.ndarray): Image data to save.
        file_path (str): Path to save the .tiff file.
        metadata (rasterio.profiles.Profile): Metadata for the image.
    """
    metadata.update({
        'height': image.shape[1],
        'width': image.shape[2],
        'count': image.shape[0]
    })
    with rio.open(file_path, 'w', **metadata) as dst:
        dst.write(image)

def save_patches(patches, output_dir, metadata):
    """
    Saves the image patches to the specified directory.

    Args:
        patches (List[np.ndarray]): List of image patches to save.
        output_dir (str): Directory to save the patches.
        metadata (rasterio.profiles.Profile): Metadata for the patches.
    """
    check_create_dir(output_dir) # Check if directory exists create 
    
    for idx, patch in enumerate(patches):
        patch_file_path = os.path.join(output_dir, f'patch_{idx}.tif')
        save_image(patch, patch_file_path, metadata)

def enhance_image(image_data):
    """
    Enhance the quality of the image by stretching or shrinking its intensity levels.

    Args:
        image (np.ndarray): Resized image data.

    Returns:
        np.ndarray: Enhanced image data.
    """
    # Change the axis from (band, x, y) to (x, y, band)
    image_data = np.transpose(image_data, (1, 2, 0))

    # Data preprocessing: enhancing the image quality
    data_enhanced = np.zeros(image_data.shape)
    for i in range(image_data.shape[-1]):
        p2, p98 = np.percentile(image_data[:, :, i], (2, 98))
        data_enhanced[:, :, i] = exposure.rescale_intensity(image_data[:, :, i], in_range=(p2, p98))

    # Reshape back to (bands, height, width) format
    data_enhanced = np.transpose(data_enhanced, (2, 0, 1))
    
    return data_enhanced

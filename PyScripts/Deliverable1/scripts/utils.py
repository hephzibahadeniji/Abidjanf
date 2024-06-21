#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt



def plot_bands(image_data, patch_id=None):
    """
    Plots all the bands of the raster image.
    
    Args:
        image_data (np.ndarray): Multispectral image data.
        patch_id (str, optional): Patch number. Defaults to None.
    """
    num_bands = image_data.shape[0]
    
    fig, axes = plt.subplots(1, num_bands, figsize=(20, 5))
    if num_bands == 1:
        axes = [axes]
    
    for i in range(num_bands):
        ax = axes[i]
        ax.imshow(image_data[i])
        if patch_id is not None:
            ax.set_title(f'{patch_id}: Band {i+2}')
        else:
            ax.set_title(f'Band {i+2}')
        ax.axis('off')
    
    plt.show()

def plot_rgb(image_data, rgb_indices=(3, 2, 1), ax=None):
    """
    Plots the RGB true color image.

    Args:
        image_data (np.ndarray): Multispectral image data.
        rgb_indices (tuple, optional): Indices of the bands to use for RGB. Defaults to (3, 2, 1) for Sentinel-2A.
        ax (Axis, optional): Axis on which the image is shown. Defaults to None.

    Raises:
        ValueError: RGB indices must be a tuple of three band indices.
    """
    if len(rgb_indices) != 3:
        raise ValueError("RGB indices must be a tuple of three band indices.")
    
    rgb_image = np.dstack([image_data[rgb_indices[0]-1], image_data[rgb_indices[1]-1], image_data[rgb_indices[2]-1]])
    rgb_image = (rgb_image - rgb_image.min()) / (rgb_image.max() - rgb_image.min())
    
    if ax is not None:
        ax.imshow(rgb_image, cmap="terrain")
    else:
        plt.figure(figsize=(10, 10))
        plt.imshow(rgb_image, cmap="terrain")
        plt.title('RGB True Color Image')
        plt.axis('off')
        plt.show()

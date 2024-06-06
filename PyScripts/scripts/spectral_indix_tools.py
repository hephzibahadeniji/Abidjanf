############### Import Required Packages #############

import sys
sys.path.insert(0, "../scripts")

import utils as s2u

############### Spectral Indices (SIs) ###############

##### Normalized Difference Vegetation Index (NDVI)
def NDVI(nir, red):
    """
    Calculates NDVI
    
    parameters
    ----------
        nir: NIR band as input
        red: RED band as input
    """
    NDVI = (nir.astype("float") - red.astype("float")) / \
        (nir.astype("float") + red.astype("float"))

    return NDVI

##### Dry Bareness Index (DBI)
def DBI(green, swinr1, ndvi):
    """
    Calculate DBI
    
    parameters
    ----------
        swinr1: SWINR1 band as input
        green: green band as input
    """
    DBI = ((swinr1.astype("float") - green.astype("float")) /
           (swinr1.astype("float") + green.astype("float"))) - ndvi

    return DBI

##### Modified Normalized Difference Water Index (NDWI)
def NDWI(green, swinr1):
    """
    Calculate MNDWI
    
    parameters
    ----------
        swinr1: MINR band as input
        green: GREEN band as input
    """
    NDWI = (green.astype("float") - swinr1.astype("float")) / \
        (green.astype("float") + swinr1.astype("float"))

    return NDWI

##### Normalized Difference Built-up Index (NDBI)
def NDBI(swinr1, nir):
    """
    Calculate NDBI
    
    parameter
    ---------
        swinr: SWINR band as input
        nir: NIR band as input
    """
    NDBI = (swinr1.astype("float") - nir.astype("float")) / \
        (swinr1.astype("float") + nir.astype("float"))

    return NDBI

#####
def calc_one_spectral_indix(input_file: str, sp_index: str="NDVI", verbose: bool=True):
    """
    Calculate the specified Spectral Index. 
    
    parameters
    ----------
        input_file: str
            path directory to the raster file
        sp_index: spectral indix of interest: NDVI, DBI, NDWI, NDBI
    """
    if verbose:
        print(f"\nThe spectral indix: {sp_index}, is being calculated ...",)

    ### Get the image id from the image_path
    img_id = input_file.split("/")[-1].split(".")[0]
    print(f"{' '*2} Raster image ID: {img_id}")

    ### Load the raster image
    if not input_file.endswith(".tif"):
        return "S\nSorry! The file entered is not for a raster image."
    else:
        raster = s2u.load_raster(input_file)

        ### Slice the bands: our data has only 11 bands instead of 13
        # Bands = ('B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12')
        blue = raster["band"][0, :, :]  # represented by B2
        green = raster["band"][1, :, :]  # represented by B3
        red = raster["band"][2, :, :]  # represented by B4
        nir = raster["band"][6, :, :]  # represented by B8
        swinr1 = raster["band"][9, :, :]  # represented by B11
        swinr2 = raster["band"][10, :, :]  # represented by B12

        if sp_index == "NDVI":
            ### Calculate NDVI
            return NDVI(nir, red)

        elif sp_index == "DBI":
            ### Calculate DBI
            ndvi = NDVI(nir, red)
            return DBI(green, swinr1, ndvi)

        elif sp_index == "NDWI":
            ### Calculate NDWI
            return NDWI(green, swinr1)

        elif sp_index == "NDBI":
            ### Calculate NDBI
            return NDBI(swinr1, nir)

        else:
            alert = "\nSorry! The spectral indix is one of these: NDVI, DBI, SAVI, NDWI, NDBI!\n"
            return alert

#####
def calc_spectral_indices(input_file: str, verbose: bool=False) -> tuple:
    """
    Calculate the Spectral Indices of Interest: NDVI, DBI, SAVI, NDWI, NDBI. 
    
    parameters
    ----------
        input_file: str
            path directory to the raster file
    """
    ### Get the image id from the image_path
    if verbose:
        img_id = input_file.split("/")[-1].split(".")[0]
        print(f"{' '*2} Spectral Indices from raster image ID: {img_id}")

    ### Load the raster image
    if not input_file.endswith(".tif"):
        return "\nSorry! The file entered is not for a raster image."
    else:
        raster = s2u.load_raster(input_file)

        ### Slice the bands: note our data has only 11 bands instead of 13
        # Bands = ('B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12')
        blue = raster["band"][0, :, :]  # represented by B2
        green = raster["band"][1, :, :]  # represented by B3
        red = raster["band"][2, :, :]  # represented by B4
        nir = raster["band"][6, :, :]  # represented by B8
        swinr = raster["band"][9, :, :]  # represented by B11
        swinr1 = raster["band"][10, :, :]  # represented by B12

        ### Calculate NDWI, NDVI, DBI, NDBI, SAVI
        ndvi = NDVI(nir, red)
        spindices = {"NDWI": NDWI(green, swinr1),
                     "NDVI": ndvi,
                     "DBI": DBI(green, swinr1, ndvi),
                     "NDBI": NDBI(swinr1, nir)}

        RGB = (red, green, blue)

        return spindices, RGB
    








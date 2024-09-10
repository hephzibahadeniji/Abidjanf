"""

Factorization based segmentation

"""
# Import required packages
import time
import numpy as np
from numpy import linalg as LA
from scipy import linalg as LAsci
import math
from skimage import io, color

# Import customized modules
from factseg_filters import image_filtering


def SHcomp(Ig, ws, BinN=11):
    """
    Compute local spectral histogram using integral histograms
    :param Ig: a n-band image
    :param ws: half window size
    :param BinN: number of bins of histograms
    :return: local spectral histogram at each pixel
    """
    h, w, bn = Ig.shape

    # quantize values at each pixel into bin ID
    for i in range(bn):
        b_max = np.max(Ig[:, :, i])
        b_min = np.min(Ig[:, :, i])
        assert b_max != b_min, "Band %d has only one value!" % i

        b_interval = (b_max - b_min) * 1. / BinN
        Ig[:, :, i] = np.floor((Ig[:, :, i] - b_min) / b_interval)

    Ig[Ig >= BinN] = BinN-1
    Ig = np.int32(Ig)

    # convert to one hot encoding
    one_hot_pix = []
    for i in range(bn):
        one_hot_pix_b = np.zeros((h*w, BinN), dtype=np.int32)
        one_hot_pix_b[np.arange(h*w), Ig[:, :, i].flatten()] = 1
        one_hot_pix.append(one_hot_pix_b.reshape((h, w, BinN)))

    # compute integral histogram
    integral_hist = np.concatenate(one_hot_pix, axis=2)

    np.cumsum(integral_hist, axis=1, out=integral_hist, dtype=np.float32)
    np.cumsum(integral_hist, axis=0, out=integral_hist, dtype=np.float32)

    # compute spectral histogram based on integral histogram
    padding_l = np.zeros((h, ws + 1, BinN * bn), dtype=np.int32)
    padding_r = np.tile(integral_hist[:, -1:, :], (1, ws, 1))

    integral_hist_pad_tmp = np.concatenate([padding_l, integral_hist, padding_r], axis=1)

    padding_t = np.zeros((ws + 1, integral_hist_pad_tmp.shape[1], BinN * bn), dtype=np.int32)
    padding_b = np.tile(integral_hist_pad_tmp[-1:, :, :], (ws, 1, 1))

    integral_hist_pad = np.concatenate([padding_t, integral_hist_pad_tmp, padding_b], axis=0)

    integral_hist_1 = integral_hist_pad[ws + 1 + ws:, ws + 1 + ws:, :]
    integral_hist_2 = integral_hist_pad[:-ws - ws - 1, :-ws - ws - 1, :]
    integral_hist_3 = integral_hist_pad[ws + 1 + ws:, :-ws - ws -1, :]
    integral_hist_4 = integral_hist_pad[:-ws - ws - 1, ws + 1 + ws:, :]

    sh_mtx = integral_hist_1 + integral_hist_2 - integral_hist_3 - integral_hist_4

    histsum = np.sum(sh_mtx, axis=-1, keepdims=True) * 1. / bn

    sh_mtx = np.float32(sh_mtx) / np.float32(histsum)

    return sh_mtx


def SHedgeness(sh_mtx, ws):
    h, w, _ = sh_mtx.shape
    edge_map = np.ones((h, w)) * -1
    for i in range(ws, h-ws-1):
        for j in range(ws, w-ws-1):
            edge_map[i, j] = np.sqrt(np.sum((sh_mtx[i - ws, j, :] - sh_mtx[i + ws, j, :])**2)
                                     + np.sum((sh_mtx[i, j - ws, :] - sh_mtx[i, j + ws, :])**2))
    return edge_map


def Fseg(Ig, ws, segn, omega, nonneg_constraint=True):
    """
    Factorization based segmentation
    :param Ig: a n-band image
    :param ws: window size for local special histogram
    :param segn: number of segment. if set to 0, the number will be automatically estimated
    :param omega: error threshod for estimating segment number. need to adjust for different filter bank.
    :param nonneg_constraint: whether apply negative matrix factorization
    :return: segmentation label map
    """

    N1, N2, bn = Ig.shape

    ws = ws / 2
    sh_mtx = SHcomp(Ig, ws)
    sh_dim = sh_mtx.shape[2]

    Y = (sh_mtx.reshape((N1 * N2, sh_dim)))
    S = np.dot(Y.T, Y)
    d, v = LA.eig(S)

    d_sorted = np.sort(d)
    idx = np.argsort(d)
    k = np.abs(d_sorted)
    
    print("\nEstimating the segment number ...")
    if segn == 0:  # estimate the segment number
        print("\nCalculate the least squared error (LSE) ratio:")
        lse_ratio = np.cumsum(k) * 1. / (N1 * N2)
        print(lse_ratio)
        avg_lse = np.sum(k)/(N1 * N2)
        print("\nAverage the LSE: %0.8f" % (avg_lse))
        segn = np.sum(lse_ratio > omega)
        print('\nEstimated segment number: %d for window size %d x %d\n' % (segn, ws*2, ws*2))

        if segn <= 1:
            segn = 2
            print('Warning: Segment number is set to 2. May need to reduce omega for better segment number estimation.')

    dimn = segn

    U1 = v[:, idx[-1:-dimn-1:-1]]

    Y1 = np.dot(Y, U1)  # project features onto the subspace

    edge_map = SHedgeness(Y1.reshape((N1, N2, dimn)), ws)

    edge_map_flatten = edge_map.flatten()

    Y_woedge = Y1[(edge_map_flatten >= 0) & (edge_map_flatten <= np.max(edge_map)*0.4), :]

    # find representative features using clustering
    cls_cen = np.zeros((segn, dimn), dtype=np.float32)
    L = np.sum(Y_woedge ** 2, axis=1)
    cls_cen[0, :] = Y_woedge[np.argmax(L), :]  # find the first initial center

    D = np.sum((cls_cen[0, :] - Y_woedge) ** 2, axis=1)
    cls_cen[1, :] = Y_woedge[np.argmax(D), :]

    cen_id = 1
    while cen_id < segn-1:
        cen_id += 1
        D_tmp = np.zeros((cen_id, Y_woedge.shape[0]), dtype=np.float32)
        for i in range(cen_id):
            D_tmp[i, :] = np.sum((cls_cen[i, :] - Y_woedge) ** 2, axis=1)
        D = np.min(D_tmp, axis=0)
        cls_cen[cen_id, :] = Y_woedge[np.argmax(D), :]

    D_cen2all = np.zeros((segn, Y_woedge.shape[0]), dtype=np.float32)
    cls_cen_new = np.zeros((segn, dimn), dtype=np.float32)
    is_converging = 1
    while is_converging:
        for i in range(segn):
            D_cen2all[i, :] = np.sum((cls_cen[i, :] - Y_woedge) ** 2, axis=1)

        cls_id = np.argmin(D_cen2all, axis=0)

        for i in range(segn):
            cls_cen_new[i, :] = np.mean(Y_woedge[cls_id == i, :], axis=0)

        if np.max((cls_cen_new - cls_cen)**2) < .00001:
            is_converging = 0
        else:
            cls_cen = cls_cen_new * 1.
    cls_cen_new = cls_cen_new.T

    ZZTinv = LAsci.inv(np.dot(cls_cen_new.T, cls_cen_new))
    Beta = np.dot(np.dot(ZZTinv, cls_cen_new.T), Y1.T)

    seg_label = np.argmax(Beta, axis=0)

    if nonneg_constraint:
        w0 = np.dot(U1, cls_cen_new)
        dnorm0 = 1

        h = Beta * 1.
        for i in range(100):
            tmp, _, _, _ = LA.lstsq(np.dot(w0.T, w0) + np.eye(segn) * .01, np.dot(w0.T, Y.T), rcond=None)
            h = np.maximum(0, tmp)
            tmp, _, _, _ = LA.lstsq(np.dot(h, h.T) + np.eye(segn) * .01, np.dot(h, Y), rcond=None)
            w = np.maximum(0, tmp)
            w = w.T * 1.

            d = Y.T - np.dot(w, h)
            dnorm = np.sqrt(np.mean(d * d))
            print(i, np.abs(dnorm - dnorm0), dnorm)
            if np.abs(dnorm - dnorm0) < .1:
                break

            w0 = w * 1.
            dnorm0 = dnorm * 1.

        seg_label = np.argmax(h, axis=0)

    return seg_label.reshape((N1, N2))


def FacSeg_S2A(input_path, filter_bank, output_path=None, ws=25, segn=0, omega=.045, nonneg_constraint=True):
    # Read the image data
    import rasterio as rio
    with rio.open(input_path) as sat_image:
        bands = sat_image.read()  # Reads all the bands
        image_data = sat_image.read([1, 2, 3, 7])  # Reads the three visible bands (Red, Green, Blue) and the near infrared (NIR) band
        image_data = image_data.transpose((1, 2, 0)) # Transpose from (bands, x, y) to (x, y, bands)
        metadata = sat_image.profile
        
        # Make the rgb composite and greyscale images
        rgb_image = rgb_S2A_image(sat_image) 
        greyscale_image = color.rgb2gray(rgb_image)
        
    # Filter the image
    filter_out = image_filtering(greyscale_image, filter_list=filter_bank)
    
    # Stack all the preprocessed arrays and include original bands
    grey_image = np.float32(greyscale_image.reshape((greyscale_image.shape[0], greyscale_image.shape[1], 1)))
    Ig = np.concatenate((np.float32(image_data), grey_image, np.float32(filter_out)), axis=2)
    
    # Try different window size, with and without nonneg constraints
    segmented_image = Fseg(Ig, ws, segn, omega, nonneg_constraint)
    
    # Include original image
    out_shape = (1, bands.shape[1], bands.shape[2])
    merged_bands = np.float32(segmented_image.reshape(out_shape)) # Transpose from (x, y) to (1, x, y) 
    
    # Update data and the metadata for the image
    if output_path is not None:  
        metadata.update({'dtype': 'float32',
                         'height': merged_bands.shape[1],
                         'width': merged_bands.shape[2],
                         'count': merged_bands.shape[0],
                         'compress': 'lzw'})
        
        with rio.open(output_path, 'w', **metadata) as dst:
            dst.write(merged_bands)
    
    return merged_bands

def FacSeg_S2A_fbands(input_path, filter_bank, output_path=None, ws=25, segn=0, omega=.045, nonneg_constraint=True):
    # Read the image data
    import rasterio as rio
    with rio.open(input_path) as sat_image:
        bands = sat_image.read()  # Reads all the bands
        image_data = sat_image.read([1, 2, 3, 7])  # Reads the three visible bands (Red, Green, Blue) and the near infrared (NIR) band
        image_data = image_data.transpose((1, 2, 0)) # Transpose from (bands, x, y) to (x, y, bands)
        metadata = sat_image.profile
        
        # Make the rgb composite and greyscale images
        rgb_image = rgb_S2A_image(sat_image) 
        greyscale_image = color.rgb2gray(rgb_image)
        
        # Filter the image
        filter_out = image_filtering(greyscale_image, filter_list=filter_bank)
        filter_red = image_filtering(sat_image.read(3), filter_list=filter_bank)
        filter_green = image_filtering(sat_image.read(2), filter_list=filter_bank)
        filter_blue = image_filtering(sat_image.read(1), filter_list=filter_bank)
        filter_nir = image_filtering(sat_image.read(7), filter_list=filter_bank)
    
    # Stack all the preprocessed arrays and include original bands
    grey_image = np.float32(greyscale_image.reshape((greyscale_image.shape[0], greyscale_image.shape[1], 1)))
    Ig = np.concatenate((np.float32(image_data), grey_image, np.float32(filter_out),
                         np.float32(filter_red), np.float32(filter_green),
                         np.float32(filter_blue), np.float32(filter_nir)), axis=2)
    
    # Try different window size, with and without nonneg constraints
    segmented_image = Fseg(Ig, ws, segn, omega, nonneg_constraint)
    
    # Include original image
    out_shape = (1, bands.shape[1], bands.shape[2])
    merged_bands = np.float32(segmented_image.reshape(out_shape)) # Transpose from (x, y) to (1, x, y) 
    
    # Update data and the metadata for the image
    if output_path is not None:  
        metadata.update({'dtype': 'float32',
                         'height': merged_bands.shape[1],
                         'width': merged_bands.shape[2],
                         'count': merged_bands.shape[0],
                         'compress': 'lzw'})
        
        with rio.open(output_path, 'w', **metadata) as dst:
            dst.write(merged_bands)
    
    return merged_bands

def FacSeg_main(image_path, filter_bank, ws, segn=0, omega=.045, nonneg_constraint=True):
    # Read the image data
    image_data = io.imread(image_path)
    if len(image_data.shape) > 2:
        image_data = color.rgb2gray(image_data)
        
    filter_out = image_filtering(image_data, filter_list=filter_bank)
    
    # Include original image as one band
    Ig = np.concatenate((np.float32(image_data.reshape((image_data.shape[0], image_data.shape[1], 1))), filter_out), axis=2)
    
    # Try different window size, with and without nonneg constraints
    segmented_image = Fseg(Ig, ws, segn, omega, nonneg_constraint)
    
    out_shape = (1, image_data.shape[0], image_data.shape[1])
    final_image = np.concatenate((image_data.reshape(out_shape), segmented_image.reshape(out_shape)), axis=0)
    
    return final_image

def rgb_S2A_image(sat_image):
    # Read the Red (band 4), Green (band 3), and Blue (band 2) bands
    red = sat_image.read(3)
    green = sat_image.read(2)
    blue = sat_image.read(1)
    
    # Stack the bands to form an RGB image
    rgb_image = np.dstack((red, green, blue))
    # Normalize the pixel values to 0-1 for better visualization
    rgb_image = rgb_image.astype(float)
    rgb_image /= rgb_image.max()
    
    return rgb_image

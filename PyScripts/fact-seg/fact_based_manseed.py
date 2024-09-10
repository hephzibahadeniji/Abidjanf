"""
Factorization based segmentation with manually selected seeds
"""

import time
import numpy as np
from fact_based_seg_filters import image_filtering
import matplotlib.pyplot as plt
from scipy import linalg as LAsci
from skimage import io, transform

def resize_image(image, target_size=(1024, 1024)):
    """
    Resize the input image to the target size.
    
    Args:
        image: Input image (NumPy array).
        target_size: Desired output size as a tuple (height, width).
    
    Returns:
        Resized image as a NumPy array.
    """
    resized = transform.resize(image, target_size + (image.shape[2],), anti_aliasing=True, preserve_range=True)
    return resized.astype(np.float32)

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
        assert b_max != b_min, f"Band {i} has only one value!"

        b_interval = (b_max - b_min) * 1. / BinN
        Ig[:, :, i] = np.floor((Ig[:, :, i] - b_min) / b_interval)

    Ig[Ig >= BinN] = BinN - 1
    Ig = np.int32(Ig)

    # convert to one hot encoding
    one_hot_pix = []
    for i in range(bn):
        one_hot_pix_b = np.zeros((h * w, BinN), dtype=np.int32)
        one_hot_pix_b[np.arange(h * w), Ig[:, :, i].flatten()] = 1
        one_hot_pix.append(one_hot_pix_b.reshape((h, w, BinN)))

    # compute integral histogram
    integral_hist = np.concatenate(one_hot_pix, axis=2)
    np.cumsum(integral_hist, axis=1, out=integral_hist)
    np.cumsum(integral_hist, axis=0, out=integral_hist)

    # compute spectral histogram based on integral histogram
    padding_l = np.zeros((h, ws + 1, BinN * bn), dtype=np.int32)
    padding_r = np.tile(integral_hist[:, -1:, :], (1, ws, 1))
    integral_hist_pad_tmp = np.concatenate([padding_l, integral_hist, padding_r], axis=1)
    padding_t = np.zeros((ws + 1, integral_hist_pad_tmp.shape[1], BinN * bn), dtype=np.int32)
    padding_b = np.tile(integral_hist_pad_tmp[-1:, :, :], (ws, 1, 1))
    integral_hist_pad = np.concatenate([padding_t, integral_hist_pad_tmp, padding_b], axis=0)

    integral_hist_1 = integral_hist_pad[ws + 1 + ws:, ws + 1 + ws:, :]
    integral_hist_2 = integral_hist_pad[:-ws - 1 - ws, :-ws - 1 - ws, :]
    integral_hist_3 = integral_hist_pad[ws + 1 + ws:, :-ws - 1 - ws, :]
    integral_hist_4 = integral_hist_pad[:-ws - 1 - ws, ws + 1 + ws:, :]

    histsum = integral_hist_1 + integral_hist_2 - integral_hist_3 - integral_hist_4
    sh_mtx = np.float32(histsum)
    sh_mtx = np.float32(sh_mtx) / np.float32(histsum)

    return sh_mtx

def Fseg(Ig, ws, seeds):
    """
    Factorization based segmentation
    :param Ig: a n-band image
    :param ws: window size for local special histogram
    :param seeds: list of coordinates [row, column] for seeds. each seed represent one type of texture
    :return: segmentation label map
    """
    N1, N2, bn = Ig.shape
    ws = ws // 2
    sh_mtx = SHcomp(Ig, ws)

    Z = []
    for seed in seeds:
        Z.append(sh_mtx[seed[0], seed[1], :].reshape((-1, 1)))

    Z = np.hstack(Z)

    Y = sh_mtx.reshape((N1 * N2, -1))

    ZZTinv = LAsci.inv(np.dot(Z.T, Z))
    Beta = np.dot(np.dot(ZZTinv, Z.T), Y.T)

    seg_label = np.argmax(Beta, axis=0)

    return seg_label.reshape((N1, N2))

if __name__ == '__main__':
    
    # An example of using fact_based_seg_manseed
    img_path = './M3.pgm'
    # img_path = './test.png'
    img = io.imread(img_path)
    # img = resize_image(img)
    
    # define filter bank and apply to image. for color images, convert rgb to grey scale and then apply filter bank
    filter_list = [('log', .5, [3, 3]), ('log', 1.2, [7, 7])]

    # include original image as one band
    # Ig = np.concatenate((np.float32(img.reshape((image.shape[0], image.shape[1], 1))), filter_out), axis=2)
    # Ig = np.concatenate((np.float32(image.reshape((image.shape[0], image.shape[1], image.shape[2], 1))), filter_out), axis=2)
    
    # Apply Filters to each channel
    if (len(img.shape) >= 3) & (img.shape[-1] >= 3):
        Ig = np.empty((img.shape[0], img.shape[1], 0), dtype=np.float32)
        for channel in range(img.shape[2]):
            filter_out = image_filtering(img[:, :, channel], filter_list=filter_list)
            Ig = np.concatenate((Ig, img[:, :, channel:channel+1], filter_out), axis=2)
    # Include original image as one band
    else:
        filter_out = image_filtering(img, filter_list=filter_list)
        Ig = np.concatenate((np.float32(img.reshape((img.shape[0], img.shape[1], 1))), filter_out), axis=2)

    seeds = [[60, 238], [160, 160], [238, 60]]  # provide seeds

    time0 = time.time()
    # run segmentation. try different window size
    seg_out = Fseg(Ig, ws=19, seeds=seeds)

    print('FSEG runs in %0.2f seconds.' % (time.time() - time0))

    # show results
    fig, ax = plt.subplots(ncols=2, sharex=True, sharey=True, figsize=(10, 5))
    ax[0].imshow(img, cmap='gray')
    seeds = np.array(seeds)
    ax[0].plot(seeds[:, 1], seeds[:, 0], 'r*')
    ax[1].imshow(seg_out, cmap='gray')
    plt.tight_layout()
    plt.show()

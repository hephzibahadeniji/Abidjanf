"""
Factorization based segmentation
"""
import os
import time
import numpy as np
from numpy import linalg as LA
from fact_based_seg_filters import image_filtering
import matplotlib.pyplot as plt
from scipy import linalg as LAsci
import math
from skimage import io, color

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
    np.cumsum(integral_hist, axis=1, out=integral_hist, dtype=np.float32)
    np.cumsum(integral_hist, axis=0, out=integral_hist, dtype=np.float32)

    # compute spectral histogram based on integral histogram
    padding_l = np.zeros((h, ws + 1, BinN * bn), dtype=np.int32)
    padding_r = np.tile(integral_hist[:, -1:, :], (1, ws, 1))
    integral_hist_pad_tmp = np.concatenate([padding_l, integral_hist, padding_r], axis=1)
    padding_t = np.zeros((ws + 1, integral_hist_pad_tmp.shape[1], BinN * bn), dtype=np.int32)
    padding_b = np.tile(integral_hist_pad_tmp[-1:, :, :], (ws, 1, 1))
    integral_hist_pad = np.concatenate([padding_t, integral_hist_pad_tmp, padding_b], axis=0)

    hi = (integral_hist_pad[2 * ws + 1:, 2 * ws + 1:, :] + integral_hist_pad[:-2 * ws - 1, :-2 * ws - 1, :] -
          integral_hist_pad[2 * ws + 1:, :-2 * ws - 1, :] - integral_hist_pad[:-2 * ws - 1, 2 * ws + 1:, :])
    hi = hi / ((2. * ws + 1) ** 2)

    return hi

def Fseg(Ig, ws, segn=0, omega=0.045, nonneg_constraint=True):
    """
    Factorization based segmentation
    :param Ig: a n-band image
    :param ws: half window size
    :param segn: number of segments
    :param omega: regularization parameter
    :param nonneg_constraint: if True, apply non-negative constraints
    :return: segmentation result
    """
    N1, N2, Bn = Ig.shape
    Y = SHcomp(Ig, ws).reshape((N1 * N2, Bn * 11)).T

    if segn == 0:
        U, S, V = LA.svd(Y, full_matrices=False)
        d = np.cumsum(S) / np.sum(S)
        segn = np.where(d >= (1 - omega))[0][0] + 1

    if nonneg_constraint:
        np.random.seed(0)
        w0 = np.random.rand(Y.shape[0], segn)
        dnorm0 = 0

        for i in range(1000):
            tmp, _, _, _ = LA.lstsq(np.dot(w0.T, w0) + np.eye(segn) * .01, np.dot(w0.T, Y), rcond=None)
            h = np.maximum(0, tmp)
            tmp, _, _, _ = LA.lstsq(np.dot(h, h.T) + np.eye(segn) * .01, np.dot(h, Y.T), rcond=None)
            w = np.maximum(0, tmp)
            w = w.T * 1.

            d = Y - np.dot(w, h)
            dnorm = np.sqrt(np.mean(d * d))
            print(i, np.abs(dnorm - dnorm0), dnorm)
            if np.abs(dnorm - dnorm0) < .1:
                break

            w0 = w * 1.
            dnorm0 = dnorm * 1.

        seg_label = np.argmax(h, axis=0)

    return seg_label.reshape((N1, N2))

if __name__ == '__main__':
    time0 = time.time()
    # An example of using fact_based_seg
    # read image
    # img_path = './M3.pgm'
    # img_path = "./inspiring-truth.jpeg"
    # img_path = "./sample_image_4.jpeg"
    img_path = "./grayscale_cat.jpg"
    img = io.imread(img_path)
    print(img.shape)
    
    output_dir = r"./image_texture/FSeg"  
    # img_size = 1024

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # define filter bank and apply to image. for color images, convert rgb to grey scale and then apply filter bank
    filter_list = [('log', .5, [3, 3]), ('log', 1, [5, 5]),
                   ('gabor', 1.5, 0), ('gabor', 1.5, math.pi/2), ('gabor', 1.5, math.pi/4), ('gabor', 1.5, -math.pi/4),
                   ('gabor', 2.5, 0), ('gabor', 2.5, math.pi/2), ('gabor', 2.5, math.pi/4), ('gabor', 2.5, -math.pi/4)
                   ]

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

    # run segmentation. try different window size, with and without nonneg constraints
    seg_out = Fseg(Ig, ws=25, segn=0, omega=.045, nonneg_constraint=True)
    
    # Save composite texture features
    # output_feature_filename = f"{output_dir}/composite_texture_features_RGB.npy"
    # np.save(output_feature_filename, seg_out)

    print('\nFSEG runs in %0.2f minutes. \n' % ((time.time() - time0)/60))

    # show results
    fig, ax = plt.subplots(ncols=2, sharex=True, sharey=True, figsize=(12, 6))
    ax[0].imshow(img, cmap='grey')
    ax[1].imshow(seg_out, cmap='grey')
    ax[0].set_title("Original image")
    ax[1].set_title("Segmented image")
    fig.tight_layout()
    plt.show()
    
    # Save visualized composite texture map
    output_image_filename = f"{output_dir}/example_with_image_cat.png"
    fig.savefig(output_image_filename, bbox_inches='tight', dpi=300)

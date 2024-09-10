"""

Factorization based segmentation

"""
# Import required packages
import time
import math
import numpy as np
import rasterio as rio
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt

# Import customized modules
import satellite_image_factoseg as satseg

def main():
    
    time0 = time.time()
    # Declare required directories and path 
    img_dir = "../S2A/patches/"
    out_dir = "../EXP3/"
    patch = 16
    input_path = img_dir + "Ibadan_patch_%d.tif" % (patch)
    aoi = input_path.split('/')[-1].split('_')[0] # Get the aoi
    
    # Define filter bank and apply to image. for color images, convert rgb to grey scale and then apply filter bank
    filter_bank = [('log', .5, [3, 3]), ('log', 1, [5, 5]),
                   ('gabor', 1.5, 0), ('gabor', 1.5, math.pi/2), ('gabor', 1.5, math.pi/4), ('gabor', 1.5, -math.pi/4),
                   ('gabor', 2.5, 0), ('gabor', 2.5, math.pi/2), ('gabor', 2.5, math.pi/4), ('gabor', 2.5, -math.pi/4)]
    
    # Run segmentation: try different window size, with and without nonneg constraints
    ws = 5
    segn = 0
    # omega = .045
    omega = .065
    nct = True
    output_path = out_dir + "%s_patch_%d_factbased_segmented_ws%d_ncT.tif" % (aoi, patch+1, ws)
    # output_path = out_dir + "%s_factbased_segmented_ws%d_ncT.tif" % (aoi, patch+1, ws)
    segmented_output = satseg.FacSeg_S2A(input_path=input_path,
                                         filter_bank=filter_bank,
                                         output_path=output_path,
                                         ws=ws, segn=segn, omega=omega,
                                         nonneg_constraint=nct)
    # segmented_output = satseg.FacSeg_S2A_fbands(input_path=input_path,
    #                                             filter_bank=filter_bank,
    #                                             output_path=output_path,
    #                                             ws=ws, segn=segn, omega=omega,
    #                                             nonneg_constraint=nct)
    
    # Show results
    fig, ax = plt.subplots(nrows=1, ncols=2, sharex=True, sharey=True, figsize=(12, 6))
    #
    sat_image = rio.open(input_path)
    rgb_image = satseg.rgb_S2A_image(sat_image)
    # # sat_image = rio.open(output_path)
    # # segmented_output = sat_image.read()
    ax[0].imshow(rgb_image, cmap='terrain')
    ax[1].imshow(segmented_output[0], cmap='terrain')
    
    #
    ax[0].set_title("Original S2A image: patch #%d" % (patch + 1))
    ax[1].set_title("Segmented image (ws = %d)" %(ws))

    print('\nFSEG total run time is about %0.2f seconds or %0.2f minutes.\n' % (time.time() - time0, (time.time() - time0)/60.))

    plt.tight_layout()
    plt.show()
    
    # Save composite image
    output_image_filename = out_dir + "%s_S2A_patch_%d_output__ws%d_ncT.png" % (aoi, patch+1, ws)
    fig.savefig(output_image_filename, bbox_inches='tight', dpi=300)
    


if __name__ == '__main__':
    
    main()


# Factorization-based Segmentation algorithm


## Implementation

This is a Python 3 version of the two original implementations ([Python 2](https://github.com/yuanj07/FSEG_py) and [MATLAB](https://github.com/yuanj07/FSEG)) of the Factorization-based Segmentation algorithm, which fast segments textured images. The algorithm is described in this paper **[Factorization-based texture segmentation](https://doi.org/10.1109/TIP.2015.2446948)** by Yuan et al. (2015).


[Here](https://medium.com/@jiangye07/factorization-based-texture-segmentation-4f8f1dee52d9) is a brief introduction of the algorithm. [Here](https://medium.com/@jiangye07/fast-local-histogram-computation-using-numpy-array-operations-d96eda02d3c) is an explanation of computing local histograms based on integral histograms.   

## Prerequisites

- Python 3
- `Numpy`
- `Scipy`
- `Scikit-image`

## Usage

To try the code, run 

```sh
python fact_based_seg.py
```
This verison implements the complete algorithm, which segments an image in a fully automatic fashion. 

To try the version with given seeds, run

```sh
python fact_based_seg_manseed.py
```

Each seed is a pixel location inside one type of texture. Note that this version represents the basic form of the algorithm and does not include nonnegativity constraint. 

Four test images are provided. 

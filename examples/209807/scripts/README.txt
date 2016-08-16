This example demonstrates a complicated use of LZIFU. This example repeats the analysis presented in Ho et al. (2014, MNRAS, 444, 3894). All the fitting is wrapped into the script run_lzifu_209807.pro.

Simply do 
IDL> .r run_lzifu_209807.pro 
will bring you through the example

The script first fits 1-component to the data to produce 209807_1_comp.fits. Then the script gets the continuum models from 209807_1_comp.fits and make an external continuum model file 209807_ext_cont.fits. The external continuum is then fed to LZIFU to perform 2- and 3-component fitting. Another script merge_209807.pro is then called to merge 1-, 2-, and 3-component cubes into a merged component cube, 209807_merge_comp.fits, following the statistical method described in Ho et al. (2014, MNRAS, 444, 3894) and  Ho et al. (2016, ApS&S, 361, 280). Finally, plot_bpt_209807.pro is called to show the BPT plots of the different components, reproducing Figure 8 in Ho et al. (2014, MNRAS, 444, 3894). Note that the plot is not exactly the same due to different data reduction pipeline versions of SAMI. 

The final outputs pre-run on my machine (stored under products/) are gzipped to save space. 

Note that the data (data/209807_[BR].fits.gz) have been restructured to follow the format required by LZIFU, i.e. different from the standard SAMI format



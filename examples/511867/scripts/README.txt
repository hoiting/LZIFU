This example shows how to fit 1-component to strong emission lines in SAMI. This galaxy is  presented in Figure 3 of Allen et al. (2015, MNRAS, 446, 1567)

Simply do 
IDL> lzifu_511867
to test running LZIFU in 1-cpu mode. You should see 511867_1_comp.fits under ../products/ after the script finishes (will take a while). After that, you can try running with multiple CPUs
IDL> lzifu_511867,ncpu = 6
This time the code will run faster and you should get the same output. 

The final output pre-run on my machine (stored under products/) is gzipped to save space. 

Note that the data (data/511867_[BR].fits.gz) have been restructured to follow the format required by LZIFU, which is different from the standard SAMI format
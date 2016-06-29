This example shows how to fit 1-component to strong emission lines in CALIFA using only the V500 data. LZIFU runs in 1-sided mode. A starmask is provided to mask out a foreground star (data/NGC0776_starmask.fits.gz)

Simply do 
IDL> lzifu_ngc0776
to test running LZIFU in 1-cpu mode. You should see NGC0776_1_comp.fits under ../products/ after the script finishes (will take a while). After that, you can try running with multiple CPUs
IDL> lzifu_ngc0776,ncpu = 6
This time the code will run faster and you should get the same output. 

The final output pre-run on my machine (stored under products/) is gzipped to save space. 


Note that the data (data/lzifu_NGC0776.fits.gz) have been restructured to follow the format required by LZIFU, which is different from the CALIFA format
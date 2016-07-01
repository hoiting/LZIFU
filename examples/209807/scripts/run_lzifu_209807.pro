PRO run_lzifu_209807
	name = '209807'
	redshift = 0.05386
	ncpu = 7
	; run 1-component fit
	lzifu_209807,obj_name = name,z = redshift,fit_ran = [4000,6950 * (1+redshift)],$
	ncpu = ncpu,ncomp = 1,n_smooth_refit = 1

	; extract continuum from 1-component fit, and output them as external continuum models
	b_cont = mrdfits('../products/209807_1_comp.fits','B_CONTINUUM')
	r_cont = mrdfits('../products/209807_1_comp.fits','R_CONTINUUM')
	mwrfits,b_cont,'../products/209807_ext_cont.fits',/create
	mwrfits,r_cont,'../products/209807_ext_cont.fits'

	; run 2-component fit
	lzifu_209807,obj_name = name,z = redshift,fit_ran = [4000,6950 * (1+redshift)],$
	ncpu = ncpu,ncomp = 2,supply_ext_cont = 1, $
	ext_cont_path = '../products/',ext_cont_name = '209807_ext_cont.fits', $
	n_smooth_refit = 2

	; run 3-component fit 
	lzifu_209807,obj_name = name,z = redshift,fit_ran = [4000,6950 * (1+redshift)],$
	ncpu = ncpu,ncomp = 3,supply_ext_cont = 1, $
	ext_cont_path = '../products/',ext_cont_name = '209807_ext_cont.fits', $
	n_smooth_refit = 2

	; merge different fits
	merge_209807	

	; plot BPT. Reproduce Fig 8 in Ho et al. (2014)
	plot_bpt_209807
	
END
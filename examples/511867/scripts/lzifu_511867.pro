PRO lzifu_511867,_extra=extra
; This is for 511867
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set = { Settings, $
only_1side             : 0                 , $  ; 0: 2-sided data. 1: 1-sided data
; For fitting
obj_name               : '511867'          , $  ; Object name
z                      :  0.0552           , $  ; Redshift
;;;;;;;;;;;;;;;;;;    Fitting range and masking    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fit_ran                : [3700,6950 * (1+0.0552)],$          ; fitting range in A
b_ext_mask             : [[5577-10,5577+10]], $	; Sky line at 5577
r_ext_mask             : [[6300-10,6300+10],$   ; Sky line at 6300
                          [5577-10,5577+10],$   ; Sky line at 5577
                          [6360-10,6360+10],$   ; Sky line at 6360
                          [7340-10,7340+10]], $ ; Sky line at 7340                          
ext_mask               : [[5577-10,5577+10], $	; Sky line at 5577
                          [6360-10,6360+10]],$  ; Sky line at 6360
;;;;;;;;;;;;;;;;;;;;;;;;;;;   Data resolution    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
b_resol_sigma          : 1.15         , $       ; data resolution in Angstrom 
r_resol_sigma          : 0.72         , $       ; data resolution in Angstrom
resol_sigma            : 0.72         , $       ; data resolution in Angstrom
;;;;;;;;;;;;;;;;;;;; External continuum model   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
supply_ext_cont      : 0, $                     ; 1 = YES, I want to provide external continuum. 0 = NO. 
ext_cont_path        : '../products/',$         ; path to external continuum model
ext_cont_name        : '',$                     ; external continuum model name
load_ext_cont_func   : 'lzifu_load_ext_cont',$  ; 
;;;;;;;;;;;;;;;;;;;;;;;;;  External 2D mask   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1 = I want to fit this spaxel. 0 = I don't want to fit this spaxel.
supply_mask_2d        : 0 , $                   ; 1 = YES. Use external 2d mask. 0 = No. Don't use. Fit all spaxels possible. 
mask_2d_path          : '', $                   ; path of the 2d mask file.
mask_2d_name          : '', $                   ; name of the 2d mask file. 
load_mask_2d_func     : 'lzifu_load_2d_mask', $ ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   Data I/O   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_path              : '../data/',$                   ; path to data
product_path           : '../products/',$                   ; path to output
load_cube_func         : 'lzifu_load_cube', $   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;   SSP template   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
temp_resol_sigma       : 0.3, $   	            ; template resolution  
template_path          : '../../../stellar_models/gonzalezdelgado/',$ ;template path 
template_name          : ['cond_SSPPadova_z004.sav','cond_SSPPadova_z008.sav','cond_SSPPadova_z019.sav'], $ ; template names
;;;;;;;;;;;;;;;;;   Continuum fitting with ppxf   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mask_width             : 40.,$                   ; Full width to mask around emission lines defined in lzifu_linelist.pro
cont_vel_sig_guess     : [0.,50.], $             ; Starting guess of delV and vel_dispersion of continuum (in km/s)
cont_ebv_guess         : 0.1      , $            ; Starting guess of ebv
degree                 : 4  , $                  ; Additive Legendre polynomial simultaneously fitted with continuum (-1 for no polynomials).
mdegree                : 0  , $                  ; Multiplicative Legendre polynomial (0 for no polynomials)
moments                : 2  , $                  ; Order of the Gauss-Hermite moments. Can only be 2,4,6 [recommend: 2]
r_resid_degree         : -1 , $                  ; Degree for fitting residual (red). -1 = don't fit. 
b_resid_degree         : -1 , $                  ; Degree for fitting residual (blue).  -1 = don't fit. 
resid_degree           : -1 , $                  ; Degree for fitting residual (one-sided).  -1 = don't fit. 
ppxf_clean             : 0  , $                  ; use CLEAN keyword in ppxf? 1 = YES. 0 = No.
;;;;;;;;;;;;;;;;;   Eission fitting with mpfit   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fit_dlambda            : 40       , $            ; Full width around line centers to be fitted. (A)
ncomp                  : 1        , $            ; Number of component. 
line_sig_guess         : 50       ,$             ; Initial guess of velocity dispersion for emission line (km/s)
vdisp_ran              : [-50,1000],$            ; Velocity dispersion constraints in km/s. 
vel_ran                : [-600.,+600.],$         ; Velocity contraints in km/s. 0 is systemic velocity from set.z
sort_type              : 'vdisp', $              ; 'vdisp', 'vel' or linelabel in linelist_func. Component sorting method. 
; variation in initial guess
comp_2_damp            : [0.4],$
comp_2_dvel            : [+150,+75,0,-75,-150],$
comp_2_dvdisp          : [+60],$
comp_3_damp            : [0.3],$
comp_3_dvel            : [-50, +50],$
comp_3_dvdisp          : [+200],$
; Re-fit with smoothed initial guess?
n_smooth_refit       : 1       , $             ; Number of iterations
smooth_width         : 5        , $            ; Spatial width (pixel) of smoothing
; What lines to fit? what lines to mask?
linelist_func          : 'lzifu_linelist_511867', $     ; Name of linelist function
; Run mode
ncpu                   : 1 $                      ; Max number of CPUs used. 1 - 15  (> 1 for parallel processing)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;   modify below only if you know what you're doing     ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; overwrite set with extra
	if exist(extra) then begin
		set = join_struct(extra,set)   
	endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;; High level scripts ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!EXCEPT = 0
	start_time = systime(/second)

	; Add more parameter to set. Some of the values will be filled in later by other scripts. 
	set = lzifu_add_set(set)
	
	; Load data cube
	datacube = call_function(set.load_cube_func,set)

	; Continuum and line fitting	
	fit_list = lzifu_loop_spaxel(datacube,set)

	; Free memory
	data = 0

	; Refit with smoothed initial guess
	for i=0,set.n_smooth_refit-1 do $
		fit_list = lzifu_smooth_refit(fit_list,set)

	; Make cubes. Turn fit_list into cubes
	out_cubes = lzifu_make_cubes(fit_list,set)
	
	; Turn fit_list into images
	out_images = lzifu_make_images(fit_list,set)

	; Free some memory
	fit_list = 0

	; Write out_cubes, out_images, set into a single fits file
	lzifu_output_fits,set,out_cubes,out_images

	print,'Total run time:',(systime(/second) - start_time)/60,'minutes'
END

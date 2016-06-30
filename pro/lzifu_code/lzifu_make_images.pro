PRO cal_flux,peak,peak_err,vdisp,vdisp_err,linewidth,linewavez,covar_peak_vdisp,flux,flux_err
	light_speed = 2.99792458e5 ; speed of light, km/s
	; error propagation!!
	; F = linewidth * peak * 2.50663 ; = sqrt(2*!PI)
	; linewidth = sqrt( (vdisp * linewavez/c)^2 + inst_disp^2 )
	flux = linewidth * peak
	df_dvdisp = peak^2 / flux * vdisp * (linewavez/light_speed)^2
	df_dpeak = linewidth
	flux_err = sqrt( df_dvdisp^2 * vdisp_err^2 + df_dpeak^2 * peak_err^2 + $
	           2 * df_dvdisp * df_dpeak * covar_peak_vdisp )
	flux = flux * sqrt(2*!PI)
	flux_err = flux_err * sqrt(2*!PI)
END

FUNCTION cal_flux_sum_err,iveldisp,ifoff,isoff,param,covar,linewavez,ncomp
	light_speed = 2.99792458e5 ; speed of light, km/s
	; calculate errors for summed fluxes. propagate covariance
	; F = sqrt(2*!PI) * sum_i(linewidth_i * peak*i) 
	; Calculate Jacobian first, then err = J * covar * J^T
	; Jacobian = [dF/dvdisp1,...,dF/dpeak1,...]
	; dF/dvdisp1 = p1 * vdisp1/linewidth1* linewavez^2/light_speed^2
	; dF/dpeak1  = linewidth1
	; linewidth = sqrt( (vdisp * linewavez/c)^2 + inst_disp^2 )
	Jacob = fltarr(ncomp * 2)
	; dF/dvdisp
	Jacob[0:ncomp-1] = param[ifoff] * param[iveldisp] / param[isoff] * (linewavez / light_speed)^2
	; dF/dpeak
	Jacob[ncomp:*] = param[isoff]
	; extract covariance
	sub_covar = fltarr(ncomp*2,ncomp*2)
	index = [iveldisp,ifoff]
	for i=0,ncomp*2-1 do $
		for j=0,ncomp*2 -1 do $
			sub_covar[i,j] = covar[index[i],index[j]]
	; calculate variance
	var = jacob ## sub_covar ## transpose(jacob)
	sig = sqrt(var) * sqrt(2*!PI)
	return,sig[0]
END


FUNCTION lzifu_make_images,fit_list,set
	;images = lzifu_make_images(fit_list,set)
	light_speed = 2.99792458e5 ; speed of light, km/s
	print,'Making images'
    
	linelist = call_function(set.linelist_func,/fit_line)
	linewave  = linelist.wave
	linewavez = linelist.wave * (1 + set.z)
	linelabel = linelist.label
    nline = n_elements(linelabel)

	; images. n x m x nline x (ncomp+1)
	; ncomp+1 = [total, 1st comp, 2nd comp, 3rd comp, ...]
	line_images       = fltarr(set.xsize,set.ysize,nline,set.ncomp+1) + !values.f_nan
	line_err_images   = line_images
	; z (v) and vdisp images. n x m x (ncomp+1)
	z_images          = fltarr(set.xsize,set.ysize,set.ncomp+1) + !values.f_nan
	z_err_images      = z_images
	vdisp_images      = z_images
	vdisp_err_images  = z_images
    ; chi2, dof n x m (only 2d)
    chi2 = fltarr(set.xsize,set.ysize) + !values.f_nan
	dof  = fltarr(set.xsize,set.ysize) + !values.f_nan
	cont_chi2 = fltarr(set.xsize,set.ysize) + !values.f_nan

	star_v          =  fltarr(set.xsize,set.ysize) + !values.f_nan
	star_v_err      =  star_v
	star_vdisp      =  star_v
	star_vdisp_err  =  star_v
	star_ebv        =  star_v
	del_b_lambda	  = star_v
	del_b_lambda_err  = star_v
	
    ; Loop through fit_list and put things in 2d images
	for i = 0,n_elements(fit_list)-1 do begin
		dum = fit_list[i]

		; if continuum is fit, output stellar velocity, velocity dispersion
		star_v[dum.i,dum.j]          =  tag_exist(dum,'starvel')       ? dum.starvel       : !values.f_nan
		star_v_err[dum.i,dum.j]      =  tag_exist(dum,'starvel_err')   ? dum.starvel_err   : !values.f_nan
		star_vdisp[dum.i,dum.j]      =  tag_exist(dum,'starvdisp')     ? dum.starvdisp     : !values.f_nan
		star_vdisp_err[dum.i,dum.j]  =  tag_exist(dum,'starvdisp_err') ? dum.starvdisp_err : !values.f_nan
		star_ebv[dum.i,dum.j]        =  tag_exist(dum,'starebv')       ? dum.starebv       : !values.f_nan
		cont_chi2[dum.i,dum.j]       =  tag_exist(dum,'cont_chi2')     ? dum.cont_chi2     : !values.f_nan


		; calculate the fluxes and then put them in line_images and line_images_err
		if ~ tag_exist(dum,'param') then continue
		if ~ tag_exist(dum,'status')  then continue
		if dum.status LE 0 then continue
		param = dum.param & perror = dum.perror & covar = dum.covar

		; chi2, dof, del_b_lambda map
		chi2[dum.i,dum.j]                  = dum.red_chi2
		dof[dum.i,dum.j]                   = dum.dof
		del_b_lambda [dum.i,dum.j]         = param[2]
		del_b_lambda_err[dum.i,dum.j]      = perror[2]

		ppoff = param[0]
		; Sorting
		order = lzifu_sort_order(param,set)


		for c = 0,set.ncomp -1 do begin
			icomp = order[c]
			iz       = ppoff + icomp * 2 
			iveldisp = ppoff + icomp * 2 + 1
			ifoff = ppoff + set.ncomp * 2 + indgen(nline)*3 + icomp * nline * 3   ;peak flux
			iwoff = ifoff + 1  ;wavelength
			isoff = ifoff + 2  ;sigma 
							
			; normal cases. no additional constraints
			cal_flux,param[ifoff],perror[ifoff],param[iveldisp],perror[iveldisp],param[isoff],linewavez,$
               	     covar[ifoff,iveldisp],flux,flux_err

			; if err is 0 (touches boundary) or lines not fit, set flux_err and flux to nan
			badlines = where(perror[ifoff] eq 0 or param[ifoff] eq 0 or param[ifoff] eq set.minfluxconst,badcnt)
			if badcnt gt 0 then begin 
				flux[badlines]      = !values.f_nan
				flux_err[badlines]  = !values.f_nan
			endif
			; put results in images
			line_images[dum.i,dum.j,*,c+1]     = flux
			line_err_images[dum.i,dum.j,*,c+1] = flux_err
			z_images[dum.i,dum.j,c+1]          = param[iz]
			z_err_images[dum.i,dum.j,c+1]      = perror[iz]
			vdisp_images[dum.i,dum.j,c+1]      = param[iveldisp]
			vdisp_err_images[dum.i,dum.j,c+1]  = perror[iveldisp]
		endfor   ; component loop
			

		;calculate sum of fluxes of each line. with covariance propagated. 
		iz       = ppoff + indgen(set.ncomp) * 2 
		iveldisp = ppoff + indgen(set.ncomp) * 2 + 1
		for iline = 1,nline do begin
			ifoff    = iveldisp[-1] + indgen(set.ncomp) * nline * 3 + (iline -1 ) * 3 + 1   ;peak flux
			iwoff    = ifoff + 1  ;wavelength
			isoff    = ifoff + 2  ;sigma 
			flux_sum_err = cal_flux_sum_err(iveldisp,ifoff,isoff,param,covar,linewavez[iline-1],set.ncomp)
			flux_sum = total(line_images[dum.i,dum.j,iline-1,1:set.ncomp],4,/nan) ; Note that total(NaNs) = 0.
			; zeroth slice is the sum
			; flux
			line_images[dum.i,dum.j,iline-1,0] = flux_sum EQ 0 ? !values.f_nan : flux_sum
			; flux_err
			line_err_images[dum.i,dum.j,iline-1,0] = flux_sum_err EQ 0 ? !values.f_nan : flux_sum_err
		endfor	; line loop. for sum fluxes with covariance propagation.
		; if any vdisp or z touches boundary, set all measurements and errors to nan
		void = where(perror[iz] eq 0,cnt1)
		void = where(perror[iveldisp] eq 0,cnt2)
		if cnt1 NE 0 or cnt2 NE 0 then begin
			message,'You should never see this message. z or vdisp touch boundaries. status should be -99 and should have been rejected earlier in the process',$
			        /continue
			line_images[dum.i,dum.j,*,*]      = !values.f_nan
			line_err_images[dum.i,dum.j,*,*]  = !values.f_nan
			z_images[dum.i,dum.j,*,*]         = !values.f_nan
			z_err_images[dum.i,dum.j,*,*]     = !values.f_nan
			vdisp_images[dum.i,dum.j,*,*]     = !values.f_nan
			vdisp_err_images[dum.i,dum.j,*,*] = !values.f_nan
			chi2[dum.i,dum.j]                 = !values.f_nan
			dof[dum.i,dum.j]                  = !values.f_nan
		endif		
		; special treatments for o3_4959 o3_5007. remove 4959 results.
		linea = where(linelabel eq 'OIII4959',cnta)
		lineb = where(linelabel eq 'OIII5007',cntb)
		if cnta eq 1 and cntb eq 1 then begin
			line_images[dum.i,dum.j,linea,*]      = !values.f_nan
			line_err_images[dum.i,dum.j,linea,*]  = !values.f_nan
		endif				
		; special treatments for n2. remove 6548 results. 
		linea = where(linelabel eq 'NII6548',cnta)
		lineb = where(linelabel eq 'NII6583',cntb)
		if cnta eq 1 and cntb eq 1 then begin
			line_images[dum.i,dum.j,linea,*]      = !values.f_nan
			line_err_images[dum.i,dum.j,linea,*]  = !values.f_nan
		endif

	endfor           ; fit_list loop 

	; turn z to v
	v_images = (z_images - set.z[0]) * light_speed
	v_err_images = (z_err_images) * light_speed
	; return a structure "images" containing all the 2d images. 
	images = {v            : v_images, $
	          v_err        : v_err_images,$
			  chi2         : chi2 , $
	          dof          : dof ,  $
	          vdisp        : vdisp_images, $
	          vdisp_err    : vdisp_err_images, $
	          del_b_lambda : [[[del_b_lambda]],[[del_b_lambda_err]]]}
	
	for i = 0,n_elements(linelabel)-1 do begin
		label = linelabel[i]
		images = add_tag(images,reform(line_images[*,*,i,*]),label)	
		images = add_tag(images,reform(line_err_images[*,*,i,*]),label+'_ERR')	
	endfor

	if set.supply_ext_cont EQ 0 then begin	; stellar ppxf part. only do when external continuum is not provided	          
		images = add_tag(images, cont_chi2,'cont_chi2')
		images = add_tag(images, [[[star_v]],[[star_v_err]]],'star_v')
		images = add_tag(images, [[[star_vdisp]],[[star_vdisp_err]]],'star_vdisp')
		images = add_tag(images, star_ebv,'star_ebv')
	endif		

	return,images
END
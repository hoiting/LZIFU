FUNCTION lzifu_fit_continuum,data,b_template,r_template,set
	; A customized implementation of PPXF
	light_speed = 299792.458 ; speed of light in km/s
;	name = tag_names(data)
;	for c=0,n_elements(name)-1 do dum=execute(name[c]+'=data.'+name[c])

	; Initialize emission linelist for masking out emission lines
	linelist = call_function(set.linelist_func,/mask_line)
	nlines = n_elements(linelist.wave)
	; Redshift emission line list
	linewavez = linelist.wave * (1+set.z)

	;;;;;;;;;;;;;;;;;;; Form a merged spectrum for continuum fitting ;;;;;;;;;;;;;;;;;;;;;;;;
	; Use lower resolution one as base
	if set.only_1side EQ 0 then begin ; two-sided data
		if set.b_resol_sigma GT set.r_resol_sigma then begin ; B has poorer resolution
			br_channel_width = set.b_channel_width
			; put on B grid
			n_channel = (max(data.r_lambda)-min(data.b_lambda))/br_channel_width - 1
			br_lambda = findgen(n_channel)*br_channel_width + min(data.b_lambda)
			;;;; convolve r to the same resolution as b
			dumflux = data.r_flux & dumflux_err = data.r_flux_err & dum = where(data.r_mask eq 0,cnt)
			if cnt ge 1 then begin 
				dumflux[dum] = !values.f_nan
				dumflux_err[dum] = !values.f_nan
			endif
			kernel_sigma = sqrt(set.b_resol_sigma^2 - set.r_resol_sigma^2)/set.r_channel_width
			kernel = gaussian_function(kernel_sigma,width = 11*kernel_sigma,/normalize)
			r_flux_lores = convol(dumflux,kernel,/nan,/edge_truncate)	
			b_flux_lores = data.b_flux
			r_flux_err_lores = sqrt( convol(dumflux_err^2,kernel^2,/nan,/edge_truncate) )
			b_flux_err_lores = data.b_flux_err				
		endif else begin   ; R has poorer resolution
			br_channel_width = set.r_channel_width
			; put on R grid
			n_channel = (max(data.r_lambda)-min(data.b_lambda))/br_channel_width - 1
			br_lambda = findgen(n_channel)*br_channel_width + min(data.b_lambda)
			;;;; convolve b to the same resolution as r
			dumflux = data.b_flux & dumflux_err = data.b_flux_err & dum = where(data.b_mask eq 0,cnt)
			if cnt ge 1 then begin 
				dumflux[dum] = !values.f_nan
				dumflux_err[dum] = !values.f_nan
			endif
			kernel_sigma = sqrt(set.r_resol_sigma^2 - set.b_resol_sigma^2)/set.b_channel_width
			kernel = gaussian_function(kernel_sigma,width = 11*kernel_sigma,/normalize)
			b_flux_lores = convol(dumflux,kernel,/nan,/edge_truncate)
			r_flux_lores = data.r_flux
			b_flux_err_lores = sqrt( convol(dumflux_err^2,kernel^2,/nan,/edge_truncate) )
			r_flux_err_lores = data.r_flux_err
		endelse
			; put on the same grid. 
			dumflux = [b_flux_lores,r_flux_lores]
			dumfluxerr = [b_flux_err_lores,r_flux_err_lores]  
			dumlambda = [data.b_lambda,data.r_lambda]
			dummask = [data.b_mask,data.r_mask] & dummaskind = where(dummask eq 0,compl = dummaskind_c)
			if cnt ge 1 then dumflux[dummaskind] = !values.f_nan
			if cnt ge 1 then dumfluxerr[dummaskind] = !values.f_nan
			dum = sort(dumlambda)
			br_flux = interpol(dumflux[dum],dumlambda[dum],br_lambda,/nan)			; this is an approximation
			br_flux_err = interpol(dumfluxerr[dum],dumlambda[dum],br_lambda,/nan)	; this is an approximation
			br_mask = replicate(0,n_elements(br_lambda))
			for c=0,n_elements(dummaskind_c)-1 do begin 
				dum2 = where(br_lambda gt dumlambda[dummaskind_c[c]]-br_channel_width and br_lambda lt dumlambda[dummaskind_c[c]]+br_channel_width,cnt2)
				if cnt2 ge 1 then br_mask[dum2] = 1
			endfor
	endif else begin ; one-sided data
		br_flux     = data.r_flux
		br_flux_err = data.r_flux_err
		br_mask     = data.r_mask
		br_lambda   = data.r_lambda
	endelse
	;;;;;;;;;;;;;;;;;;;;; Merging completed  ;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Make a template for the merged spectrum
	;  Redshift stellar templates
	if set.only_1side EQ 0 then begin  ; two-sided data
		templatelambdaz = b_template.lambda * (1 + set.z)
		if set.b_resol_sigma GT set.r_resol_sigma then begin ; B has poorer resolution
			br_temp = lzifu_interpol_template(br_lambda, templatelambdaz, b_template.flux / (1 + set.z[0]) )
		endif else begin   ; R has poorer resolution
			br_temp = lzifu_interpol_template(br_lambda, templatelambdaz, r_template.flux / (1 + set.z[0]) )	
		endelse

		; interpolate b and r template
		b_temp = lzifu_interpol_template(data.b_lambda, templatelambdaz, b_template.flux / (1 + set.z[0]) )
		r_temp = lzifu_interpol_template(data.r_lambda, templatelambdaz, r_template.flux / (1 + set.z[0]) )

		; Mask emission lines
		br_ct_indx  = lzifu_mask_emission(br_lambda, linewavez, replicate(set.mask_width / 2,n_elements(linewavez)))
		br_gd_indx   = where(br_mask EQ 1, complement=br_gd_indx_c)
		br_ct_indx   = cmset_op(br_ct_indx,'AND',br_gd_indx)       ; good continuum
		br_cont_mask = br_mask*0 & br_cont_mask[br_ct_indx]=1
		b_ct_indx   = lzifu_mask_emission(data.b_lambda, linewavez, replicate(set.mask_width / 2,n_elements(linewavez)))
		b_gd_indx   = where(data.b_mask EQ 1, complement=b_gd_indx_c)
		b_ct_indx   = cmset_op(b_ct_indx,'AND',b_gd_indx)       ; good continuum
		b_cont_mask = data.b_mask*0 
		if b_ct_indx[0] NE -1 then b_cont_mask[b_ct_indx]=1
		r_ct_indx   = lzifu_mask_emission(data.r_lambda, linewavez, replicate(set.mask_width / 2,n_elements(linewavez)))
		r_gd_indx   = where(data.r_mask EQ 1, complement=r_gd_indx_c)
		r_ct_indx   = cmset_op(r_ct_indx,'AND',r_gd_indx)       ; good continuum
		r_cont_mask = data.r_mask*0 
		if r_ct_indx[0] NE -1 then r_cont_mask[r_ct_indx]=1
		; if too few channels (<10% of the number of channels) then return
		if n_elements(b_ct_indx) + n_elements(r_ct_indx) LT 0.1 * (set.b_zsize + set.r_zsize) then begin
			data = add_tag(data,-1,'cont_status')
			return,data
		endif
	endif else begin  ; one-sided data
		templatelambdaz = r_template.lambda * (1 + set.z)
		br_temp = lzifu_interpol_template(br_lambda, templatelambdaz, r_template.flux / (1 + set.z) )	
		; Mask emission lines
		br_ct_indx  = lzifu_mask_emission(br_lambda, linewavez, replicate(set.mask_width / 2,n_elements(linewavez)))
		br_gd_indx   = where(br_mask EQ 1, complement=br_gd_indx_c)
		br_ct_indx   = cmset_op(br_ct_indx,'AND',br_gd_indx)       ; good continuum
		br_cont_mask = br_mask*0 & br_cont_mask[br_ct_indx]=1
		r_ct_indx   = lzifu_mask_emission(data.r_lambda, linewavez, replicate(set.mask_width / 2,n_elements(linewavez)))
		r_gd_indx   = where(data.r_mask EQ 1, complement=r_gd_indx_c)
		r_ct_indx   = cmset_op(r_ct_indx,'AND',r_gd_indx)       ; good continuum
		r_cont_mask = data.r_mask*0 
		if r_ct_indx[0] NE -1 then r_cont_mask[r_ct_indx]=1
		; if too few channels (<10% of the number of channels) then return
		if n_elements(r_ct_indx) LT 0.1 * (set.r_zsize) then begin
			data = add_tag(data,-1,'cont_status')
			return,data
		endif
	endelse
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;; Now ready to do continuum subtraction with ppxf   ;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; log rebin for ppxf
	if set.only_1side EQ 0 then begin  ; two-sided data
		; decide velocity scale for log_regin
		; use whichever smaller in B and R  
		velScale = br_channel_width/min(br_lambda) * light_speed
		br_lamrange=[min(br_lambda),max(br_lambda)]
		b_lamrange=[min(data.b_lambda),max(data.b_lambda)]
		r_lamrange=[min(data.r_lambda),max(data.r_lambda)]

		log_rebin,br_lamrange, br_flux, br_flux_rebin, br_logLam, VELSCALE=velScale
		log_rebin,br_lamrange, br_flux_err^2, dum, br_logLam, VELSCALE=velScale & br_flux_err_rebin = sqrt(dum)
		log_rebin,br_lamrange, br_cont_mask, br_cont_mask_rebin, br_logLam, VELSCALE=velScale
		br_ct_indx = where(abs(br_cont_mask_rebin) gt 0.99 and finite(br_flux_rebin) and finite(br_flux_err_rebin) and br_flux_err_rebin gt 0,complement=ind_c)
		if ind_c[0] NE -1 then br_cont_mask_rebin[ind_c] = 0

		; log rebin template for composite spectrum
		tempsize = set.n_metal * set.n_age
		br_temp_rebin = fltarr(n_elements(br_flux_rebin),tempsize)
		for c = 0, tempsize-1 do begin
			log_rebin, r_lamrange, r_temp[*,c], r_dum, r_loglam, VELSCALE=velScale 
			log_rebin, b_lamrange, b_temp[*,c], b_dum, b_loglam, VELSCALE=velScale 
			log_rebin, br_lamrange, br_temp[*,c], br_dum, VELSCALE=velScale  
			br_temp_rebin[*,c] = br_dum 
			if c eq 0 then begin
				r_temp_rebin = fltarr(n_elements(r_dum),tempsize)
				b_temp_rebin = fltarr(n_elements(b_dum),tempsize)
			endif
				r_temp_rebin[*,c] = r_dum 
				b_temp_rebin[*,c] = b_dum	
		endfor
	endif else begin  ; one-sided data
		; decide velocity scale for log_regin
		; use whichever smaller in B and R  
		velScale = set.r_channel_width/min(br_lambda) * light_speed
		br_lamrange=[min(br_lambda),max(br_lambda)]

		log_rebin,br_lamrange, br_flux, br_flux_rebin, br_logLam, VELSCALE=velScale
		log_rebin,br_lamrange, br_flux_err^2, dum, br_logLam, VELSCALE=velScale & br_flux_err_rebin = sqrt(dum)
		log_rebin,br_lamrange, br_cont_mask, br_cont_mask_rebin, br_logLam, VELSCALE=velScale
		br_ct_indx = where(abs(br_cont_mask_rebin) gt 0.99 and finite(br_flux_rebin) and finite(br_flux_err_rebin) and br_flux_err_rebin gt 0,complement=ind_c)
		if ind_c[0] NE -1 then br_cont_mask_rebin[ind_c] = 0

		; log rebin template for composite spectrum
		tempsize = set.n_metal * set.n_age
		br_temp_rebin = fltarr(n_elements(br_flux_rebin),tempsize)
		for c = 0, tempsize-1 do begin
			log_rebin, br_lamrange, br_temp[*,c], br_dum, VELSCALE=velScale  
			br_temp_rebin[*,c] = br_dum 
		endfor
	endelse	

	; normalize template and data to avoid numerical issues. 
	temp_norm_factor = median(br_temp_rebin,/double)
	data_norm_factor = abs(median(br_flux_rebin[br_ct_indx],/double))
	if data_norm_factor LT 1e-25 then begin  
		data_norm_factor = 1. ; if too small don't normalize. usually something is wrong. print a message
		message,"Median value of the data is very small. Something might be wrong. LZIFU don't normalize this spaxel...",/continue
	endif
	; floating point limits: print,(MACHAR()).xmin,(MACHAR()).xmax
	if temp_norm_factor LT 1e-25 then begin
		temp_norm_factor = 1.
		message,"Median value of the template is very small. Something might be wrong. LZIFU don't normalize templates...",/continue		
	endif

	if set.only_1side EQ 0 then begin ; 2-sided data
		br_temp_rebin = br_temp_rebin / temp_norm_factor
		b_temp_rebin = b_temp_rebin / temp_norm_factor
		r_temp_rebin = r_temp_rebin / temp_norm_factor
	
		br_flux_rebin = br_flux_rebin / data_norm_factor
		br_flux_err_rebin = br_flux_err_rebin / data_norm_factor
	endif else begin ; 1-sided data 
		br_temp_rebin = br_temp_rebin / temp_norm_factor

		br_flux_rebin = br_flux_rebin / data_norm_factor
		br_flux_err_rebin = br_flux_err_rebin / data_norm_factor
	endelse
	
	start  = set.cont_vel_sig_guess
	br_ebv = set.cont_ebv_guess

	;; ppxf doesn't like flux_err = 0
	br_ind_tmp=where(br_flux_err_rebin LE 0 OR ~finite(br_flux_rebin) OR ~finite(br_flux_err_rebin),cnt)
	if cnt gt 0 then br_flux_err_rebin[br_ind_tmp]=1e+10
	;; ppxf doesn't like flux = nan
	ind_tmp = where(~finite(br_flux_rebin),cnt)
	if cnt gt 0 then br_flux_rebin[ind_tmp] = 0

	; PPXF continuum fitting
	if set.mdegree le 0 then begin 	; if WITHOUT multiplicative polynomial
		cmd = set.ppxf_name + ', float(br_temp_rebin),float(br_flux_rebin),float(br_flux_err_rebin),velScale,start,'+$
		'br_sol,BESTFIT=br_logcontinuum, BIAS=br_bias, GOODPIXELS=br_ct_indx,' +$
		'LAMBDA=float(exp(br_loglam)/(1+set.z)), REDDENING=br_ebv,'+$
		'DEGREE = set.degree, WEIGHTS = br_starcoeff, error = br_sol_err, POLYWEIGHTS = br_polyweights,' +$
		'clean = set.ppxf_clean, moments = set.moments'
		exec_status = execute(cmd)
		; if ppxf failed then return
		if exec_status NE 1 then begin
			data = add_tag(data,-1,'cont_status')
			return,data		
		endif
	endif else begin ; if WITH multiplicative polynomial
		cmd = set.ppxf_name + ', float(br_temp_rebin),float(br_flux_rebin),float(br_flux_err_rebin),velScale,start,'+$
		'br_sol,BESTFIT=br_logcontinuum, BIAS=br_bias, GOODPIXELS=br_ct_indx,' +$
		'LAMBDA=float(exp(br_loglam)/(1+set.z)),' +$
		'DEGREE = set.degree, MDEGREE = set.mdegree, WEIGHTS = br_starcoeff, error = br_sol_err, POLYWEIGHTS = br_polyweights,' +$
		'clean = set.ppxf_clean, moments = set.moments'
		exec_status = execute(cmd)
		; if ppxf failed then return
		if exec_status NE 1 then begin
			data = add_tag(data,-1,'cont_status')
			return,data		
		endif
		br_ebv = !values.f_nan ; no ebv if with multiplicative
	endelse
	
	; update b_cont_mask, r_cont_mask, b_ct_indx and r_ct_indx if uses ppxf_clean
	if set.ppxf_clean EQ 1 then begin
		if set.only_1side EQ 0 then begin ; two-sided data
			old_b_cont_mask = b_cont_mask
			old_r_cont_mask = r_cont_mask
			br_cont_mask_rebin[*] =  0
			br_cont_mask_rebin[br_ct_indx] = 1
			b_cont_mask = interpol(br_cont_mask_rebin, exp(br_loglam),data.b_lambda)
			r_cont_mask = interpol(br_cont_mask_rebin, exp(br_loglam),data.r_lambda)
			b_ct_indx = where(b_cont_mask EQ 1 and old_b_cont_mask eq 1,complement=ind_c,cnt)
			if ind_c[0] NE -1 then b_cont_mask[ind_c] = 0
			r_ct_indx = where(r_cont_mask EQ 1 and old_r_cont_mask eq 1,complement=ind_c,cnt)
			if ind_c[0] NE -1 then r_cont_mask[ind_c] = 0
		endif else begin ; one-sided data 
			old_r_cont_mask = r_cont_mask
			br_cont_mask_rebin[*] =  0
			br_cont_mask_rebin[br_ct_indx] = 1
			r_ct_indx = where(r_cont_mask EQ 1 and old_r_cont_mask eq 1,complement=ind_c,cnt)
			if ind_c[0] NE -1 then r_cont_mask[ind_c] = 0
		endelse
	endif

	;;; scale error with red_chi2. this assumes fit is good.
	br_sol_err = br_sol_err*sqrt(br_sol[6])
	br_continuum = interpol(br_logcontinuum,exp(br_loglam),br_lambda) * data_norm_factor


	; Now once the results is out. Use the stellar coefficient to get continuum models for 
	; the blue and the red
	; range of the merged spectrum. lzifu_remake_ppxf_bestfit needs this to know how to interpret additive/multiplicative legendre polynomial
	range = [min(exp(br_loglam)/(1+set.z)),max(exp(br_loglam)/(1+set.z))]
	if set.mdegree le 0 then begin  ; fit reddening
		if set.moments eq 2 then $
			res = [br_sol[0:1]/velScale ,br_ebv] 
		if set.moments gt 2 then $
			res = [br_sol[0:1]/velScale ,br_sol[2: 2 + set.moments-2-1],br_ebv]
	endif else begin ; did not fit reddening	
		if set.moments eq 2 then $   
			res = [br_sol[0:1]/velScale,br_sol[-set.mdegree:-1]] $
		else $
			res = [br_sol[0:1]/velScale,br_sol[2: 2+set.moments-2-1],br_sol[-set.mdegree:-1]]
	endelse
	
	if set.only_1side EQ 0 then begin ; two-sided data
		; for the blue:
		b_recon = lzifu_remake_ppxf_bestfit(res, DEGREE=set.degree, MDEGREE=set.mdegree,$
		STAR=b_temp_rebin, WEIGHTS=br_starcoeff,$
		LAMBDA=float(exp(b_loglam)/(1+set.z[0])), RANGE = range, $
		POLYWEIGHTS = br_polyweights)
		b_logcontinuum = b_recon.bestfit & b_logaddpoly = b_recon.addpoly & b_logmpoly = b_recon.mpoly
						
		; for the red
		r_recon = lzifu_remake_ppxf_bestfit(res, DEGREE=set.degree, MDEGREE=set.mdegree,$
		STAR=r_temp_rebin, WEIGHTS=br_starcoeff,$
		LAMBDA=float(exp(r_loglam)/(1+set.z[0])), RANGE = range, $
		polyweights = br_polyweights)
		r_logcontinuum = r_recon.bestfit & r_logaddpoly = r_recon.addpoly & r_logmpoly = r_recon.mpoly

		; Fit residual with combination of Legendre Polynomial with bvls (simliar to what ppxf does)
		b_continuum = interpol(b_logcontinuum,exp(b_loglam),data.b_lambda) 
		r_continuum = interpol(r_logcontinuum,exp(r_loglam),data.r_lambda) 
		b_addpoly   = interpol(b_logaddpoly,exp(b_loglam),data.b_lambda) 
		r_addpoly   = interpol(r_logaddpoly,exp(r_loglam),data.r_lambda) 
		b_mpoly     = interpol(b_logmpoly,exp(b_loglam),data.b_lambda) 
		r_mpoly     = interpol(r_logmpoly,exp(r_loglam),data.r_lambda) 

		b_residual = data.b_flux/data_norm_factor - b_continuum
		r_residual = data.r_flux/data_norm_factor - r_continuum

		r_residfit = lzifu_fit_residual(data.r_lambda,r_residual,data.r_flux_err, $
		                                degree = set.r_resid_degree,goodpixels = r_ct_indx)
		r_cont_mask = r_cont_mask * 0 & if r_ct_indx[0] NE -1 then r_cont_mask[r_ct_indx] = 1

		b_residfit = lzifu_fit_residual(data.b_lambda,b_residual,data.b_flux_err, $ 
		                                degree = set.b_resid_degree,goodpixels = b_ct_indx)
		b_cont_mask = b_cont_mask * 0 & if b_ct_indx[0] NE -1 then b_cont_mask[b_ct_indx] = 1

		; Output continuum models include residfit. 
		b_continuum = (b_continuum + b_residfit) * data_norm_factor
		r_continuum = (r_continuum + r_residfit) * data_norm_factor
		b_residfit = b_residfit * data_norm_factor
		r_residfit = r_residfit * data_norm_factor
		b_addpoly  = b_addpoly * data_norm_factor
		r_addpoly  = r_addpoly * data_norm_factor
			
		; cut out channels before and after fit_ran
		ind = min( where(b_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.b_zsize-1 then begin 
			b_continuum[0:ind-1] = !values.f_nan
			b_residfit[0:ind-1]  = !values.f_nan
			b_addpoly[0:ind-1]   = !values.f_nan
			b_mpoly[0:ind-1]     = !values.f_nan
		endif
		if ind eq set.b_zsize-1 then begin 
			b_continuum[*] = !values.f_nan
			b_residfit[*]  = !values.f_nan
			b_addpoly[*]   = !values.f_nan
			b_mpoly[*]     = !values.f_nan
		endif
		ind = max( where(b_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.b_zsize-1 then begin 
			b_continuum[ind+1:*] = !values.f_nan
			b_residfit[ind+1:*]  = !values.f_nan
			b_addpoly[ind+1:*]   = !values.f_nan
			b_mpoly[ind+1:*]     = !values.f_nan
		endif

		ind = min( where(r_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.r_zsize-1 then begin 
			r_continuum[0:ind-1] = !values.f_nan
			r_residfit[0:ind-1]  = !values.f_nan
			r_addpoly[0:ind-1]   = !values.f_nan
			r_mpoly[0:ind-1]     = !values.f_nan
		endif
		if ind eq set.r_zsize-1 then begin 
			r_continuum[*] = !values.f_nan
			r_residfit[*]  = !values.f_nan
			r_addpoly[*]   = !values.f_nan
			r_mpoly[*]     = !values.f_nan
		endif
		ind = max( where(r_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.r_zsize-1 then begin 
			r_continuum[ind+1:*] = !values.f_nan
			r_residfit[ind+1:*]  = !values.f_nan
			r_addpoly[ind+1:*]   = !values.f_nan
			r_mpoly[ind+1:*]     = !values.f_nan
		endif
		; calculate red_chi2 for continuum fit!!
		if b_ct_indx[0] NE -1 and r_ct_indx[0] NE -1 then begin
			chi2 = total(((data.b_flux[b_ct_indx] - b_continuum[b_ct_indx])/data.b_flux_err[b_ct_indx] )^2 ) + $
				   total(((data.r_flux[r_ct_indx] - r_continuum[r_ct_indx])/data.r_flux_err[r_ct_indx] )^2 )
			red_chi2 = chi2 / (n_elements(b_ct_indx) + n_elements(r_ct_indx)) ; dof only roughly right. should be good enough. 
		endif else begin
			if b_ct_indx[0] NE -1 then $
				red_chi2 = total(((data.b_flux[b_ct_indx] - b_continuum[b_ct_indx])/data.b_flux_err[b_ct_indx] )^2 ) / n_elements(b_ct_indx)
			if r_ct_indx[0] NE -1 then $
				red_chi2 = total(((data.b_flux[b_ct_indx] - b_continuum[b_ct_indx])/data.b_flux_err[b_ct_indx] )^2 ) / n_elements(r_ct_indx)
			if b_ct_indx[0] eq -1 and r_ct_indx[0] eq -1 then red_chi2 = !values.f_nan
		endelse
	endif else begin ; 1-sided data
		; reconstruct mpoly and addpoly
		r_recon = lzifu_remake_ppxf_bestfit(res, DEGREE=set.degree, MDEGREE=set.mdegree,$
		STAR=br_temp_rebin, WEIGHTS=br_starcoeff,$
		LAMBDA=float(exp(br_loglam)/(1+set.z)), RANGE = range, $
		polyweights = br_polyweights)
		r_logcontinuum = r_recon.bestfit & r_logaddpoly = r_recon.addpoly & r_logmpoly = r_recon.mpoly

		r_continuum = interpol(br_logcontinuum,exp(br_loglam),br_lambda) 
		r_addpoly   = interpol(r_logaddpoly,exp(br_loglam),br_lambda) 
		r_mpoly     = interpol(r_logmpoly,exp(br_loglam),br_lambda) 

		r_residual = data.r_flux/data_norm_factor - r_continuum
		; Fit residual with combination of Legendre Polynomial with bvls
		r_residfit = lzifu_fit_residual(data.r_lambda,r_residual,data.r_flux_err, $
		                                degree = set.r_resid_degree,goodpixels = r_ct_indx)
		r_cont_mask = r_cont_mask * 0 & if r_ct_indx[0] NE -1 then r_cont_mask[r_ct_indx] = 1
		; Output continuum models include residfit. 
		r_continuum = (r_continuum + r_residfit) * data_norm_factor	
		r_residfit = r_residfit * data_norm_factor
		r_addpoly  = r_addpoly * data_norm_factor
		
		b_continuum = data.b_flux + !values.f_nan
		b_residual  = data.b_flux + !values.f_nan
		b_residfit  = data.b_flux + !values.f_nan
		b_cont_mask = data.b_flux + !values.f_nan
		b_addpoly   = data.b_flux + !values.f_nan
		b_mpoly     = data.b_flux + !values.f_nan
		
		; cut out channels before and after fit_ran
		ind = min( where(r_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.r_zsize-1 then begin 
			r_continuum[0:ind-1] = !values.f_nan
			r_residfit[0:ind-1]  = !values.f_nan
			r_addpoly[0:ind-1]   = !values.f_nan
			r_mpoly[0:ind-1]     = !values.f_nan
		endif
		if ind eq set.r_zsize-1 then begin 
			r_continuum[*] = !values.f_nan
			r_residfit[*]  = !values.f_nan
			r_addpoly[*]   = !values.f_nan
			r_mpoly[*]     = !values.f_nan
		endif
		ind = max( where(r_cont_mask eq 1) ) 
		if ind gt 0 and ind lt set.r_zsize-1 then begin 
			r_continuum[ind+1:*] = !values.f_nan
			r_residfit[ind+1:*]  = !values.f_nan
			r_addpoly[ind+1:*]   = !values.f_nan
			r_mpoly[ind+1:*]     = !values.f_nan
		endif
		; calculate red_chi2 for continuum fit!!
		if br_ct_indx[0] NE -1 then begin
			chi2 = total(((data.r_flux[r_ct_indx] - r_continuum[r_ct_indx])/data.r_flux_err[r_ct_indx] )^2 ) 
			red_chi2 = chi2 / n_elements(r_ct_indx) ; dof only roughly right. should be good enough. 
		endif else red_chi2 = !values.f_nan
	endelse

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;     Finish continuum fitting    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
	data = add_tag(data,b_continuum,'b_continuum')
	data = add_tag(data,r_continuum,'r_continuum')
	data = add_tag(data,b_cont_mask,'b_cont_mask')
	data = add_tag(data,r_cont_mask,'r_cont_mask')
	data = add_tag(data,data.b_flux - b_continuum,'b_flux_nocnt')
	data = add_tag(data,data.r_flux - r_continuum,'r_flux_nocnt')
	data = add_tag(data,b_residfit,'b_residfit')
	data = add_tag(data,r_residfit,'r_residfit')
	data = add_tag(data,b_addpoly,'b_addpoly')
	data = add_tag(data,r_addpoly,'r_addpoly')
	data = add_tag(data,b_mpoly,'b_mpoly')
	data = add_tag(data,r_mpoly,'r_mpoly')
	data = add_tag(data,red_chi2,'cont_chi2')

	; update z for this spaxel
	z_star = set.z + br_sol[0]/light_speed
	
	data = add_tag(data,z_star,'z_star')
	data = add_tag(data,br_sol[0],'starvel')	
	data = add_tag(data,br_sol_err[0],'starvel_err')
	data = add_tag(data,br_sol[1],'starvdisp')
	data = add_tag(data,br_sol_err[1],'starvdisp_err')
	data = add_tag(data,br_ebv,'starebv')

	data = add_tag(data,1,'cont_status')

	; br_starcoeff
	; put normalization factor back to br_starcoeff
	br_starcoeff = br_starcoeff / temp_norm_factor
	br_starcoeff = reform(br_starcoeff,set.n_age,set.n_metal)
	data = add_tag(data,br_starcoeff,'starcoeff')

	return,data

END
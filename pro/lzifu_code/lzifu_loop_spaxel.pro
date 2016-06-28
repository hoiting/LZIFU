FUNCTION lzifu_build_mask,data,set
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; build [br]_mask array. 1: data is good. 0: data is bad. 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	r_mask=replicate(1B,n_elements(data.r_flux)) & b_mask=replicate(1B,n_elements(data.b_flux))
	
	if set.only_1side EQ 0 then begin ; 2-sided data
		; User external mask
		if n_elements(set.r_ext_mask) NE 0 then begin
			for k=0,n_elements(set.r_ext_mask)/2-1 do begin
				r_ind=where(data.r_lambda GT set.r_ext_mask[0,k] and data.r_lambda LT set.r_ext_mask[1,k],r_cnt)
				if r_cnt GT 0 then r_mask[r_ind]=0
			endfor
		endif 
		if n_elements(set.b_ext_mask) NE 0 then begin
			for k=0,n_elements(set.b_ext_mask)/2-1 do begin
				b_ind=where(data.b_lambda GT set.b_ext_mask[0,k] and data.b_lambda LT set.b_ext_mask[1,k],b_cnt)
				if b_cnt GT 0 then b_mask[b_ind]=0
			endfor	
		endif
		; Include bpix into [rb]_mask
		; Include NAN pixels and 0 pixels in masks. in case MPFITS crashes
		b_ind= where(data.b_bpix eq 1 OR ~finite(data.b_flux) OR data.b_flux EQ 0 OR ~finite(data.b_flux_err) OR data.b_flux_err LE 0,bcnt) 
		r_ind= where(data.r_bpix eq 1 OR ~finite(data.r_flux) OR data.r_flux EQ 0 OR ~finite(data.r_flux_err) OR data.r_flux_err LE 0,rcnt) 
		if rcnt GT 0 then r_mask[r_ind]=0   & if bcnt GT 0 then b_mask[b_ind]=0   ; 1 is good. 0 is bad.		
		; Include fit_ran
		b_ind = where(data.b_lambda ge set.fit_ran[0] and data.b_lambda le set.fit_ran[1],bcnt,complement=b_ind_c)
		r_ind = where(data.r_lambda ge set.fit_ran[0] and data.r_lambda le set.fit_ran[1],rcnt,complement=r_ind_c)
		if bcnt NE n_elements(data.b_flux) then b_mask[b_ind_c] = 0 
		if rcnt NE n_elements(data.r_flux) then r_mask[r_ind_c] = 0
	endif else begin  ; 1-sided data
		; User external mask
		if n_elements(set.ext_mask) NE 0 then begin
			for k=0,n_elements(set.ext_mask)/2-1 do begin
				r_ind=where(data.r_lambda GT set.ext_mask[0,k] and data.r_lambda LT set.ext_mask[1,k],r_cnt)
				if r_cnt GT 0 then r_mask[r_ind]=0
			endfor
		endif 
		; Include bpix into [rb]_mask
		; Include NAN pixels and 0 pixels in masks. in case MPFITS crashes
		r_ind= where(data.r_bpix eq 1 OR ~finite(data.r_flux) OR data.r_flux EQ 0 OR ~finite(data.r_flux_err) OR data.r_flux_err LE 0,rcnt) 
		if rcnt GT 0 then r_mask[r_ind]=0   ; 1 is good. 0 is bad.		
		; Include fit_ran
		r_ind = where(data.r_lambda ge set.fit_ran[0] and data.r_lambda le set.fit_ran[1],rcnt,complement=r_ind_c)
		if rcnt NE n_elements(r_flux) then r_mask[r_ind_c] = 0	
	endelse

	mask = {mask,$
	        b_mask  : b_mask,$
	        r_mask  : r_mask}
	return,mask
END

PRO lzifu_reduce_fit,fit=fit
	; remove some extensions in fit to save memory usage.
	tag_list = ['B_FLUX','B_BPIX',$
				'R_FLUX','R_BPIX']
	for i = 0,n_elements(tag_list)-1 do begin
		cmd = 'if tag_exist(fit,"'+tag_list[i]+'") then fit = rem_tag(fit,"'+tag_list[i]+'")'
		void = execute(cmd)
	endfor
END

PRO lzifu_fit_spaxel,data,b_template,r_template,set, fit = fit
	!EXCEPT = 0
	; Build mask. 
	mask = lzifu_build_mask(data,set)

	; Add structure mask to structure data. 
	data = struct_addtags(data,mask)

	; fit continuum with ppxf
	if set.supply_ext_cont EQ 0 then begin
		data = lzifu_fit_continuum(data,b_template,r_template,set)	
		; if continuum fit fails then return
		if tag_exist(data,'CONT_STATUS') then begin  
			if data.cont_status EQ -1 then begin
				fit = data
				return
			endif
		endif
	endif	
	; fit line emission with mpfit
	fit = lzifu_fit_line(data,set)  ; fit contains both fit results and data
	; reduce fit to save memory
	lzifu_reduce_fit,fit=fit
END

PRO lzifu_check_fit_ran,lambda,set
	min_l = min(lambda,/nan,max = max_l)
	if set.fit_ran[0] LT min_l*(1+set.z[0]) then begin
		message,'Lower bound of FIT_RAN '+ string(set.fit_ran[0],format='(I0)') + $
		        ' is smaller than minimum wavelength of the template. Set lower ' + $
		        'bound of FIT_RAN to ' + string(min_l*(1+set.z[0]),format='(I0)'),/continue
		fit_ran = set.fit_ran
		fit_ran[0] = min_l*(1+set.z[0])
		set = rep_tag_value(set,fit_ran,'fit_ran')
	endif
	if set.fit_ran[1] GT max_l*(1+set.z[0]) then begin
		message,'Upper bound of FIT_RAN '+ string(set.fit_ran[1],format='(I0)') + $
		        ' is greater than maximum wavelength of the template. Set upper ' +$ 
		        'bound of FIT_RAN to ' + string(max_l*(1+set.z[0]),format='(I0)'),/continue
		fit_ran = set.fit_ran
		fit_ran[1] = max_l*(1+set.z[0])
		set = rep_tag_value(set,fit_ran,'fit_ran')
	endif

END


FUNCTION lzifu_convol_template,template,set

	if set.only_1side eq 0 then begin  ; two-sided data 
		b_template=template & r_template=template
		conv_width = sqrt(set.b_resol_sigma^2-set.temp_resol_sigma^2)
		if conv_width gt 0 then begin
			b_template.flux = lzifu_disperse_template(b_template.flux,b_template.lambda,conv_width)
		endif else begin 
			print,'Warning: LZIFU does not convolve B template because template resolution is lower ' + $ 
			      'than data. This may cause problems!!'
			print,'         template resolution (sigma):',set.temp_resol_sigma,' data resolution (sigma):',set.b_resol_sigma,format='(A,F5.2,A,F5.2)'
		endelse
		conv_width = sqrt(set.r_resol_sigma^2-set.temp_resol_sigma^2)
		if conv_width gt 0 then begin	
			r_template.flux = lzifu_disperse_template(r_template.flux,r_template.lambda,conv_width)
		endif else begin 
			print,'Warning: LZIFU does not convolve R template because template resolution is lower ' + $
			      'than data. This may cause problems!!'
			print,'         template resolution (sigma):',set.temp_resol_sigma,' data resolution (sigma):',set.r_resol_sigma,format='(A,F5.2,A,F5.2)'
		endelse
	endif else begin   ; one-sided data
		b_template = {empty:!values.f_nan} & r_template=template
		conv_width = sqrt(set.resol_sigma^2-set.temp_resol_sigma^2)
		if conv_width gt 0 then begin	
			r_template.flux = lzifu_disperse_template(r_template.flux,r_template.lambda,conv_width)
		endif else begin 
			print,'Warning: LZIFU does not convolve the template because template resolution is lower ' + $
			      'than data. This may cause problems!!'
			print,'         template resolution (sigma):',set.temp_resol_sigma,' data resolution (sigma):',set.resol_sigma,format='(A,F5.2,A,F5.2)'
		endelse
	endelse
	return,list(b_template,r_template)

END


FUNCTION lzifu_loop_spaxel, datacube, set

	
	; Load stellar template
	if set.supply_ext_cont EQ 0 then begin ; if external continuum not provided
		; Read in stellar template
		set.n_metal = n_elements(set.template_name)
		for i = 0,set.n_metal-1 do begin
			restore,set.template_path + '/' + set.template_name[i]
			; check fit_ran keyword. modify it if it doesn't make sense 
			lzifu_check_fit_ran,template.lambda,set	
			if i eq 0 then begin 
				n_age = size(template.flux,/dim)
				n_age= n_age[1]
				dum_template = template
				if tag_exist(template,'age_myr') then set  = add_tag(set,template.age_myr,'age_myr')
			endif else $
				dum_template = {lambda: template.lambda, flux: [[dum_template.flux],[template.flux]]}
		endfor
		template = dum_template	 & dum_template = 0
		set.n_age = n_age
		; Convolve template
		tmp = lzifu_convol_template(template,set)
		b_template = tmp[0]
		r_template = tmp[1] & tmp = 0 
	endif else begin ; external continuum supplied
		cont_cube = call_function(set.load_ext_cont_func,set)
	endelse
	
	; Load 2d madk if supplied.
	if set.supply_mask_2d eq 1 then begin
		mask_2d = call_function(set.load_mask_2d_func,set)
	endif 	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;; Loop through each spaxel   ;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; For parallel processing
	if set.ncpu gt 1 then begin	
		bridges = build_bridges(set.ncpu,!CPU.TPOOL_NTHREADS)  
		set.ncpu = n_elements(bridges)
		for i=0,set.ncpu-1 do begin
	    	(bridges[i])->execute, '.r lzifu_loop_spaxel.pro'
		    (bridges[i])->execute, '.r lzifu_callback.pro'	    
    	    (bridges[i])->setproperty, callback='lzifu_callback'
		endfor		
	endif else set.ncpu = 1
	; User data. this is a pointer of a list
	; Store output data (ugly structure)
	ud = ptr_new(list())
	var_pass = []
	if set.supply_ext_cont EQ 0  then str_pass=['data_str','b_template','r_template','set'] $
		else str_pass = ['data_str','set']
	; main loop
	for i = 0,set.xsize-1 do begin
		for j = 0,set.ysize-1 do begin
			; Skip pixel if masked out by external 2D mask
			if set.supply_mask_2d eq 1 then begin
				if mask_2d[i,j] eq 0 then begin
					print,set.obj_name+'('+strtrim(set.ncomp,2)+' comp.): Skip pixel ('+string(i,format='(I0)')+','+string(j,format='(I0)')+') of ('+string(set.xsize-1,format='(I0)')+','+string(set.ysize-1,format='(I0)')+'). Masked by external 2d mask. '
					continue
				endif
			endif

			; Get 1d flux and flux_err from cube  bpix: 0=good 1=bad !! opposite to [rb]_mask
			r_flux=reform(datacube.r_cube[i,j,*]) & r_flux_err=reform(datacube.r_cube_err[i,j,*]) & r_bpix=reform(datacube.r_cube_bpix[i,j,*])
			b_flux=reform(datacube.b_cube[i,j,*]) & b_flux_err=reform(datacube.b_cube_err[i,j,*]) & b_bpix=reform(datacube.b_cube_bpix[i,j,*])


			; Skip empty pixels at boundaries or very poor pixels (almost no info).  
			if mode(b_bpix) eq 1              or mode(r_bpix) eq 1 or $
			   median(b_flux_err) eq 0        or median(r_flux_err) eq 0 or $
			   ~finite(median(b_flux_err))    or ~finite(median(r_flux_err)) or $
			   ~finite(median(b_flux))        or ~finite(median(r_flux)) or $
			   array_equal(b_flux,b_flux * 0) or array_equal(r_flux,r_flux * 0) then begin
				fit = {i:i,j:j,fitstatus:!values.f_nan}
				(*ud)->add,fit
				print,set.obj_name+'('+strtrim(set.ncomp,2)+' comp.): Empty pixel ('+string(i,format='(I0)')+','+string(j,format='(I0)')+') of ('+string(set.xsize-1,format='(I0)')+','+string(set.ysize-1,format='(I0)')+'). Skip!!'
				continue   ; skip this for loop turn.
			endif
			
			; Pack data into a structure
			data_str = {data_str, $
						i          : i,          $
			            j          : j,          $
			            r_flux     : r_flux,     $
			            r_flux_err : r_flux_err, $
		      	        r_bpix     : r_bpix,     $
			            r_lambda   : datacube.r_lambda,   $
			            b_flux     : b_flux,     $
			            b_flux_err : b_flux_err, $
			            b_bpix     : b_bpix,     $
			            b_lambda   : datacube.b_lambda}
			; Subtract continuum and pack it into data_str if external continuum is provided
			if set.supply_ext_cont EQ 1 then begin ; external continuum supplied
				if tag_exist(cont_cube,'b_continuum') then $ 
					data_str = add_tag(data_str,b_flux - reform(cont_cube.b_continuum[i,j,*]),'b_flux_nocnt') $
					else $
					message,'External continuum cube not properly loaded (should never get to here).'
				if tag_exist(cont_cube,'r_continuum') then $ 
					data_str = add_tag(data_str,r_flux - reform(cont_cube.r_continuum[i,j,*]),'r_flux_nocnt') $
					else $
					message,'External continuum cube not properly loaded (should never get to here).'

				if tag_exist(cont_cube,'b_continuum') then $ 
					data_str = add_tag(data_str,reform(cont_cube.b_continuum[i,j,*]),'b_continuum') $
					else $
					message,'External continuum cube not properly loaded (should never get to here).'
				if tag_exist(cont_cube,'r_continuum') then $ 
					data_str = add_tag(data_str,reform(cont_cube.r_continuum[i,j,*]),'r_continuum') $
					else $
					message,'External continuum cube not properly loaded (should never get to here).'
			endif
			; Prepare command for each spaxel
			cmd = 'lzifu_fit_spaxel, data_str, b_template, r_template, set, fit = fit'
			if set.ncpu GT 1 then begin ; Parallel processing 
				; Find idle bridge
				bridge = get_idle_bridge(bridges,cpu_no=cpu_no)
				print,set.obj_name+'('+strtrim(set.ncomp,2)+' comp.): Sending ('+string(i,format='(I0)')+','+string(j,format='(I0)')+') of ('+string(set.xsize-1,format='(I0)')+','+string(set.ysize-1,format='(I0)')+') to CPU #'+string(cpu_no,format='(I0)')
				bridge -> setproperty, userdata=ud
				; pass structures to the bridge
				for c=0,n_elements(str_pass)-1 do struct_pass,scope_varfetch(str_pass[c]),bridge
				; pass other variables to the bridge	
				for c=0,n_elements(var_pass)-1 do bridge->setvar, var_pass[c], scope_varfetch(var_pass[c])
				; Now execute the command!
				bridge -> execute,/nowait,cmd 				
			endif else begin   ; NO parallel processing. Single CPU
				print,set.obj_name+'('+strtrim(set.ncomp,2)+' comp.): Fitting ('+string(i,format='(I0)')+','+string(j,format='(I0)')+') of ('+string(set.xsize-1,format='(I0)')+','+string(set.ysize-1,format='(I0)')+')'
				void = execute(cmd)				
				(*ud)->add,fit
			endelse
		endfor
	endfor

	; kill all bridges when done
    if set.ncpu GT 1 then begin
        barrier_bridges, bridges
        burn_bridges, bridges
    endif

	fit_list = *ud
	
	return,fit_list
	
END
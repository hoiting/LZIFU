FUNCTION lzifu_smooth_refit,fit_list,set

	; if too few then don't do anything.
	if n_elements(fit_list) LT 5 then return,fit_list
	; make param array
	for i = 0,n_elements(fit_list)-1 do begin
		dum = fit_list[i]
		if ~ tag_exist(dum,'param') then continue
		; if param_arr doesn't exist, create it!
		if n_elements(param_arr) eq 0 then param_arr = fltarr(set.xsize,set.ysize,n_elements(dum.param)) + !values.f_nan
		param_arr[dum.i,dum.j,*] = dum.param
	endfor

	; smooth the param_arr
	print,'Smoothing parameters from the previous fit....'
	s = size(param_arr,/dim)
	smooth_param_arr = fltarr(s) + !values.f_nan
	for i = 0,s[2]-1 do $
		smooth_param_arr[*,*,i] = median(param_arr[*,*,i],set.smooth_width)

	print,'Re-running line fitting with smoothed parameters'

	; For parallel processing
	if set.ncpu GT 1 then begin	
		bridges = build_bridges(set.ncpu)  
		set.ncpu = n_elements(bridges)
		for i=0,set.ncpu-1 do begin
	    	(bridges[i])->execute, '.r lzifu_fit_line.pro'
		    (bridges[i])->execute, '.r lzifu_callback.pro'	    
    	    (bridges[i])->setproperty, callback='lzifu_callback'
		endfor	
	endif	
	; Variables and structure to be passed to bridges
	var_pass = ['this_param']
	str_pass=['this_fit','set'] 
	; Create a pointer of a list to store output data (ugly structure)
	ud = ptr_new(list())

	; refit the spectrum and update fit_list
	for i = 0,n_elements(fit_list)-1 do begin
		; print progress...
		if i mod 10 eq 0 then print,format='($,".")'
		if i mod 400 eq 0 then begin
			print,'.'
			print,set.obj_name+': '+ strtrim(i,2)+'/'+strtrim(n_elements(fit_list),2)
		endif

		; extract from fit_list
		this_fit = fit_list[i]
		if ~ tag_exist(this_fit,'param') then continue
		; !!Remove previous fit result to avoid contamination
		this_fit = rem_tag(this_fit,'param')
		; new param
		this_param = reform(smooth_param_arr[this_fit.i,this_fit.j,*])

		cmd = 'fit = lzifu_fit_line(this_fit,set,param = this_param )'

		if set.ncpu EQ 1 then begin ; no parallel processing
			; re-fit with new parinit
			void = execute(cmd)
			(*ud)->add,fit
		endif else begin ; parallel processing!
			; Find idle bridge
			bridge = get_idle_bridge(bridges,cpu_no=cpu_no)
			bridge -> setproperty, userdata = ud
			; pass structures to the bridge
			for c=0,n_elements(str_pass)-1 do struct_pass,scope_varfetch(str_pass[c]),bridge
			; pass other variables to the bridge	
			for c=0,n_elements(var_pass)-1 do bridge->setvar, var_pass[c], scope_varfetch(var_pass[c])
			; Now execute the command!
			bridge -> execute,/nowait,cmd 			
		endelse
	endfor

	; kill all bridges when done
    if set.ncpu GT 1 then begin
        barrier_bridges, bridges
        burn_bridges, bridges
    endif
	
	new_fit_list = *ud

	return,new_fit_list
	
END




FUNCTION lzifu_add_set,set
	; Add other parameters to set.

	; Version # 
	set = add_tag(set,'v1.1','LZIFU_VERSION')

	; Additional hidden settings
	if ~tag_exist(set,'PPXF_NAME') then $
		set  = add_tag(set,'PPXF','PPXF_NAME')
	set  = add_tag(set,500,'MPFIT_MAXITER')

	; Create some variables which will be filled in later
	set  = add_tag(set,-1.,'r_channel_width')
	set  = add_tag(set,-1.,'b_channel_width')
	set  = add_tag(set,-1L,'n_metal')
	set  = add_tag(set,-1L,'n_age')
	set  = add_tag(set,-1L,'xsize')
	set  = add_tag(set,-1L,'ysize')
	set  = add_tag(set,-1L,'b_zsize')
	set  = add_tag(set,-1L,'r_zsize')
	
	; In case obj_name and z are 1-element arrays.
	set = rep_tag_value(set,set.obj_name[0],'OBJ_NAME')	
	set = rep_tag_value(set,set.z[0],'Z')	

	; set.ncomp has to be integer!
	set = rep_tag_value(set,FIX(set.ncomp),'NCOMP')
	if ~ (set.ncomp EQ 1 OR set.ncomp EQ 2 OR set.ncomp EQ 3) then $
		message,'NCOMP should be 1, 2, or 3'
	
	; Determine n_guess (later used in lzifu_initpar)
	if set.ncomp EQ 1 then n_guess = 1
	if set.ncomp EQ 2 then $
		n_guess = n_elements(set.comp_2_damp) * n_elements(set.comp_2_dvel) * n_elements(set.comp_2_dvdisp) 
	if set.ncomp EQ 3 then $
		n_guess = n_elements(set.comp_2_damp) * n_elements(set.comp_2_dvel) * n_elements(set.comp_2_dvdisp) * $
		          n_elements(set.comp_3_damp) * n_elements(set.comp_3_dvel) * n_elements(set.comp_3_dvdisp)
	set  = add_tag(set,n_guess,'n_guess')
	if set.ncomp NE 1 and set.ncomp NE 2 and set.ncomp NE 3 then begin
		message,'Currently only support 1, 2, or 3 component fit.',/continue
		stop
	endif
	; Check sort_type
	if ~ tag_exist(set,'sort_type') then $
		message,"SORT_TYPE is missing."	

	if ~(strcmp(set.sort_type,'vdisp',/fold_case) or strcmp(set.sort_type,'vel',/fold_case) or $
        where(strtrim(strupcase((call_function(set.linelist_func,/fit_line)).label),2) EQ strtrim(strupcase(set.sort_type),2) ) NE -1) then $
		message,"SORT_TYPE should be either 'vdisp' or 'vel' or LABEL in set.linelist_func (/fit_line)"	
		
	; Output filename
	set = add_tag(set,set.product_path + '/' + set.obj_name + $
	              '_'+strtrim(set.ncomp,2) + '_comp.fits','out_file')

	; Check some ppxf parameters
	if set.ppxf_clean NE 1 then set.ppxf_clean = 0

	if set.mdegree lt 0 then begin
		set.mdegree = 0
	    message,"MDEGREE can't be negative. Set to 0.",/continue		
	endif
	if set.mdegree gt 0 then begin
	    message,"MDEGREE > 0. PPXF will fit multiplicative polynomials and will not fit EBV.",/continue		
	endif	
	if ~ (set.moments EQ 2 or set.moments EQ 4 or set.moments EQ 6) then begin
	    message,"MOMENTS has to be 2, 4 or 6."
	endif
	if set.degree lt 0 then begin
		set.degree = -1
	endif

	; Disable fit_del_b_lambda
	if ~tag_exist(set,'fit_del_b_lambda') then set  = add_tag(set,0,'fit_del_b_lambda') else set.fit_del_b_lambda = 0
	if ~tag_exist(set,'del_b_lambda') then set  = add_tag(set,0,'del_b_lambda') else set.del_b_lambda = 0
	
	; if one-sided then don't fit del_b_lambda
	if set.only_1side EQ 1 then begin 
		set.del_b_lambda     = 0
		set.fit_del_b_lambda = 0
	endif
	; A small floating point for tagging amplitudes of the lines not fit
	set = add_tag(set,10^float(ceil(alog10((MACHAR()).xmin))),'minfluxconst') 
	return,set
END
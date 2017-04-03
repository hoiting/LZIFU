FUNCTION lzifu_load_ext_cont,set
	ext_cont_fn = set.ext_cont_path + '/' + set.ext_cont_name

	; See if the files exist?	
	if ~ file_exist(ext_cont_fn) then $
		message,"Can't find file:" + ext_cont_fn

	; Load file
	print,"Loading externally supplied continuum cubes:"
	
	if set.only_1side EQ 0 then begin ; 2-sided data
		b_continuum = mrdfits(ext_cont_fn,0)
		r_continuum = mrdfits(ext_cont_fn,1)
		; check size
		bs = size(b_continuum,/dim)
		rs = size(r_continuum,/dim)
		if not array_equal(bs,[set.xsize,set.ysize,set.b_zsize]) then $
			message,'B continuum model provided does not match with data cube'
		if not array_equal(rs,[set.xsize,set.ysize,set.r_zsize]) then $
			message,'R continuum model provided does not match with data cube'
	endif else begin  ; 1-sided data
		r_continuum = mrdfits(ext_cont_fn,0)
		; check size
		rs = size(r_continuum,/dim)
		if not array_equal(rs,[set.xsize,set.ysize,set.r_zsize]) then $
			message,'Continuum model provided does not match with data cube'
		; fake blue cube
		b_continuum      = fltarr(set.xsize,set.ysize,2) + 1
	endelse

	return,{b_continuum       : b_continuum,$
	    	r_continuum       : r_continuum}
END
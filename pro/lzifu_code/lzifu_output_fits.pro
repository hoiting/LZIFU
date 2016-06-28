FUNCTION make_cube_header,header_in
	; create basic header structure
	fxhmake,header_out,xtension='IMAGE'
	; Add these keys into header_out
    keys = ['NAXIS1','NAXIS2','NAXIS3', $
            'CRPIX1','CRPIX2','CRPIX3', $
            'CDELT1','CDELT2','CDELT3', $
            'CRVAL1','CRVAL2','CRVAL3', $
            'CTYPE1','CTYPE2','CTYPE3', $
            'CUNIT1','CUNIT2','CUNIT3', $
            'CD1_1','CD1_2','CD2_1','CD2_2']
    sxaddpar,header_out,'NAXIS',3
    for kk = 0,n_elements(keys)-1 do begin
        value = sxpar(header_in,keys[kk],count= count)
        if count eq 1 then $
            sxaddpar, header_out, keys[kk], value
    endfor
    sxaddpar,header_out,'PCOUNT',0
    sxaddpar,header_out,'GCOUNT',1
    
    return,header_out
END

FUNCTION make_map_header,header_in,data
	s = size(data,/dim)
	; create basic header structure
	fxhmake,header_out,xtension='IMAGE'
	; Add these keys into header_out. only wcs information. 
    keys = ['NAXIS1','NAXIS2', $
            'CRPIX1','CRPIX2', $
            'CDELT1','CDELT2', $
            'CRVAL1','CRVAL2', $
            'CTYPE1','CTYPE2', $
            'CUNIT1','CUNIT2', $
            'CD1_1','CD1_2','CD2_1','CD2_2']
    sxaddpar,header_out,'NAXIS',n_elements(s)
    for kk = 0,n_elements(keys)-1 do begin
        value = sxpar(header_in,keys[kk],count= count)
        if count eq 1 then $
            sxaddpar, header_out, keys[kk], value
    endfor
    sxaddpar,header_out,'PCOUNT',0
    sxaddpar,header_out,'GCOUNT',1
    if n_elements(s) eq 3 then $
	    sxaddpar,header_out,'NAXIS3',s[2],after='NAXIS2'
    
    return,header_out
END


PRO lzifu_output_fits,set,cubes,images
	; produce a single fits file that contains all outputs
	products = join_struct(cubes,images)
	;;;;;;;;;;;;;;;;;;; set up output plan ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if set.only_1side EQ 0 then begin ; two-sided data
		content   = list('b_continuum','r_continuum','b_addpoly','r_addpoly','b_mpoly','r_mpoly','b_residfit','r_residfit', 'b_cont_mask', 'r_cont_mask', $
	    	             'b_line'     ,'r_line', $
	        	         'b_line_comp1','r_line_comp1','b_line_comp2','r_line_comp2','b_line_comp3','r_line_comp3',$
		                 'v','v_err','vdisp','vdisp_err','chi2','dof')
		fits_key  = list('b_continuum','r_continuum','b_addpoly','r_addpoly','b_mpoly','r_mpoly','b_residfit','r_residfit', 'b_cont_mask', 'r_cont_mask', $
	    	             'b_line'     ,'r_line', $
	        	         'b_line_comp1','r_line_comp1','b_line_comp2','r_line_comp2','b_line_comp3','r_line_comp3',$
		                 'v','v_err','vdisp','vdisp_err','chi2','dof')
		header_type= list('b_cube','r_cube','b_cube','r_cube','b_cube','r_cube','b_cube','r_cube','b_cube' , 'r_cube', $
		                  'b_cube'     ,'r_cube', $
	    	              'b_cube','r_cube','b_cube','r_cube','b_cube','r_cube',$
	            	      'map','map','map','map','map','map')
	endif else begin  ; one-sided data
		content   = list('r_continuum','r_addpoly','r_mpoly','r_residfit', 'r_cont_mask', $
	    	             'r_line', $
	        	         'r_line_comp1','r_line_comp2','r_line_comp3',$
		                 'v','v_err','vdisp','vdisp_err','chi2','dof')
		fits_key  = list('continuum', 'addpoly','mpoly','residfit','cont_mask', $
	    	             'line', $
	        	         'line_comp1','line_comp2','line_comp3',$
		                 'v','v_err','vdisp','vdisp_err','chi2','dof')
		header_type= list('r_cube','r_cube','r_cube','r_cube','r_cube',$
		                  'r_cube', $
	    	              'r_cube','r_cube','r_cube',$
	            	      'map','map','map','map','map','map')
	endelse
	; add lines in to plan
	linelist = call_function(set.linelist_func,/fit_line)
	for i = 0,n_elements(linelist.label)-1 do begin
		this_line = linelist.label[i]
		if this_line eq 'OIII4959' or this_line eq 'NII6548' then continue ; skip these two lines
		content.add, this_line
		fits_key.add, this_line
		header_type.add, 'map'

		content.add, this_line+'_ERR'
		fits_key.add, this_line+'_ERR'
		header_type.add, 'map'
	endfor
	;;;;;;;;;;;;;;;;;;;;;;;; reduce output plan to only those actually exist ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	remove_indices = list()
	for i=1,n_elements(content)-1 do begin
		if ~ tag_exist(products,content[i]) then remove_indices.add,i
	endfor
	if remove_indices.count() GT 0 then begin
		dum = content.remove(remove_indices.toarray())
		dum = fits_key.remove(remove_indices.toarray())
		dum = header_type.remove(remove_indices.toarray())
	endif

	;;;;;;;;;;;;;;;;;;;;; create proper header ;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; Do the Primary extension 
	fxhmake,header0,/init,/extend ; make simple header
	; things to be included in header0 from set
	header_key     = ['OBJECT'     ,'Z_LZIFU'       ,'VERSION'                        ,'NCOMP'            ,'SORTTYPE']
	header_comment = ['Object name','Input redshift','LZIFU version (I-Ting Ho, 2016)','No. of components','Component sorting method']
	key_lzifu      = ['OBJ_NAME'   ,'Z'             ,'LZIFU_VERSION'                  ,'NCOMP'            ,'SORT_TYPE']
	for i=0,n_elements(header_key)-1 do $
		fxaddpar,header0,header_key[i],str_tagval(set,key_lzifu[i]),header_comment[i]
	; add in which extension is what
	for i=0,n_elements(content)-1 do $
		if tag_exist(products,content[i]) then $
			fxaddpar,header0,'EXT'+strtrim(i,2),strupcase(fits_key[i])
	fxaddpar,header0,'EXT'+strtrim(n_elements(content),2),'SET' ; last extension for storing 'set'
	; make header templates. 
	if set.only_1side EQ 0 then begin ; two-sided data
		b_cube_header = make_cube_header(set.b_header)
		r_cube_header = make_cube_header(set.r_header)
	endif else $          ; one-sided data
		r_cube_header = make_cube_header(set.r_header)

	map_header    = make_map_header(set.r_header)

	;;;;;;;;;;;;;;;;;;;;;;;; write the data out  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; primary header (ext=0)
	print,'Writing out FITS file'
	writefits,set.out_file,0,header0

	for i = 0,n_elements(content)-1 do begin
		cont = content[i]
		fk   = fits_key[i]
		hd_type = header_type[i]

		; decide header
		case hd_type of
			'b_cube'   : tmp_header = b_cube_header
			'r_cube'   : tmp_header = r_cube_header
			'map'      : tmp_header = make_map_header(set.r_header,gt_tagval(products,cont))
			else: fxhmake,tmp_header  ; empty header...
		endcase
		; Add extension name
		fxaddpar,tmp_header,'EXTNAME',strupcase(fk)
		; if exist, write into extension. 
		if tag_exist(products,cont) then begin	
			writefits,set.out_file,gt_tagval(products,cont),tmp_header,/append
			continue
		endif 

		; empty extension if key can't be found
		writefits,set.out_file,0,/append
	endfor	
	; write out "set" at the very end
   	mwrfits,set,set.out_file   	
	fxhmodify,set.out_file,'EXTNAME','SET',exten=n_elements(content)+1 ; update header EXTNAME = SET

END
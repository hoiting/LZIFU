FUNCTION lzifu_make_cubes,fit_list,set
; loop through fit_list to generate model cubes
; add those cubes to data structure and return data structure
	print,'Making model cubes'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	; initialize output. stupid way to code but more efficient than add_tag when cubes are very big
	if set.supply_ext_cont EQ 0 then begin  ; no external continuum provided 
		case set.ncomp of
			1: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_residfit  	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
		    			        r_residfit  	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.b_zsize), $
	    	            		r_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.r_zsize), $	                
								b_addpoly   	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	        			        r_addpoly   	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
	        			        b_mpoly           :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	        		    	    r_mpoly           :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
		    		            starcoeff         :  fltarr(set.xsize,set.ysize,set.n_age,set.n_metal) + !values.f_nan}
				end
			2: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_residfit  	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	        			        r_residfit  	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.b_zsize), $
	                			r_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.r_zsize), $	                
								b_addpoly   	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
		        		        r_addpoly   	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
	    	    		        b_mpoly           :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	        			        r_mpoly           :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
			    	            b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
			        	        r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp2      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp2      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
		    		            starcoeff         :  fltarr(set.xsize,set.ysize,set.n_age,set.n_metal) + !values.f_nan}
				end
			3: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_residfit  	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	        			        r_residfit  	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
								b_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.b_zsize), $
	                			r_cont_mask  	  :  bytarr(set.xsize,set.ysize,set.r_zsize), $	                
								b_addpoly   	  :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
		        		        r_addpoly   	  :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
		        		        b_mpoly           :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
	    	    		        r_mpoly           :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp2      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp2      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp3      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp3      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
	    			            starcoeff         :  fltarr(set.xsize,set.ysize,set.n_age,set.n_metal) + !values.f_nan}
				end
			else:message,'Should never get to here!!!'
		endcase
	endif else begin ; external continuum provided 
		case set.ncomp of
			1: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan}
				end
			2: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
			        	        r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp2      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp2      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan}
				end
			3: begin
				out_datacube = {b_continuum       :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_continuum       :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line            :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line            :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp1      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp1      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp2      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp2      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan, $
				                b_line_comp3      :  fltarr(set.xsize,set.ysize,set.b_zsize) + !values.f_nan, $
				                r_line_comp3      :  fltarr(set.xsize,set.ysize,set.r_zsize) + !values.f_nan}
				end
			else:message,'Should never get to here!!!'	
		endcase
	endelse	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	; Fill the cubes
	for c = 0,n_elements(fit_list)-1 do begin
		dum = fit_list[c]

		if 	is_struct(dum) EQ 0 then continue
		
		if tag_exist(dum,'B_CONTINUUM') then out_datacube.b_continuum[dum.i,dum.j,*] = dum.b_continuum
		if tag_exist(dum,'R_CONTINUUM') then out_datacube.r_continuum[dum.i,dum.j,*] = dum.r_continuum
		if tag_exist(dum,'B_CONT_MASK') then out_datacube.b_cont_mask[dum.i,dum.j,*] = dum.b_cont_mask
		if tag_exist(dum,'R_CONT_MASK') then out_datacube.r_cont_mask[dum.i,dum.j,*] = dum.r_cont_mask
		if tag_exist(dum,'B_ADDPOLY') then out_datacube.b_addpoly[dum.i,dum.j,*] = dum.b_addpoly
		if tag_exist(dum,'R_ADDPOLY') then out_datacube.r_addpoly[dum.i,dum.j,*] = dum.r_addpoly
		if tag_exist(dum,'B_MPOLY') then out_datacube.b_mpoly[dum.i,dum.j,*]   = dum.b_mpoly
		if tag_exist(dum,'R_MPOLY') then out_datacube.r_mpoly[dum.i,dum.j,*]   = dum.r_mpoly
		if tag_exist(dum,'B_RESIDFIT') then out_datacube.b_residfit[dum.i,dum.j,*,*] = dum.b_residfit 
		if tag_exist(dum,'R_RESIDFIT') then out_datacube.r_residfit[dum.i,dum.j,*,*]  = dum.r_residfit 
		if tag_exist(dum,'STARCOEFF') then out_datacube.starcoeff[dum.i,dum.j,*,*] = dum.starcoeff

		if ~ tag_exist(dum,'STATUS')  then continue
		if dum.status LE 0 then continue

		if tag_exist(dum,'B_LINEFIT') then out_datacube.b_line[dum.i,dum.j,*]      = dum.b_linefit
		if tag_exist(dum,'R_LINEFIT') then out_datacube.r_line[dum.i,dum.j,*]      = dum.r_linefit
		for j = 1,set.ncomp do begin
			void = execute('out_datacube.b_line_comp'+strtrim(j,2)+'[dum.i,dum.j,*] = dum.b_linefit_'+strtrim(j,2))		
			void = execute('out_datacube.r_line_comp'+strtrim(j,2)+'[dum.i,dum.j,*] = dum.r_linefit_'+strtrim(j,2))		
		endfor
	end

	print,'Finish making model cubes'

	return,out_datacube
END
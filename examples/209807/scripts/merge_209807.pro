FUNCTION is_line_map,label
	; possible names. 
	line_names = ['Hbeta', 'OIII4959', 'OIII5007','OI6300', 'NII6548','Halpha', 'NII6583', 'SII6716', $
			      'SII6731','V','VDISP']
	ind = where(strupcase(label) eq strupcase(line_names),cnt)
	if cnt eq 1 then return,1
	ind = where(strupcase(label) eq strupcase(line_names+'_ERR'),cnt)
	if cnt eq 1 then return,1
	return,0
END

FUNCTION is_cont_cube,label
	; possible names. can have more!
	names = ['B_CONTINUUM','R_CONTINUUM']
	ind = where(strupcase(label) eq strupcase(names),cnt)
	if cnt eq 1 then return,1 else return,0
END


FUNCTION is_line_cube,label
	; possible names. can have more!
	names = ['B_LINE','B_LINE_COMP1','B_LINE_COMP2','B_LINE_COMP3',$
	         'R_LINE','R_LINE_COMP1','R_LINE_COMP2','R_LINE_COMP3']
	ind = where(strupcase(label) eq strupcase(names),cnt)
	if cnt eq 1 then return,1 else return,0
END


FUNCTION sort_2d_maps,c1,c2,c3,label
	s = size(c3,/dim)
	out = fltarr(s) + !values.f_nan
	ind1 = where(label eq 1,cnt1)
	ind2 = where(label eq 2,cnt2)
	ind3 = where(label eq 3,cnt3)
	; put stuff in out
	c1_0 = c1[*,*,0] & c1_1 = c1[*,*,1]
	c2_0 = c2[*,*,0] & c2_1 = c2[*,*,1] & c2_2 = c2[*,*,2]
	c3_0 = c3[*,*,0] & c3_1 = c3[*,*,1] & c3_2 = c3[*,*,2] & c3_3 = c3[*,*,3]

	im1 = fltarr(s[0],s[1]) + !values.f_nan
	if cnt1 ge 1 then im1[ind1] = c1_1[ind1]
	if cnt2 ge 1 then im1[ind2] = c2_1[ind2]
	if cnt3 ge 1 then im1[ind3] = c3_1[ind3]

	im2 = fltarr(s[0],s[1]) + !values.f_nan
	if cnt2 ge 1 then im2[ind2] = c2_2[ind2]
	if cnt3 ge 1 then im2[ind3] = c3_2[ind3]

	im3 = fltarr(s[0],s[1]) + !values.f_nan
	if cnt3 ge 1 then im3[ind3] = c3_3[ind3]
	out[*,*,1] = im1 & out[*,*,2] = im2 & out[*,*,3] = im3

	; zeroth slice
	im0 = fltarr(s[0],s[1]) + !values.f_nan
	if cnt1 ge 1 then im0[ind1] = c1_0[ind1]
	if cnt2 ge 1 then im0[ind2] = c2_0[ind2]
	if cnt3 ge 1 then im0[ind3] = c3_0[ind3]
	out[*,*,0] = im0

	return,out
END


FUNCTION sort_single_maps,c1,c2,c3,label
	s = size(c3,/dim)
	out = fltarr(s)
	ind1 = where(label eq 1,cnt1)
	ind2 = where(label eq 2,cnt2)
	ind3 = where(label eq 3,cnt3)
	if cnt1 gt 0 then out[ind1] = c1[ind1]
	if cnt2 gt 0 then out[ind2] = c2[ind2]
	if cnt3 gt 0 then out[ind3] = c3[ind3]

	return,out
END


FUNCTION sort_3d_cubes,c1_1,c2_1,c2_2,c3_1,c3_2,c3_3,label
	cube_out = fltarr([size(c1_1,/dim),3]) + !values.f_nan
	s = size(c1_1,/dim)
	for i=0,s[0]-1 do begin
		for j=0,s[1]-1 do begin
			CASE label[i,j] OF
				1: BEGIN
					cube_out[i,j,*,0]     = c1_1[i,j,*]
				END
				2: BEGIN
					; narrow component
					cube_out[i,j,*,0]     = c2_1[i,j,*]
					; 2nd comp.		
					cube_out[i,j,*,1]     = c2_2[i,j,*]
				END
				3: BEGIN
					; narrow component
					cube_out[i,j,*,0]     = c3_1[i,j,*]
					; 2nd component
					cube_out[i,j,*,1]     = c3_2[i,j,*]
					; 3rd component
					cube_out[i,j,*,2]     = c3_3[i,j,*]
				END
				ELSE:
			ENDCASE
		endfor
	endfor	; loop i,j
	return,cube_out
END



PRO merge_209807

	comp1_name = '../products/209807_1_comp.fits'
	comp2_name = '../products/209807_2_comp.fits'
	comp3_name = '../products/209807_3_comp.fits'
	merge_comp_name = '../products/209807_merge_comp.fits'
	merge_extname_arr = ['B_CONTINUUM','R_CONTINUUM','B_LINE','R_LINE','B_LINE_COMP1','R_LINE_COMP1','B_LINE_COMP2','R_LINE_COMP2','B_LINE_COMP3','R_LINE_COMP3', $
			             'V','V_ERR','VDISP','VDISP_ERR','CHI2','DOF','HBETA','HBETA_ERR','OIII5007','OIII5007_ERR','OI6300','OI6300_ERR',$
			             'HALPHA','HALPHA_ERR','NII6583','NII6583_ERR',$
			             'SII6716','SII6716_ERR','SII6731','SII6731_ERR']

    crit_sig = 0.01

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; READ IN DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; read in chi2 and dof
	c1_chi2 = mrdfits(comp1_name,'CHI2',/silent)
	c2_chi2 = mrdfits(comp2_name,'CHI2',/silent)
	c3_chi2 = mrdfits(comp3_name,'CHI2',/silent)
	
	c1_dof  = mrdfits(comp1_name,'DOF',/silent)
	c2_dof  = mrdfits(comp2_name,'DOF',/silent)
	c3_dof  = mrdfits(comp3_name,'DOF',/silent)
	c1_chi2 = c1_chi2 * c1_dof	
	c2_chi2 = c2_chi2 * c2_dof	
	c3_chi2 = c3_chi2 * c3_dof

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	s = size(c1_dof,/dim)

	
	; Initialize 
	sig12 = dblarr(s[0],s[1]) + !values.f_nan
	sig23 = dblarr(s[0],s[1]) + !values.f_nan
	sig13 = dblarr(s[0],s[1]) + !values.f_nan
	; Calculate significance with likelihood ratio test (see Ho et al. 2014, and Appendix of Ho et al. 2016)
	for i=0,s[0]-1 do begin 
		for j=0,s[1]-1 do begin 
				sig12[i,j] = 1 - chisqr_pdf(c1_chi2[i,j] - c2_chi2[i,j],c1_dof[i,j] - c2_dof[i,j])
				sig23[i,j] = 1 - chisqr_pdf(c2_chi2[i,j] - c3_chi2[i,j],c2_dof[i,j] - c3_dof[i,j])
				sig13[i,j] = 1 - chisqr_pdf(c1_chi2[i,j] - c3_chi2[i,j],c1_dof[i,j] - c3_dof[i,j])
		endfor
	endfor

	; Make component map ("label") based on the significance maps
	label = intarr(s[0],s[1]) + !values.f_nan
	for i=0,s[0]-1 do begin 
		for j=0,s[1]-1 do begin
			if ~ finite(c1_chi2[i,j]) and ~ finite(c2_chi2[i,j]) and ~ finite(c3_chi2[i,j]) then continue

			if sig12[i,j] lt crit_sig and finite(c2_chi2[i,j]) then begin  ;2 is better than 1
				; proceed to 2-3 comparison
				if sig23[i,j] lt crit_sig and finite(c3_chi2[i,j]) then begin
					label[i,j] = 3
					continue
				endif else begin	; 2 is better than 3
					label[i,j] = 2
					continue
				endelse
			endif else begin  ; 1 is better than 2
				; 1 - 3 comparison
				if sig13[i,j] lt crit_sig and finite(c3_chi2[i,j]) then begin ; 3 is better than 1
					label[i,j] = 3
					continue
				endif else begin	; 1 is better than 3 (also better than 2)
					label[i,j] = 1	
					continue
				endelse
			endelse
		endfor
	endfor


	; Sort line cubes based on the component map
	b_line_1_1 = mrdfits(comp1_name,'B_LINE_COMP1',/silent)
	b_line_2_1 = mrdfits(comp2_name,'B_LINE_COMP1',/silent)
	b_line_2_2 = mrdfits(comp2_name,'B_LINE_COMP2',/silent)
	b_line_3_1 = mrdfits(comp3_name,'B_LINE_COMP1',/silent)
	b_line_3_2 = mrdfits(comp3_name,'B_LINE_COMP2',/silent)
	b_line_3_3 = mrdfits(comp3_name,'B_LINE_COMP3',/silent)
	tmp = sort_3d_cubes(b_line_1_1,b_line_2_1,b_line_2_2,b_line_3_1,b_line_3_2,b_line_3_3,label)
	b_line = total(tmp,4,/nan) & b_line_comp1 = tmp[*,*,*,0] & b_line_comp2 = tmp[*,*,*,1] & b_line_comp3 = tmp[*,*,*,2]

	r_line_1_1 = mrdfits(comp1_name,'R_LINE_COMP1',/silent)
	r_line_2_1 = mrdfits(comp2_name,'R_LINE_COMP1',/silent)
	r_line_2_2 = mrdfits(comp2_name,'R_LINE_COMP2',/silent)
	r_line_3_1 = mrdfits(comp3_name,'R_LINE_COMP1',/silent)
	r_line_3_2 = mrdfits(comp3_name,'R_LINE_COMP2',/silent)
	r_line_3_3 = mrdfits(comp3_name,'R_LINE_COMP3',/silent)
	tmp = sort_3d_cubes(r_line_1_1,r_line_2_1,r_line_2_2,r_line_3_1,r_line_3_2,r_line_3_3,label)
	r_line = total(tmp,4,/nan) & r_line_comp1 = tmp[*,*,*,0] & r_line_comp2 = tmp[*,*,*,1] & r_line_comp3 = tmp[*,*,*,2]

	; Output merge cube
    ; Read 0th extension of from 3
    dum = mrdfits(comp3_name,0,header0,/silent)
	; Update header
	for i=0,n_elements(merge_extname_arr)-1 do $
	    fxaddpar,header0,'EXT'+strtrim(i+1,2),merge_extname_arr[i]
    ; Add comp_map extension
    fxaddpar,header0,'EXT'+strtrim(n_elements(merge_extname_arr),2),'COMP_MAP','Component map'    
	; Write 0th extension
	writefits,merge_comp_name,0,header0

	
	; Write other extensions
	for ext = 0,n_elements(merge_extname_arr)-1 do begin
		extname = strupcase(strtrim(merge_extname_arr[ext],2))
		; if continuum related. propagate through...
		if is_cont_cube(extname) then begin
			data = mrdfits(comp3_name,extname,header,/silent)
			writefits,merge_comp_name,data,header,/append 
			continue
		endif
		; if line maps related, sort with label
		if is_line_map(extname) then begin
			data3 = mrdfits(comp3_name,extname,header,/silent)
			data2 = mrdfits(comp2_name,extname,/silent)
			data1 = mrdfits(comp1_name,extname,/silent)
			data = sort_2d_maps(data1,data2,data3,label)
			writefits,merge_comp_name,data,header,/append 
			continue
		endif

		; if line cubes... these are pre-sorted before entering the loop
		if is_line_cube(extname) then begin
			header = headfits(comp3_name, EXTEN = extname,/silent)
			void = execute('data = ' + extname)
			writefits,merge_comp_name,data,header,/append 
			continue
		endif

		; if chi2 and dof. use sort_single_maps
		if extname EQ 'CHI2' or extname EQ 'DOF' then begin
			data3 = mrdfits(comp3_name,extname,header,/silent)
			data2 = mrdfits(comp2_name,extname,/silent)
			data1 = mrdfits(comp1_name,extname,/silent)
			data = sort_single_maps(data1,data2,data3,label)
			writefits,merge_comp_name,data,header,/append 
			continue
		endif
		
		message,"You should never get here. This extension is not recognize by the script:" + extname
		
	endfor

	; Write component map (label) at the end
	fxhmake,header,xtension='IMAGE'
	fxaddpar,header,'EXTNAME','COMP_MAP'
	writefits,merge_comp_name,label,header,/append 
	
	print,'Finish merging:' + merge_comp_name

END


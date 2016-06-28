FUNCTION lzifu_sort_order,param,set
	; get sorting order based on param array
  	ppoff = param[0]
  	; If sorting w/ line flux
	if ~ strcmp(set.sort_type,'vdisp',/fold_case) and ~strcmp(set.sort_type,'vel',/fold_case) then begin
		linelabel = (call_function(set.linelist_func,/fit_line)).label
		nline = n_elements(linelabel)
		iline = (where(strtrim(strupcase(linelabel),2) EQ strtrim(strupcase(set.sort_type),2),cnt))[0]
		if cnt NE 1 then message,'You should never get to here...'
		ifoff = ppoff + set.ncomp * 2 + indgen(set.ncomp) * nline *3 + iline * 3   ;peak flux
;		iwoff = ifoff + 1  ;wavelength
		isoff = ifoff + 2  ;sigma 
		sort_ref = param[ifoff] * param[isoff]
		; Sorting 
		order = reverse(sort(sort_ref)) ; line fluxes... large to small
	endif else begin ; if sorting w/ vdisp or vel
		if strcmp(set.sort_type,'vdisp',/fold_case) then $
			sort_ref = param[ ppoff + indgen(set.ncomp) * 2 + 1]
		if strcmp(set.sort_type,'vel',/fold_case) then $
			sort_ref = param[ ppoff + indgen(set.ncomp) * 2]
		; Sorting
		order = sort(sort_ref)   ; vel and vdisp... small to large
	endelse	

	return,order
END
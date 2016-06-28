PRO lzifu_callback, status, error, bridge, ud

	; get the fit structure out of the bridge!
	; create empty structure
	fit={}

	; get tag names first
	bridge -> execute,'tags = tag_names(fit)'
	tags = bridge -> getvar('tags')

	for i=0,n_elements(tags)-1 do begin
		var = bridge -> getvar('fit.'+tags[i])
		fit = add_tag(fit,var,tags[i])		
	endfor

	(*ud)->add,fit

END

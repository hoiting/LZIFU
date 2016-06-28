FUNCTION lzifu_fit_residual,x,y,err,degree = m ,goodpixels = ind
	; fit residuals with Legendre Polynomial using BVLS in PPXF
	; fit twice. reject outliers to increase robustness. 
	reject_crit = 5. ; outlier rejection criteria
	if m lt 1 then begin
		print,'LZIFU_FIT_RESIDUAL: Degree of freedom < 1. Skip fitting residuals.'
		return,x*0
	endif
	if ind[0] eq -1 or n_elements(ind) LT m then return,x*0		

	; remove nan in y and yerr from ind. just in case.
	dum = where(~ finite(y) or ~ finite(err),complement=dum_c,cnt)
	if cnt gt 0 then ind = cmset_op(ind,'AND',dum_c)
	
	n = n_elements(x)
	poly_arr = fltarr(n,m+1)
	legendre_x = cap_range(-1,1,n)
	; Create m Lengendre basis 
	for i = 0, m do $
		poly_arr[*,i] = legendre(legendre_x,i)/err

	; Create bnd for bvls. There is no boundary.
	bnd = fltarr(2,m+1)
	bnd[0,*] = -(MACHAR()).XMAX 
	bnd[1,*] = (MACHAR()).XMAX	
	; CHI2 minimization with BVLS
	bvls,poly_arr[ind,*],y[ind]/err[ind],bnd,coeff

	; Reconstruct the fit
	fit = (poly_arr # coeff) * err
	; find outliers
	resid = (y - fit) / err
	sig = robust_sigma(resid[ind])
	out_ind = where(abs(resid) gt reject_crit * sig,complement = not_out_ind,cnt)
	if cnt gt 0 then begin  ; reject outliers and then fit again
		new_ind = cmset_op(ind,'AND',not_out_ind)
		bvls,poly_arr[new_ind,*],y[new_ind]/err[new_ind],bnd,coeff
		; Reconstruct the fit
		fit = (poly_arr # coeff) * err
		ind = new_ind ; also output outlier rejected indices
	endif

	return,fit
END

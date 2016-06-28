FUNCTION gaus,wave_l,wave_r,flux,refwave,sig,nwave,nline
	flux_arr = fltarr(nwave)
	d_wave_rl = wave_r - wave_l
	sqrt_pi_2 = sqrt(!PI/2)
	sqrt_2    = sqrt(2)
	; with error function:
	for i = 0,nline-1 do $
		flux_arr     = flux_arr + $
		               flux[i] * sig[i] * sqrt_pi_2 * $
    	               ( erf( (wave_r - refwave[i])/sqrt_2/sig[i]) - erf( (wave_l - refwave[i])/sqrt_2/sig[i]) ) / d_wave_rl
	return,flux_arr
END

FUNCTION amp_deriv,wave_l,wave_r,refwave,sig
	return, sig * sqrt(!PI/2) * ( erf( (wave_r - refwave)/sqrt(2)/sig) - erf( (wave_l - refwave)/sqrt(2)/sig) ) / (wave_r - wave_l)
END

FUNCTION z_deriv,wave_l,wave_r,z,flux,refwave,sig,nwave,nline
	d_wave_rl = wave_r - wave_l
	; partial derivative w.r.t z
	; amp * (wave - refwave) * linewave / sig^2 * exp(-(wave - refwave)^2 / sig / sig / 2d)
	linewave     = refwave / (1+z)
	const        = flux * linewave / sig^2
	; analytical form:
	dp = fltarr(nwave)
	for i = 0,nline-1 do $
		dp = dp + $
		     const[i] * sig[i]^2 * $
	         (  exp(- (wave_l - refwave[i])^2/sig[i]^2/2d) - exp(- (wave_r - refwave[i])^2/sig[i]^2/2d) ) /  (d_wave_rl)
	return, dp
END

FUNCTION vdisp_deriv,wave_l,wave_r,z,vdisp,flux,refwave,sig,nwave,nline
	; partial derivative w.r.t vdisp
	; amp * vdisp * linewave^2 * (1+z)^2 / sig^4 / light_speed^2 * (wave - refwave)^2 * 
	; exp(-(wave - refwave)^2 / sig / sig / 2d)
	d_wave_rl = wave_r - wave_l
	sqrt_pi_2 = sqrt(!PI/2)
	sqrt_2    = sqrt(2)
	dp = fltarr(nwave)	
	light_speed = 299792.458d ; speed of light in km/s
;	linewave     = refwave / (1+z)
	const        = flux * abs(vdisp) * refwave^2 / sig^4 / light_speed^2
	; analytical form:
	for i = 0,nline - 1 do begin 
		dwave_l = wave_l - refwave[i]
		dwave_r = wave_r - refwave[i]
		dum_l = sqrt_pi_2 * sig[i]^3 * erf( dwave_l / sig[i] / sqrt_2 ) - sig[i]^2 * dwave_l * exp(-dwave_l^2 / sig[i]^2 / 2d) 
		dum_r = sqrt_pi_2 * sig[i]^3 * erf( dwave_r / sig[i] / sqrt_2 ) - sig[i]^2 * dwave_r * exp(-dwave_r^2 / sig[i]^2 / 2d) 
		dp = dp + const[i] * (dum_r - dum_l) / (d_wave_rl)
	endfor
	return, dp
END

FUNCTION del_b_lambda_deriv,wave_l,wave_r,param,ncomp,nwave,br_sep_point
	; partial derivative w.r.t. del_b_lambda
	; amp * (wave - refwave) / sig^2 * exp(-(wave - refwave)^2 / sig / sig / 2d)
	; sum all blue lines. 
  	ppoff = param[0]
  	nline = param[1]
	if br_sep_point eq 0 then return,replicate(0.,nwave)
	; get all line index
	find = []
	for icomp=0,ncomp-1 do $
		find = [find, ppoff + ncomp*2 + indgen(nline)*3 + icomp * nline * 3]
	wind = find + 1
	; determine which lines are in the blue
	b_ind = where(param[wind] LE wave_r[br_sep_point-1],nline)
	if nline eq 0 then return,replicate(0.,nwave)
	find = find[b_ind]
	wind = find + 1
	sind = find + 2			

	dp = fltarr(nwave)	
	flux    =   param[find]
	refwave =   param[wind] 
	sig     =   param[sind]
	const   =   param[find] / param[sind]^2
	d_wave_rl = wave_r - wave_l
	for i = 0,nline-1 do $
		dp = dp + $
			 const[i] * sig[i]^2 * $
		     (  exp(- (wave_l - refwave[i])^2/sig[i]^2/2d) - exp(- (wave_r - refwave[i])^2/sig[i]^2/2d) ) /  (d_wave_rl)
	return,dp
END

PRO seperate_wave,wave,nwave,set,br_sep_point,wave_l = wave_l,wave_r = wave_r
	CASE br_sep_point of  ; 0 -> only red side. nwave -> only blue side. others-> both sides.
			0:	BEGIN
				wave_l = wave - set.r_channel_width/2.
				wave_r = wave + set.r_channel_width/2.
			END
		nwave:BEGIN
				wave_l = wave - set.b_channel_width/2.
				wave_r = wave + set.b_channel_width/2.
			END
		ELSE:BEGIN
			wave_l  = wave
			wave_r  = wave
			wave_l[0:br_sep_point-1,*]  = wave_l[0:br_sep_point-1,*] - set.b_channel_width/2.
			wave_l[br_sep_point : *,*]  = wave_l[br_sep_point : *,*] - set.r_channel_width/2.
			wave_r[0:br_sep_point-1,*]  = wave_r[0:br_sep_point-1,*] + set.b_channel_width/2.
			wave_r[br_sep_point : *,*]  = wave_r[br_sep_point : *,*] + set.r_channel_width/2.
			END
	ENDCASE ; case br_sep_point
END

FUNCTION calc_jacobian,wave,wave_l,wave_r,param,dp,set,br_sep_point
	; Calculate jacobian Analytically
  	ppoff = param[0]
	nwave = n_elements(wave)
  	nline = param[1]
	requested = dp
	dp = make_array(nwave, n_elements(param), value=0.)
	; separate left and right side of wave
;	seperate_wave,wave,nwave,set,br_sep_point,wave_l = wave_l,wave_r = wave_r			
	for i = 0, n_elements(param)-1 do begin 
		if requested(i) EQ 0 then continue   ; jacobian not required
		if i LT ppoff - 1 then $
			message,'Calculating Jacobian. LZIFU should never get here!!!'

		if i eq 2 then begin
			dp[*,i] = del_b_lambda_deriv(wave_l,wave_r,param,set.ncomp,nwave,br_sep_point)
			continue
		endif

		icomp = fix((i - ppoff - 2*set.ncomp) / (nline*3)) 
		iline = fix((i - ppoff - 2*set.ncomp - icomp * nline*3 ) / 3)
		indx_lo = ppoff + 2 * set.ncomp

		; derivative w.r.t. amplitude
		if icomp ge 0 and iline ge 0 and iline lt nline and i ge indx_lo then begin
			z     = param[ppoff + 2 * icomp]
			vdisp = param[ppoff + 2 * icomp + 1]
;			print,i,'A line flux',param[i],icomp,iline,z,vdisp
			dp[*,i] = amp_deriv(wave_l,wave_r,param[i+1],param[i+2])			
			continue
		endif

		; derivative w.r.t. Z
		if (i - ppoff) mod 2 eq 0 and i lt indx_lo then begin
			icomp = fix((i-ppoff)/2)   ; 0,1,2,
			find = ppoff+ set.ncomp*2 + indgen(nline)*3 + icomp * nline * 3
			wind = find + 1
			sind = find + 2			
;			print,i,'Z',param[i],icomp,find
			dp[*,i] = z_deriv(wave_l,wave_r,param[i],param[find],param[wind],param[sind],nwave,nline)
			continue
		endif

		; derivative w.r.t. vdisp
		if (i - ppoff) mod 1 eq 0 and i lt indx_lo then begin
			icomp = fix((i-ppoff)/2)    ; 0,1,2,
			find = ppoff+ set.ncomp*2 + indgen(nline)*3 + icomp * nline * 3
			wind = find + 1
			sind = find + 2			
			iz   = i - 1
;			print,i,'vdisp',param[i],icomp
			dp[*,i] = vdisp_deriv(wave_l,wave_r,param[iz],param[i],param[find],param[wind],param[sind],nwave,nline)
			continue
		endif

		message,'Calculating Jacobian. LZIFU should never get here!!!'
	endfor
	return,dp
END

FUNCTION lzifu_manygauss, wave, param, dp, set = set , sep_comp = sep_comp, $
                          br_sep_point = br_sep_point
	; Line model: Many Gaussians stacked together...
	; Keywords: [sep_comp]
	;           Separate and sort different components in the output. For reconstructing output.
	;           Not called by MPFIT. 
	;           [br_sep_point]
	;           position in wave where b and r side separate. 
  	ppoff = param[0]
	nwave = n_elements(wave)
  	nline = param[1]
	flux = fltarr(nwave)

	if not keyword_set(sep_comp) then begin
		; separate left and right side of wave
		seperate_wave,wave,nwave,set,br_sep_point,wave_l = wave_l,wave_r = wave_r
		for icomp = 1,set.ncomp do begin
			find = ppoff+ set.ncomp*2 + indgen(nline)*3 + (icomp-1) * nline * 3
			wind = find + 1
			sind = find + 2
			; make spectrum.
			flux = gaus(wave_l,wave_r,param[find],param[wind],param[sind],nwave,nline) + flux
		endfor ; component for loop
		; Compute derivative if requested by caller. calculate derivative of the model (jacobian) analytically for mpfit to use.
		if n_params() GT 2 then dp = calc_jacobian(wave,wave_l,wave_r,param,dp,set,br_sep_point)
		return,flux	
	endif else begin   ; if sep_comp set. calculate output
		b_str = 'b_linefit_'+ strtrim(indgen(set.ncomp)+1,2)
		r_str = 'r_linefit_'+ strtrim(indgen(set.ncomp)+1,2)
		b_flux = fltarr(set.b_zsize)
		r_flux = fltarr(set.r_zsize)
		out = {b_linefit:b_flux,r_linefit:r_flux}
		for c = 0,set.ncomp-1 do begin
			out = add_tag(out,b_flux,b_str[c])
			out = add_tag(out,r_flux,r_str[c])
		endfor
;		; Sorting
		order = lzifu_sort_order(param,set)

		for c = 0,set.ncomp-1 do begin
			icomp = order[c] +1
			find = ppoff+ set.ncomp*2 + indgen(nline)*3 + (icomp-1) * nline * 3
			wind = find + 1
			sind = find + 2	
			; make spectrum. 
			b_wave = wave[0:set.b_zsize-1]
			r_wave = wave[set.b_zsize:*]
			n_b = n_elements(b_wave)
			n_r = n_elements(r_wave)
			b_flux = gaus(b_wave - set.b_channel_width/2,b_wave + set.b_channel_width/2,$
			              param[find],param[wind],param[sind],n_b,nline)
			r_flux = gaus(r_wave - set.r_channel_width/2,r_wave + set.r_channel_width/2,$
			              param[find],param[wind],param[sind],n_r,nline)
			flux_comp  = [b_flux,r_flux] 
			void = execute('out.b_linefit_'+strtrim(c+1,2)+' = flux_comp[0:set.b_zsize-1]')
			void = execute('out.r_linefit_'+strtrim(c+1,2)+' = flux_comp[set.b_zsize:-1]')
			flux         = flux_comp + flux			
		endfor
		out.b_linefit = flux[0:set.b_zsize-1]
		out.r_linefit = flux[set.b_zsize:*]
		return,out    ; output is "flux"
	endelse

END

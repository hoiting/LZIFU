FUNCTION lzifu_initpar,data,set,linelist,$
                       b_indline = b_indline,r_indline= r_indline,$
                       param = param

	light_speed = 299792.458 ; speed of light in km/s
	linewave = linelist.wave
	linelabel = linelist.label

	; Estimate redshift
	; if z_star not too crazy. use it. else use systemic z. 
	; velocity difference < 300 km/s and velocity dispersion < 300 km/s
	; velocity err < 100 km/s
	; errors are not zero (doesn't touch boundary)
	if tag_exist(data,'starvel') and tag_exist(data,'starvdisp') and tag_exist(data,'starvel_err') and $
	   tag_exist(data,'starvdisp_err') and tag_exist(data,'z_star') then begin
		if abs(data.starvel) LT 300 and abs(data.starvdisp)  LT 300 and $
		   data.starvel_err LT 100 and $
		   data.starvel_err GT 0 and data.starvdisp_err GT 0 then begin
			z = data.z_star[0]
		endif else begin
			z = set.z
		endelse
	endif else z = set.z
	
	linewavez = linewave * (1 + set.z)
	nline = n_elements(linelabel)


	; Find out where the lines are (indexes) in [br]+lambda
	; These are also outputs. For later use on chopping channels near lines to form a new spectrum
	b_indline = fltarr(nline) & b_indline[*] = !values.f_nan
	r_indline = fltarr(nline) & r_indline[*] = !values.f_nan
	side = replicate('',nline)

	for iline = 0, nline-1 do begin
		b_ind=where( abs(data.b_lambda-linewavez[iline]) le set.b_channel_width/2. and finite(data.b_flux_nocnt) and data.b_mask eq 1,bcnt)
	  	r_ind=where( abs(data.r_lambda-linewavez[iline]) le set.r_channel_width/2. and finite(data.r_flux_nocnt) and data.r_mask eq 1,rcnt)
		if bcnt eq 1 then side[iline] = 'B'
		if rcnt eq 1 then side[iline] = 'R'
	  	if linewavez[iline] LT max(data.b_lambda) AND linewavez[iline] GT min(data.b_lambda) and bcnt GT 0 $
  		   and abs(data.b_lambda[b_ind[0]]-linewavez[iline]) LT 5 then b_indline[iline] = b_ind[0]
	  	if linewavez[iline] LT max(data.r_lambda) AND linewavez[iline] GT min(data.r_lambda) and rcnt GT 0 $
  		   and abs(data.r_lambda[r_ind[0]]-linewavez[iline]) LT 5 then r_indline[iline] = r_ind[0]
  	endfor
	; extract peak flux guess at each line
	; this is to find line peak. search +/- 300km/s for max values. 
	dv = float(300)
	line_peak = fltarr(nline) & line_peak[*] = !values.f_nan
	line_peak_err = line_peak
	tmp_b_indline = b_indline   &   tmp_r_indline = r_indline ; temporary variable. record new index. 

	for iline = 0, nline-1 do begin 
		;blue side
	  	if finite(b_indline[iline]) then begin
	  		width = sqrt( (dv/light_speed*linewavez[iline])^2+set.b_resol_sigma^2) /set.b_channel_width
			b_left = b_indline[iline] - width GE 0 ? b_indline[iline] - width  : 0
			b_right= b_indline[iline] + width LT n_elements(data.b_flux_nocnt)-1 ? b_indline[iline] + width : n_elements(data.b_flux_nocnt)-1
			b = abs(max(data.b_flux_nocnt[b_left: b_right]/data.b_flux_err[b_left: b_right],ind_bmax,/nan))			
			b_err = data.b_flux_err[ b_left + ind_bmax ]
			tmp_b_indline[iline] = b_left + ind_bmax
		endif else begin 
			b     = !values.f_nan
			b_err = !values.f_nan
		endelse
		; red side
  		if finite(r_indline[iline]) then begin
	  		width= sqrt( (dv/light_speed*linewavez[iline])^2+set.r_resol_sigma^2) /set.r_channel_width
			r_left = r_indline[iline] - width GE 0 ? r_indline[iline] - width  : 0
			r_right= r_indline[iline] + width LT n_elements(data.r_flux_nocnt)-1 ? r_indline[iline] + width : n_elements(data.r_flux_nocnt)-1
			r = abs(max(data.r_flux_nocnt[r_left: r_right]/data.r_flux_err[r_left: r_right],ind_rmax,/nan))
			r_err = data.r_flux_err[ r_left + ind_rmax ]
			tmp_r_indline[iline] = r_left + ind_rmax
		endif else begin
			r     = !values.f_nan
			r_err = !values.f_nan
		endelse
	  	line_peak[iline] = mean([b,r],/nan)
	  	line_peak_err[iline] = mean([b_err,r_err],/nan)
	endfor

	; find out which line has the maximum s/n line peak. update z with that info. 
	; as well as [br]_indline
	if max(line_peak/line_peak_err,peak_ind,/nan) gt 5 then begin	; only do when S/N is good
		peak_side = side[peak_ind]		
		if peak_side eq 'R' then begin
			del_r_ind =  tmp_r_indline[peak_ind] - r_indline[peak_ind]
			del_b_ind = del_r_ind * set.r_channel_width/set.b_channel_width
			r_indline = r_indline + round(del_r_ind)
			b_indline = b_indline + round(del_b_ind)
			del_lambda = del_r_ind * set.r_channel_width
			z = z + del_lambda / linewave[peak_ind]
		endif
		if peak_side eq 'B' then begin
			del_b_ind =  tmp_b_indline[peak_ind] - b_indline[peak_ind]
			del_r_ind = del_b_ind * set.b_channel_width/set.r_channel_width
			b_indline = b_indline + round(del_b_ind)
			r_indline = r_indline + round(del_r_ind)
			del_lambda = del_b_ind * set.b_channel_width
			z = z + del_lambda / linewave[peak_ind]
		endif
	endif
	

	; Number of velocity components  ; not used for now. 
	ncomp = set.ncomp

	; Number of initial parameters before Gaussian parameters begin
	ppoff = 3

	; Number of emission lines to fit
	parinfo_template = REPLICATE({value:0d, fixed:0, limited:[0B,0B], tied:'', $
    	                   limits:[0D,0D], step:0d, mpprint:0b, label:'', type:''},$
        	               ppoff + ncomp*(nline) *3 + ncomp * 2)  
	parindx = indgen(n_elements(parinfo_template))

	; variation in initial guess
	; create empty initial guess
	par_guess ={parinfo_1: parinfo_template}
	if keyword_set(param) EQ 0 then $ ; if external guess is not provided. make multiple guesses
		for i=2,set.n_guess do par_guess = add_tag(par_guess,parinfo_template,'parinfo_'+strtrim(i,2))	

	; make arrays of variations in damp, dvel, and dvdisp
	CASE set.ncomp OF 
		1:
		2:	BEGIN
		damp2    = []
		dvel2    = []
		dvdisp2  = []
		for iamp2   = 0,n_elements(set.comp_2_damp)-1 do begin
		for ivel2   = 0,n_elements(set.comp_2_dvel)-1 do begin
		for ivdisp2 = 0,n_elements(set.comp_2_dvdisp)-1 do begin
			damp2   = [damp2,set.comp_2_damp[iamp2] ]
			dvel2   = [dvel2,set.comp_2_dvel[ivel2] ]
			dvdisp2 = [dvdisp2,set.comp_2_dvdisp[ivdisp2] ]
		endfor & endfor & endfor		
			END
		3: BEGIN
		damp2    = []
		dvel2    = []
		dvdisp2  = []
		damp3    = []
		dvel3    = []
		dvdisp3  = []
		for iamp2   = 0,n_elements(set.comp_2_damp)-1 do begin
		for ivel2   = 0,n_elements(set.comp_2_dvel)-1 do begin
		for ivdisp2 = 0,n_elements(set.comp_2_dvdisp)-1 do begin
		for iamp3   = 0,n_elements(set.comp_3_damp)-1 do begin
		for ivel3   = 0,n_elements(set.comp_3_dvel)-1 do begin
		for ivdisp3 = 0,n_elements(set.comp_3_dvdisp)-1 do begin
			damp2   = [damp2,set.comp_2_damp[iamp2] ]
			dvel2   = [dvel2,set.comp_2_dvel[ivel2] ]
			dvdisp2 = [dvdisp2,set.comp_2_dvdisp[ivdisp2] ]
			damp3   = [damp3,set.comp_3_damp[iamp3] ]
			dvel3   = [dvel3,set.comp_3_dvel[ivel3] ]
			dvdisp3 = [dvdisp3,set.comp_3_dvdisp[ivdisp3] ]
		endfor & endfor & endfor & endfor & endfor & endfor
			END
		ELSE: BEGIN
			message,'You should never get to here....',/continue
			stop
			END
	ENDCASE
	damp1 = replicate(1.,set.n_guess)
	dvel1 = replicate(0.,set.n_guess)
	dvdisp1 = replicate(0.,set.n_guess)

	for i_guess =1,set.n_guess do begin
		; extract parinfo_"i_guess" from par_guess
		dum = execute ( 'parinfo = par_guess.parinfo_'+strtrim(i_guess,2) )

		; Number of initial parameters before Gaussian parameters begin
		; [ppoff (3),nline,del_b_lambda,z1,disp1,z2,disp2,line1(3),line2(3),...,line1(3),line2(3),...]
		parinfo[0].value = ppoff
		parinfo[0].fixed = 1B
		parinfo[0].label = 'ppoff'

		; Number of lines
		parinfo[1].value = nline
		parinfo[1].fixed = 1B  
		parinfo[1].label = 'nline'

		; dlambda 
		parinfo[2].value = set.del_b_lambda
		parinfo[2].fixed = 1 - set.fit_del_b_lambda   ; fit_del_b_lambda = 0 = not fit. fit_del_b_lambda = 1 = fit. 
		parinfo[2].label = 'del_b_lambda'
		parinfo[2].limited = [1B,1B]
		parinfo[2].limits  = [-1.,1.]*set.b_channel_width ; from -1 to 1 x channel width
  
		FOR c = 1,ncomp DO BEGIN
			dum = execute( 'dz = dvel' + strtrim(c,2) +'[i_guess-1] / light_speed')
			ind = ppoff+(c-1)*2
			parinfo[ind].value   = z + dz
			parinfo[ind].limited = [1B,1B]
			parinfo[ind].limits  = z + set.vel_ran/light_speed
			parinfo[ind].mpprint = 1b
			parinfo[ind].label = 'z comp '+strtrim(c,2)
			; linewidth (km/s)
			dum = execute( 'dvdisp = dvdisp' + strtrim(c,2) +'[i_guess-1]')
			ind = ppoff+(c-1)*2+1
			parinfo[ind].value    = set.line_sig_guess + dvdisp
			parinfo[ind].limited  = [1B,1B]
			parinfo[ind].limits   = [set.vdisp_ran[0],set.vdisp_ran[1]] ; can't be negative. can't be higher than vdisp_kms[1]
			parinfo[ind].mpprint  = 1b
			parinfo[ind].label    = 'line width comp '+strtrim(c,2)
		ENDFOR
		; Calculate damp normalization so that the sum are still at peak values.
		sum_amp = fltarr(nline) + 1
		FOR iline = 0 ,nline-1 DO BEGIN
			inst_disperse = side[iline] eq 'B' ? set.b_resol_sigma : set.r_resol_sigma
			FOR icomp = 2,set.ncomp DO BEGIN
				; extract dvdisp dvel, and damp
				void = execute('dvdisp = dvdisp'+ strtrim(icomp,2) + '[i_guess-1]')
				void = execute('dvel   = dvel'  + strtrim(icomp,2) + '[i_guess-1]')
				void = execute('damp   = damp'  + strtrim(icomp,2) + '[i_guess-1]')
				d_lambda = linewave[iline] *   dvel / light_speed + inst_disperse
				d_sigma  = linewave[iline] * dvdisp / light_speed + inst_disperse
				sum_amp[iline] = sum_amp[iline] + damp* exp(-1.*d_lambda^2/d_sigma^2/2)
			ENDFOR
		ENDFOR

		; Assign line width, line flux, and wavelength!
		FOR icomp = 1, ncomp DO BEGIN
			zindx = ppoff + (icomp-1) * 2      ; common redshift
    	    sindx = ppoff + (icomp-1) * 2 + 1  ; common sigma
			dum = execute( 'damp = damp' + strtrim(icomp,2) +'[i_guess-1]')

			FOR iline=0, nline-1 DO BEGIN
			
				; Find index
				ifoff = ppoff + ncomp*2+ iline*3+(icomp-1)*nline*3    ;peak flux
				iwoff = ifoff+1                     ; wavelength
				isoff = ifoff+2                     ; sigma 

			    parinfo[ifoff].label = linelabel[iline] & parinfo[ifoff].type  = 'Flux'
    			parinfo[iwoff].label = linelabel[iline] & parinfo[iwoff].type  = 'Wave (A)'
    			parinfo[isoff].label = linelabel[iline] & parinfo[isoff].type  = 'Width (A)'    
	
				; if line doesn't fall into wavelength range then don't fit that one.
				; still set none zero values to avoid overflow
				if side[iline] eq ''  then begin
					parinfo[ifoff].fixed = 1B 
					parinfo[ifoff].value = set.minfluxconst
					parinfo[iwoff].fixed = 1B
					parinfo[iwoff].value = linewavez[iline]
					parinfo[isoff].fixed = 1B
					parinfo[isoff].value = sqrt(parinfo[4].value/light_speed*linewavez[iline]^2)  ; doesn't matter. won't use. 
					continue
			    endif

				; peak flux
	    		parinfo[ifoff].value = line_peak[iline] * damp / sum_amp[iline]

				;; Special treatment for O2 doublet cause they are usually too close to each other
				if parinfo[ifoff].label eq 'OII3726' then parinfo[ifoff].value = line_peak[iline]/2 * damp
				if parinfo[ifoff].label eq 'OII3729' then parinfo[ifoff].value = line_peak[iline]/2 * damp

			    parinfo[ifoff].limited[0] = 1B
			    parinfo[ifoff].limits[0]  = 0d    ; flux can't be negative
    			; wavelength
			    parinfo[iwoff].value = linewave[iline,0] * (1 + parinfo[zindx].value)   ; tied to common redshift
		    
    			; fix to the same redshift
    			if side[iline] eq 'B' then $
			    	parinfo[iwoff].tied = string(linewave[iline],format='(D0.2)')+'*(1. + P['+string(zindx,format='(I0)')+']) + P[2]' $
    			else $
			    	parinfo[iwoff].tied = string(linewave[iline],format='(D0.2)')+'*(1. + P['+string(zindx,format='(I0)')+'])'    			

				; sigma set to initial vdisp and tie together
				if side[iline] eq 'B' then inst_disperse = set.b_resol_sigma
				if side[iline] eq 'R' then inst_disperse = set.r_resol_sigma
	
			    parinfo[isoff].value = sqrt( (parinfo[sindx].value/light_speed*linewavez[iline])^2+inst_disperse^2)

				; all linewidth tied to parinfo[3]
			    ;P[N] = sqrt(   (P[4]/c* linewave *( 1 + z) )^2 + set.b_resol_sigma^2 ) 
			    parinfo[isoff].tied = $   
				    'sqrt( (P[' + string(sindx,format='(I0)')+'] / 2.99792458e5 *'+ string(linewavez[iline],format='(F0.2)') + $
			    	')^2 + '+string(inst_disperse^2,format='(F0.7)')+' )'

			ENDFOR   ;iline
		ENDFOR	; icomp
	
		; Tie some lines together
		FOR icomp = 1,ncomp DO BEGIN
			indx_lo = ppoff + 2 * ncomp + (icomp -1)*nline*3
			indx_hi = indx_lo + nline * 3 -1
			; tie 4959 to 1/3 of 5007
			linea = where(parinfo.label eq 'OIII4959' and parinfo.type eq 'Flux' and parindx ge indx_lo and parindx le indx_hi,cta)
			lineb = where(parinfo.label eq 'OIII5007' and parinfo.type eq 'Flux' and parindx ge indx_lo and parindx le indx_hi,ctb)

			if (cta gt 0 AND ctb gt 0) then begin
    			parinfo[linea].tied = 'P['+string(lineb,format='(I0)')+']/2.94118'    ; ratio tied to 1/3 (Osterbrock & Ferland Astrophysics of gas nebulae and AGN, 2nd edition, p 56).
    			if parinfo[linea].fixed EQ 1 or parinfo[lineb].fixed EQ 1 then begin
					parinfo[linea:linea+2].fixed =1   & parinfo[linea].value=set.minfluxconst
			    	parinfo[lineb:lineb+2].fixed =1   & parinfo[lineb].value=set.minfluxconst
					inda=where(linelabel eq 'OIII4959') & indb=where(linelabel eq 'OIII5007')
					r_indline[inda]= !values.f_nan & r_indline[indb]= !values.f_nan 
					b_indline[inda]= !values.f_nan & b_indline[indb]= !values.f_nan 
					side[inda] = '' & side[indb] = ''				
				endif
			endif
			; tie 6548 to 1/3 of 6583
			linea = where(parinfo.label eq 'NII6548' and parinfo.type eq 'Flux' and parindx ge indx_lo and parindx le indx_hi,cta)
			lineb = where(parinfo.label eq 'NII6583' and parinfo.type eq 'Flux' and parindx ge indx_lo and parindx le indx_hi,ctb)
		  	if (cta gt 0 AND ctb gt 0) then begin
    			parinfo[linea].tied = 'P['+string(lineb,format='(I0)')+']/3.06122'    ; ratio tied to 1/3 (Osterbrock & Ferland Astrophysics of gas nebulae and AGN, 2nd edition, p 56).
    			if parinfo[linea].fixed EQ 1 or parinfo[lineb].fixed EQ 1 then begin
					parinfo[linea:linea+2].fixed =1  & parinfo[linea].value=set.minfluxconst
			    	parinfo[lineb:lineb+2].fixed =1  & parinfo[lineb].value=set.minfluxconst
					inda=where(linelabel eq 'NII6548') & indb=where(linelabel eq 'NII6583')
					r_indline[inda]= !values.f_nan & r_indline[indb]= !values.f_nan 
					b_indline[inda]= !values.f_nan & b_indline[indb]= !values.f_nan 
					side[inda] = '' & side[indb] = ''				
				endif
			endif
		ENDFOR

		; Put parinfo back into par_guess (can't use rep_tag_name. idl_bridge doesn't like it.)
		par_guess = rem_tag(par_guess,'parinfo_'+strtrim(i_guess,2))
		par_guess = add_tag(par_guess,parinfo,'parinfo_'+strtrim(i_guess,2))	
		
		; if external param is supplied then use it and return
		if keyword_set(param) NE 0 then begin
			; for those that are not fixed (not set.minfluxconst), overwrite with param provided
			goodline = where(parinfo.value NE set.minfluxconst,goodlinecnt)
			if goodlinecnt gt 1 then $
				par_guess.parinfo_1[goodline].value = param[goodline]
			return, par_guess
		endif
	ENDFOR		; set.n_guess loop 

	return, par_guess
END
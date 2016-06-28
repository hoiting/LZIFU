FUNCTION lzifu_fit_line,data,set,param = param,_extra=extra

	if n_elements(param) GT 0 then supply_param = 1 else supply_param = 0
	
	; remove param in data if exist to avoid contamination
	if supply_param eq 1 and tag_exist(data,'param') then data = rem_tag(data,'param')
	
	; Which lines to fit? Call linelist function
	linelist = call_function(set.linelist_func,/fit_line)

	; Create initial guess
	if supply_param eq 0 then $
		par_guess = lzifu_initpar(data,set,linelist,b_indline=b_indline,r_indline=r_indline) $ 
	else $
		par_guess = lzifu_initpar(data,set,linelist,b_indline=b_indline,r_indline=r_indline,param = param) 
	;;;;;;;;;restrain fit to only channels close to lines ;;;;;;;;;;;;;;;;
   fit_dlambda=set.fit_dlambda & linewave=linelist.wave 
   for i=0,n_elements(linewave)-1 do begin
		if finite(b_indline[i]) then begin
			ind=b_indline[i]
			b_tmp=where(data.b_lambda GT data.b_lambda[ind]-fit_dlambda/2 and data.b_lambda LT data.b_lambda[ind]+fit_dlambda/2 and data.b_mask EQ 1,b_cnt)
			if  exist(b_ind) and b_cnt GT 0 then b_ind = cmset_op(b_ind,'OR',b_tmp) 
			if ~exist(b_ind) and b_cnt GT 0 then b_ind = b_tmp
		endif
   		if finite(r_indline[i]) then begin
			ind=r_indline[i]
			r_tmp=where(data.r_lambda GT data.r_lambda[ind]-fit_dlambda/2 and data.r_lambda LT data.r_lambda[ind]+fit_dlambda/2 and data.r_mask EQ 1,r_cnt)
			if  exist(r_ind) and r_cnt GT 0 then r_ind = cmset_op(r_ind,'OR',r_tmp) 
			if ~exist(r_ind) and r_cnt GT 0 then r_ind = r_tmp			
		endif
   endfor

	; create a sigle line_lambda,line_flux,line_flux_err which contain only channels close to lines to be fitted.    
	if exist(r_ind) and exist(b_ind) then begin
		line_lambda   = [data.b_lambda[b_ind],data.r_lambda[r_ind]]
		line_flux     = [data.b_flux_nocnt[b_ind],data.r_flux_nocnt[r_ind]]
		line_flux_err = [data.b_flux_err[b_ind],data.r_flux_err[r_ind]]
		br_sep_point  = n_elements(b_ind)
	endif 
	if exist(r_ind) and not exist(b_ind) then begin
		line_lambda   = data.r_lambda[r_ind]
		line_flux     = data.r_flux_nocnt[r_ind]
		line_flux_err = data.r_flux_err[r_ind]
		br_sep_point  = 0
	endif 
	if not exist(r_ind) and exist(b_ind) then begin
		line_lambda   = data.b_lambda[b_ind]
		line_flux     = data.b_flux_nocnt[b_ind]
		line_flux_err = data.b_flux_err[b_ind]
		br_sep_point  = n_elements(b_ind)
	endif 
	if not exist(r_ind) and not exist(b_ind) then return,data
   ; Remove 0 error pixels, or mpfit crashes. 
   ind=where(line_flux_err LE 0 or ~ finite(line_flux),cnt) 
   if cnt gt 0 then line_flux_err[ind]=!values.f_nan 

   functargs = {set:set,br_sep_point:br_sep_point} ; arguments passed to lzifu_manygauss

   if n_elements(line_flux) lt (n_elements(linelist.wave)+ 3) * set.ncomp then $ ; if too few channels then skip fitting
   		return,data 

	; Fit emission line!
	if supply_param eq 0 then begin
		; loop through par_guess
		for iguess = 1,set.n_guess do begin
			void = execute('parinfo = par_guess.parinfo_' + strtrim(iguess,2) )
			t_param = Mpfitfun('lzifu_manygauss',line_lambda,line_flux,line_flux_err, $
        	    	  	        functargs = functargs, parinfo=parinfo,perror=t_perror, $
        		    	        maxiter=set.mpfit_maxiter,bestnorm=t_chisq, covar=t_covar,yfit=t_specfit,dof=t_dof, $
    	        	    	    niter=niter,status=t_status,$
	                	    	npegged=t_npegged,nfree=t_nfree,autoderivative = 0, $
	                	    	/nan,_extra=extra);,/quiet)
	        ; compare chisq. update results with min_chisq
	        ; pocket algorithm!
	        if iguess EQ 1 then begin 
	        	perror = t_perror
	        	param  = t_param
	        	chisq = t_chisq 
				covar = t_covar
	        	status = t_status
				specfit = t_specfit
				dof = t_dof	  
				npegged=t_npegged
				nfree=t_nfree      	
	        endif else begin
	        	if t_status GT 0 and t_chisq LT chisq then begin
;	        		; don't accept fit if v or vdisp touch boundaries; even when chi2 is smaller
					ppoff    = t_param[0]
					iz       = ppoff + indgen(set.ncomp)  * 2 
					iveldisp = iz + 1					
					dum = where(t_perror[iz] eq 0,cnt1) & dum = where(t_perror[iveldisp] eq 0,cnt2)
					if cnt1 gt 0 or cnt2 gt 0 then continue
		        	perror  = t_perror
		        	param   = t_param
	    	    	chisq   = t_chisq 
					covar   = t_covar
	        		status  = t_status
					specfit = t_specfit
					dof     = t_dof	  
					npegged = t_npegged
					nfree   = t_nfree      		        	
	        	endif
	        endelse
        endfor
    endif else begin	; if using smoothened values as initial guess
		param = Mpfitfun('lzifu_manygauss',line_lambda,line_flux,line_flux_err, $
       	    	  	        functargs = functargs, parinfo=par_guess.parinfo_1,perror=perror, $
    		    	        maxiter=500,bestnorm=chisq, covar=covar,yfit=specfit,dof=dof, $
   	        	    	    niter=niter,status=status,$
                	    	npegged=npegged,nfree=nfree,autoderivative = 0 ,$
                	    	/nan,_extra=extra);,/quiet)

    endelse

	if status GT 0 then begin   ; fit is success
		; if velocity or velocity dispersion touches boundaries (err = 0), then set status to -99
		ppoff    = param[0]
		iz       = ppoff + indgen(set.ncomp)  * 2 
		iveldisp = iz + 1
		dum = where(perror[iz] eq 0,cnt1) & dum = where(perror[iveldisp] eq 0,cnt2)
		if cnt1 gt 0 or cnt2 gt 0 then status = -99

		;Set vdisp to positive values. 
		param[iveldisp] = abs(param[iveldisp])


		dof=n_elements(where(finite(line_flux)))-nfree
		redchisq = chisq/dof

		diff_comp = lzifu_manygauss([data.b_lambda,data.r_lambda],param,set=set,/sep_comp)  ; remake different components

		data = join_struct(diff_comp,data)      ; put them in data structure. overwrite if components exist in data already (when smoothen refit)

		out = {param      :   param,$
	    	   perror     :   perror,$
	       	   covar      :   covar, $
	       	   red_chi2   :   redchisq,$
	       	   dof        :   dof , $
	       	   status     :   status}
	    ; merge fit results with data and do a single structure output
		out = join_struct(out,data) 	       	   
	endif else begin
		out = data
	endelse

	return,out
END
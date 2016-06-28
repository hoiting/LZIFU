FUNCTION lzifu_linelist_209807,fit_line=fit_line,mask_line = mask_line
; This is for 209807
; Label and wavelength lists
; http://www.mpa-garching.mpg.de/SDSS/DR7/SDSS_line.html
; http://www.pa.uky.edu/~peter/atomic/

;  Common lines:
;
;  labels = ['OII3726', 'OII3729', $
;            'NeIII3869', $
;            'Hepsilon', 'Hdelta', 'Hgamma', 'OIII4363', $
;            'Hbeta', 'OIII4959', 'OIII5007', $
;            'OI6300', 'NII6548', $
;            'Halpha', 'NII6583', 'SII6716', $
;            'SII6731' ]

;  waves = double([3726.032, 3728.815, $
;                  3869.060, $
;                  3970.072, 4101.734, 4340.464, 4363.210, $
;                  4861.325, 4958.911, 5006.843, $
;                  6300.304, 6548.040, $
;                  6562.800, 6583.460, 6716.440, $
;                  6730.810])

	if keyword_set(mask_line) then begin
	;;;;;;;;;;;;;;;;;;;;;; Modify this part ;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;; Lines to mask out when fitting the continuum ;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;;;;;;;;;!!!!! NO SPECIAL CHARACTERS FOR LINE LABELS !!!!!!!;;;;;;

	  labels = ['OII3726', 'OII3729', $
        	    'Hepsilon', 'Hdelta', 'Hgamma', $
            	'Hbeta', 'OIII4959', 'OIII5007', $
	            'OI6300', 'NII6548', $
    	        'Halpha', 'NII6583', 'SII6716', $
        	    'SII6731' ]

	  waves = double([3726.032, 3728.815, $
        	          3970.072, 4101.734, 4340.464, $
            	      4861.325, 4958.911, 5006.843, $
                	  6300.304, 6548.040, $
	                  6562.800, 6583.460, 6716.440, $
    	              6730.810])
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	endif

   if keyword_set(fit_line) then begin
	;;;;;;;;;;;;;;;;;;;;;; Modify this part ;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;; Lines to fit  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;;;;;;;;;!!!!! NO SPECIAL CHARACTERS FOR LINE LABELS !!!!!!!;;;;;;

	  labels = ['Hbeta', 'OIII4959', 'OIII5007', $
	  			'OI6300', $
	            'NII6548','Halpha', 'NII6583', $
	            'SII6716', 'SII6731' ]

	  waves = double([4861.325, 4958.911, 5006.843, $
	  				  6300.304, $
                	  6548.040, 6562.800, 6583.460, $
                	  6716.440, 6730.810])

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif

	if n_elements(labels) NE n_elements(waves) then begin
		message,'Numbers of lines in linelist do not match up!'
	endif
	linelist = { label:labels, wave:double(waves) }

	return,linelist
END

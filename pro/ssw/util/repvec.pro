
; 	(14-jul-92)
  function repvec,a,num_reps
;+
; NAME:
;	REPVEC
; PURPOSE:
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
;   POSITIONAL PARAMETERS:
;   KEYWORDS PARAMETERS:
; OUTPUTS:
;   POSITIONAL PARAMETERS:
;   KEYWORDS PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
; MODIFICATION HISTORY:
;       July, 1992. - Written by GLS, LMSC.
;-

a = makvec(a)
return, $
  reform(transpose(reform(rebin(a,n_elements(a)*num_reps,/sample), $
    num_reps,n_elements(a))),n_elements(a)*num_reps)

end

   

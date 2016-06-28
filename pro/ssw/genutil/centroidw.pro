;	(11-feb-91)
PRO CENTROIDW,ARRAY,XCEN,YCEN
;+
; NAME:
;	CENTROIDW
; PURPOSE:
;	Calculate the weighted average of ARRAY
; CATEGORY:
;	
; CALLING SEQUENCE:
;	CENTROID,ARRAY,XCEN,YCEN
; INPUTS:
;	ARRAY = Rectangular input array of any type except string
; OUTPUTS:
;	XCEN = weighted average of X values
;	YCEN = weighted average of Y values
; COMMON BLOCKS:
;	NONE.
; SIDE EFFECTS:
;	NONE.
; PROCEDURE:
;	
; MODIFICATION HISTORY:
; 	VERSION 1.0, Written J. R. Lemen, 11 Feb 1991
;-
;
;
ON_ERROR,2              ;Return to caller if an error occurs
S=SIZE(ARRAY)
if S(0) ne 2 then message, 'Array is not 2-dimensional.'

totarr = total(ARRAY) 		; Get the total value
YCEN   = total(ARRAY#findgen(n_elements(ARRAY(0,*)))) / totarr	
XCEN   = total(findgen(n_elements(ARRAY(*,0)))#ARRAY) / totarr	

return 
end 


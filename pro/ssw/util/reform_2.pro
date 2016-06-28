;+
; PROJECT:
;	SSW
; NAME:
;	REFORM_2
;
; PURPOSE:
;	This function uses reform to reformat the first input array to the same size
;	as the second input array.
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	Result = Reform_2( arr1, arr2 )
;
; CALLS:
;	none
;
; INPUTS:
;       Arr1
;		Arr2
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	arr1 and arr2 must have the same number of elements.
;
; PROCEDURE:
;	Uses the IDL reform function with /overwrite and size(/dim) to dimension ARR1 to the
;	same size as ARR2
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 21-feb-03
;
;-


function reform_2, arr1, arr2

return, reform( arr1, size(/dim, arr2)>1,/over)
end
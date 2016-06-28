function is_nonzero, arg

;+
; PROJECT:
;	SSW
; NAME:
;	IS_NONZERO
;
; PURPOSE:
;	This function returns zero if the argument is undefined or all zeroes.
;
; CATEGORY:
;	Util
;
; CALLING SEQUENCE:
;	test = is_nonzero( a )
;
; CALLS:
;	none
;
; INPUTS:
;       Arg - argument to test.
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
;	Argument may only be undefined or of numeric type.
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	20-dec-02, Version 1, richard.schwartz@gsfc.nasa.gov
;
;-

if not keyword_set( arg ) then return, 0

return, total(abs(arg)) gt 0
end

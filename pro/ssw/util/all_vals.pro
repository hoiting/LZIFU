;+
; NAME:
;       ALL_VALS
; PURPOSE:
;       Find and sort unique values in an array
; CATEGORY:
; CALLING SEQUENCE:
;       out = all_vals(in)
; INPUTS:
;	in	any array
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;	out	sorted array of unique values
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;       RDB     Sep-98  Written, modelled on old library routine
;
;-

function	all_vals,array

out = array(uniq(array,sort(array)))

return,out

end

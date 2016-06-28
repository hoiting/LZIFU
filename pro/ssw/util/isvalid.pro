;+
; NAME:
;	ISVALID
; PURPOSE:
;	Returns validity flag for its argument
; CALLING SEQUENCE:
;	result = isvalid(variable)
; INPUTS:
;	variable: the variable to be tested
; OPTIONAL INPUT PARAMETERS:
;	(none)
; KEYWORD PARAMETERS:
;	(none)
; RESTRICTIONS:
;	None I know of....
; MODIFICATION HISTORY:
;	Created by Craig DeForest, 4/13/1995
;-
function isvalid,a
return, ((size(a))((size(a))(0)+1) ne 0)
end

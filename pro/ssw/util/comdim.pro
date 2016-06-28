;+
;
; NAME:
;	COMDIM
;
; PURPOSE:
;	Collapse degenerate dimensions of an array.
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
;	Result = COMDIM(Array)
;
; INPUTS:
;       Array:	Array to be collapsed.
;
; OUTPUTS:
;       Result:	Reformed array.
;
; RESTRICTIONS:
;       Use Version 2 function Reform to make Version 1 code compatible.
;
; MODIFICATION HISTORY:
;       Mod. 05/06/96 by RCJ. Added formal documentation.
;-
;
function comdim,a
return,reform(a) 
end

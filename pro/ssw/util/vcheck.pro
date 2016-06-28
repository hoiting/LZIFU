;+
; Project     : SOHO - CDS     
;                   
; Name        : VCHECK()
;               
; Purpose     : Check if variable exists and return optional default if not.
;               
; Explanation : Two parameters can be supplied.  If the first is defined, its
;               value is returned.  If the first is not defined the function
;               returns the value of the second (if it is defined) or zero if
;               it is not.  If the first parameter is not defined and the 
;               second is not supplied, a zero value is returned.
;               
; Use         : IDL> a = vcheck(x,x_default)
;    
; Inputs      : x   -  variable to be checked
;               
; Opt. Inputs : x_default - the value to assign to function value if first
;                           parameter does not exist.
;               
; Outputs     : Function returns value as explained above.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Utilities
;               
; Prev. Hist. : From anonymous Yohkoh idea.
;
; Written     : C D Pike, RAL,  20-Apr-94
;               
; Modified    : 
;
; Version     : Version 1, 20-Apr-94
;-            

function vcheck, p1, p2

out = 0
if (n_elements(p2) ne 0) then out = p2
if (n_elements(p1) ne 0) then out = p1
return, out
end

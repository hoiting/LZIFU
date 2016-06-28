;+
; Project     : SOHO - CDS     
;                   
; Name        : NINT()
;               
; Purpose     : Returns the nearest integers to the input values.
;               
; Explanation : Returns the nearest integer (2 or 4 byte) to the input scalar
;               or array.  Note this function should be used instead of 
;               relying on the IDL FIX or LONG functions to convert a real
;               number. Eg fix(1.0/0.001) = 999 but nint(1.0/0.001) = 1000
;               
; Use         : IDL> n = nint(x)
;    
; Inputs      : x   array for which nearest integers are to be found.
;               
; Opt. Inputs : None
;               
; Outputs     : Function value  - the nearest integers.
;               
; Opt. Outputs: None
;               
; Keywords    : LONG	= If this keyword is set and non-zero, then the result
;			  of NINT is of type LONG.  Otherwise, the result is
;			  either of type INTEGER or LONG depending on the
;			  extent of the data.
;
; Calls       : None
;               
; Restrictions: The nearest integer of 2.5 is 3
;               the nearest integer of -2.5 is -3
;               
; Side effects: None
;               
; Category    : Util, Numerical
;               
; Prev. Hist. : Unknown
;
; Written     : Unknown
;               
; Modified    : To CDS format, C D Pike, RaL, 18-May-1993
;		Version 2, William Thompson, GSFC, 27 July 1993.
;			Added LONG keyword, taken from routine of same name
;			written by Wayne Landsman.
;		Version 3, William Thompson, GSFC, 17 February 1998
;			Use ROUND function
;		Version 4, William Thompson, GSFC, 19 February 1998
;			Allow string inputs
;
; Version     : Version 4, 19 February 1998
;-            

function nint,x,long=long

xmax = max(x,min=xmin)
xmax = abs(xmax) > abs(xmin)
if (xmax gt 32767) or keyword_set(long) then begin
    if datatype(x,1) eq 'String' then b = round(float(x)) else b = round(x)
end else begin
    if datatype(x,1) eq 'String' then b = fix(round(float(x))) else	$
	    b = fix(round(x))
endelse

return, b  

end

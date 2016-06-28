function dspline,x,y,t,sigma,interp=interp
;+
; NAME:
;	DSPLINE    (Deluxe SPLINE)
;
; PURPOSE:
;	Perform cubic spline interpolation or linear interpolation
;
; CATEGORY:
;	util, Interpolation - E1.
;
; CALLING SEQUENCE:
;	Result = DSPLINE(X, Y, T [, Sigma])		; Spline
;	Result = DSPLINE(X, Y, T [, Sigma],interp=0)	; Linear
;
; INPUTS:
;	X:	Abcissa vector.  The values need not monotonically increase.
;
;	Y:	The vector of ordinate values corresponding to X.
;
;	T:	The vector of abcissae values for which the ordinate is 
;		desired.  The values of T need not monotonically increase.
;
; OPTIONAL INPUT PARAMETERS:
;	Sigma:	The amount of "tension" that is applied to the curve.  The 
;		default value is 1.0.  If sigma is close to 0, (e.g., .01),
;		then effectively there is a cubic spline fit.  If sigma
;		is large, (e.g., greater than 10), then the fit will be like
;		a polynomial interpolation.
; OPTIONAL INPUT KEYWORDS:
;	interp	=0 For linear interpolation
;		=1 For spline interpolation (default)
;
; OUTPUTS:
;	DSPLINE returns a vector of interpolated ordinates.
;	Result(i) = value of function at T(i).
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Data must not be string or structure type.
;
; PROCEDURE:
;	Sorts T and abssica and then calls spline or interpol.
;
; EXAMPLE:
;	The commands below show a typical use of DSPLINE:
;
;		X = [2.,3.,4.]  	;X values of original function
;		Y = (X-3)^2     	;Make a quadratic
;		T = FINDGEN(20)/10.+2 	;Values for interpolated points.
;					;twenty values from 2 to 3.9.
;		Z = DSPLINE(X,Y,T) 	;Do the interpolation.
;
;
;
; MODIFICATION HISTORY:
;	26-Jan-93, J. R. Lemen LPARL, Written
;       28-oct-93, JRL, Force T to be a vector when calling sort
;-
;
on_error,2                      ;Return to caller if an error occurs
if n_params(0) lt 4 then sigma = 1.0 else sigma = sigma > .001	;in range?
n = n_elements(x) < n_elements(y)
;
if n le 1 then message, 'X and Y must be arrays.'

if n_elements(interp) eq 0 then interp = 1
;
if interp then begin		; Use SLINE interpolation

;  Set up the output array

   ss_T = sort([T])			; Sort the T values
   Z = (x(0) * 0. * y(0)) * T 		; Same size and type (mimic spline)
   ss_X = sort(x)			; X monotonically increasing
   Z(ss_T) = spline(X(ss_x),Y(ss_x),T(ss_T),sigma)
   return,Z

endif else begin		; Use INTERPOL interpolation

   return,temporary(interpol(y,x,T))

endelse

end

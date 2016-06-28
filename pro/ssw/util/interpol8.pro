FUNCTION INTERPOL8, V, X, U
;+
; NAME:
;	INTERPOL8
;
; PURPOSE:
;	Linearly interpolate vectors with a regular or irregular grid.
;
; CATEGORY:
;	E1 - Interpolation
;
; CALLING SEQUENCE:
;	Result = INTERPOL8(V, N) 	;For regular grids.
;
;	Result = INTERPOL8(V, X, U)	;For irregular grids.
;
; INPUTS:
;	V:	The input vector can be any type except string.
;
;	For regular grids:
;	N:	The number of points in the result when both input and
;		output grids are regular.  The output grid absicissa values
;		equal FLOAT(i)/N_ELEMENTS(V), for i = 0, n-1.
;
;	Irregular grids:
;	X:	The absicissae values for V.  This vector must have same # of
;		elements as V.  The values MUST be monotonically ascending 
;		or descending.
;
;	U:	The absicissae values for the result.  The result will have 
;		the same number of elements as U.  U does not need to be 
;		monotonic.
;	
; OPTIONAL INPUT PARAMETERS:
;	None.
; KEYWORDS:
;	CUBIC -uses cubic interpolation option in INTERPOLATE
;
; OUTPUTS:
;	INTERPOL returns a floating-point vector of N points determined
;	by linearly interpolating the input vector.
;
;	If the input vector is double or complex, the result is double 
;	or complex.
; CALLS:
;	FIND_IX, F_DIV
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Result(i) = V(x) + (x - FIX(x)) * (V(x+1) - V(x))
;
;	where 	x = i*(m-1)/(N-1) for regular grids.
;		m = # of elements in V, i=0 to N-1.
;
;	For irregular grids, x = U(i).
;		m = number of points of input vector.
;
; MODIFICATION HISTORY:
;	Based on INTERPOL but speeded up using FIND_IX and INTERPOLATE.
;	richard.schwartz@gsfc.nasa.gov, 7-sep-1997.
;-
;
	on_error,2              ;Return to caller if an error occurs
	if n_elements(cubic) eq 0 then cubic = 0
	m = N_elements(v)	;# of input pnts
	if N_params(0) eq 2 then begin	;Regular?
		r = findgen(x)*(m-1)/(x-1>1) ;Grid points in V
		rl = long(r)		;Cvt to integer
		return, interpolate( 1.0*v(*), rl + r-rl, cubic=cubic)
		endif
;
	if n_elements(x) ne m then $ 
		stop,'INTERPOL8 - V and X must have same # of elements'
	n= n_elements(u)	;# of output points

	if x(1) - x(0) ge 0 then s1 = 1 else s1=-1 ;Incr or Decr X
;
;Find indices in X neighboring U
;
	nix = (find_ix( x, u) < (m-2) )> (1-s1)/2

        return, interpolate(1.0*v(*), nix +s1* f_div( u(*) - x(nix),x(nix+s1)-x(nix)),cubic=cubic)

end

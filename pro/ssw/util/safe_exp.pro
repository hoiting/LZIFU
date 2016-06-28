	FUNCTION SAFE_EXP, X
;+
; Project     :	SOHO - CDS
;
; Name        :	SAFE_EXP()
;
; Purpose     :	Safe version of EXP() -- no floating underflows
;
; Category    :	Class4, Numerical
;
; Explanation :	Prior to IDL version 4, taking the exponential of a large
;		negative number, for example when calculating a Gaussian far
;		out from line center, would give a result of 0.  With the
;		advent of version 4, the same calculation would give floating
;		underflow error messages.
;
;		This routine allows one to calculate exponentials without
;		worrying about generating floating underflow errors.  Any
;		numbers smaller than -87 (which gives an exponential of
;		1.6E-38) return a result of 0.
;
; Syntax      :	Same as the EXP() function.
;
; Examples    :	Y = SAFE_EXP(-X^2)
;
; Inputs      :	X	= The value or array to take the exponential of.
;			  Complex numbers are also supported.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the exponential.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 13-Jun-1997, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	Y = 0*X
	W = WHERE(FLOAT(X) GT -87, COUNT)
	IF COUNT GT 0 THEN Y(W) = EXP(X(W))
;
	RETURN, Y
	END

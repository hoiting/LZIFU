	FUNCTION FIND_VALUE,XX,YY,VAL
;+
; Project     :	SOHO - CDS
;
; Name        :	FIND_VALUE()
;
; Purpose     :	Finds where an array is equal to a value.
;
; Category    :	Class4, Numerical
;
; Explanation :	This procedure finds the index of the point closest to the
;		specified value, and then performs a bilinear interpolation.
;
; Syntax      :	Result = FIND_VALUE( Y, VALUE )
;		Result = FIND_VALUE( X, Y, VALUE )
;
; Examples    :	X = 0.1*FINDGEN(100) + 2
;		Y = X^2
;		PRINT, FIND_VALUE(X, Y, 10)
;
; Inputs      :	Y     = The array to search for VALUE within.  Must be
;			monotonically increasing or decreasing.
;
;		VALUE = The value to search for.
;
; Opt. Inputs :	X     = An array of positions for the Y data values.  If not
;			passed, then the indices (0,1,2,...) are used instead.
;
; Outputs     :	The result of the function is the interpolated position.
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
; Prev. Hist. :	Taken from the routine FIND in the SERTS library.
;
; History     :	Version 1, 21-Aug-1996, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
;  Interpret the input parameters.  Force VALUE to be at least floating point.
;
	IF N_PARAMS() EQ 2 THEN BEGIN
		X = LINDGEN(N_ELEMENTS(XX))
		Y = XX
		VALUE = YY*1.
	END ELSE IF N_PARAMS() EQ 3 THEN BEGIN
		X = XX
		Y = YY
		VALUE = VAL*1.
	END ELSE MESSAGE, 'Syntax:  Result = FIND_VALUE( [X,]  Y, VALUE )'
;
;  Check the number of parameters of Y, and optionally X.
;
	N = N_ELEMENTS(Y)
	IF N_PARAMS() EQ 3 THEN IF N_ELEMENTS(X) NE N THEN MESSAGE,	$
		'X and Y must have the same number of elements'
;
;  If Y is single-valued, then return the default position.
;
	IF N LT 2 THEN RETURN, X(0)
;
;  Find the nearest position to where Y=VALUE.
;
	IF Y(N-1) GT Y(0) THEN I = MAX( WHERE( Y LE VALUE) ) ELSE	$
			       I = MAX( WHERE( Y GE VALUE) )
;
;  If not found, then return the first position.
;
	IF I EQ -1 THEN RETURN, X(0)
;
;  If at the extreme edge, then return the last position.
;
	IF I EQ N-1 THEN RETURN, X(N-1)
;
;  Otherwise, extrapolate the position.
;
	RETURN, X(I) + (X(I+1) - X(I)) * (VALUE - Y(I)) / (Y(I+1) - Y(I))
	END

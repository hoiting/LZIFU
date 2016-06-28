	FUNCTION BASE_INTERP, Y, X, X0, WEIGHTS=W, MINSIG=MINSIG, ORDER=ORDER
;+
; Project     :	SOHO - CDS
;
; Name        :	BASE_INTERP()
;
; Purpose     :	Interpolate to the base of a curve, ignoring outliers.
;
; Category    :	Class4, Interpolation
;
; Explanation :	Makes a polynomial (by default linear) fit to the data, and
;		removes any points which are far from the fit, before
;		performing the interpolation.
;
; Syntax      :	Result = BASE_INTERP(Y, X, X0)
;
; Examples    :	
;
; Inputs      :	Y  = Array of Y values to interpolate to.
;		X  = Array of positions corresponding to the Y array.
;		X0 = Array of new positions to interpolate the array to.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the interpolated array.
;
; Opt. Outputs:	None.
;
; Keywords    :	WEIGHTS	= Array of weights to use in fitting the data.  The
;			  default is to use equal weights for all points.
;		MINSIG	= The minimum value of sigma to use in rejecting
;			  points.  Points which are 2*SIGMA away from the
;			  fitted curve are ignored.
;		ORDER	= Polynomial order to fit to.  The default is 1.
;
; Calls       :	POLYFITW, INTERPOL
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 18-Jun-1996, William Thompson, GSFC
;		Version 2, 11-Dec-1997, William Thompson, GSFC
;			Don't perform fit unless there are enough points.
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
;  Check the input parameters.
;
	IF N_PARAMS() NE 3 THEN MESSAGE,	$
		'Syntax:  Result = BASE_INTERP(Y, X, X0)'
;
	IF N_ELEMENTS(Y) LE 1 THEN MESSAGE,	$
		'Parameters X and Y should be arrays'
;
	IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN MESSAGE,	$
		'Arrays X and Y should have the same number of elements'
;
	IF N_ELEMENTS(X0) EQ 0 THEN MESSAGE, 'Parameter X0 not defined'
;
;  Get the array of weights.
;
	IF N_ELEMENTS(WEIGHTS) EQ 0 THEN BEGIN
		W = REPLICATE(1, N_ELEMENTS(Y))
	END ELSE IF N_ELEMENTS(WEIGHTS) NE N_ELEMENTS(Y) THEN MESSAGE, $
		'WEIGHTS must have same number of elements as X, Y'
;
;  Get the polynomial order.
;
	IF N_ELEMENTS(ORDER) EQ 0 THEN ORDER = 1
;
;  Make sure that X is in ascending order, and that all the parameters are at
;  least integer.
;
	S = SORT(X)
	XX = X(S)*1
	YY = Y(S)*1
	WW = W(S)*1
	COUNT = N_ELEMENTS(XX)
;
;  Keep reiterating until the number of elements doesn't change.
;
REITERATE:
	IF COUNT LE (ORDER+1) THEN GOTO, FINISH
	PARAM = POLYFITW(XX, YY, WW, ORDER, YFIT, YBAND, SIGMA)
	IF N_ELEMENTS(MINSIG) EQ 1 THEN SIGMA = SIGMA > MINSIG
	IF SIGMA EQ 0 THEN GOTO, FINISH
	WB = WHERE(ABS(YY-YFIT) GE 2*SIGMA, COUNT)
	IF COUNT NE 0 THEN BEGIN
		WG = WHERE(ABS(YY-YFIT) LT 2*SIGMA, COUNT)
		IF COUNT EQ 0 THEN GOTO, FINISH
		XX = XX(WG)
		YY = YY(WG)
		WW = WW(WG)
		GOTO, REITERATE
	ENDIF
;
;  Interpolate the remaining points.
;
FINISH:
	RETURN, INTERPOL(YY,XX,X0)
	END

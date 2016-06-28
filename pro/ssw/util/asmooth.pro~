	FUNCTION ASMOOTH,ARRAY,WIDTH,MISSING=MISSING
;+
; Project     :	SOHO - CDS
;
; Name        :	ASMOOTH()
;
; Purpose     :	Smooths a one or two-dimensional array.
;
; Category    :	Image-processing, SU:SERTSIM, Class3
;
; Explanation :	Does the same thing as the IDL built-in SMOOTH function, except
;		that:
;
;		1.  The effect tapers off at the edges of the array, instead
;		    of abruptly stopping as in SMOOTH.
;
;		2.  Missing pixels are handled.
;
; Syntax      :	Result = ASMOOTH( ARRAY, WIDTH )
;
; Examples    :	
;
; Inputs      :	ARRAY	= One or two-dimensional array to be smoothed.
;		WIDTH	= Width of the smoothing box.  If an even number, then
;			  WIDTH+1 is used.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the smoothed array.
;
; Opt. Outputs:	None.
;
; Keywords    :	MISSING	= The value representing missing pixels.
;
; Calls       :	GET_IM_KEYWORD, IS_NOT_MISSING, FLAG_MISSING
;
; Common      :	None.
;
; Restrictions:	ARRAY must be one or two-dimensional.
;
; Side effects:	None.
;
; Prev. Hist. :	Originally written for the SERTS project, February 1993.
;
; History     :	Version 1, 14-Aug-1998, William Thompson, GSFC
;		Version 2, 29-Oct-1998, William Thompson, GSFC
;			Fixed bug at edges of array when MISSING is not used.
;		Version 3, 02-Dec-1998, William Thompson, GSFC
;			Fixed bug when WIDTH is even, and MISSING not passed.
;		Version 4, 24-Dec-2002, William Thompson, GSFC
;			Sped up by using built-in SMOOTH function.
;               Version 5, 11-May-2005, William Thompson, GSFC
;                       Handle NaN values
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  Result = ASMOOTH(ARRAY,WIDTH)'
;
;  Check the size of the array.
;
	SZ = SIZE(ARRAY)
	IF SZ[0] EQ 0 THEN MESSAGE,'ARRAY not defined'
	IF SZ[0] GT 2 THEN MESSAGE,'ARRAY must be one- or two-dimensional'
	NX = SZ[1]
	IF SZ[0] EQ 2 THEN NY = SZ[2] ELSE NY = 1
;
;  Get the size of the border to add onto the array.
;
	IF N_ELEMENTS(WIDTH) NE 1 THEN MESSAGE,		$
		'WIDTH must be a scalar'
	WIDTHX = WIDTH
	IF SZ[0] EQ 2 THEN WIDTHY = WIDTH ELSE WIDTHY = 1
	WX = FIX(WIDTHX/2)
	WY = FIX(WIDTHY/2)
;
;  Get the value of the missing keyword.
;
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
;  Form the larger array to apply the smoothing function to.
;
	A = FLTARR(NX+2*WX, NY+2*WY)
	N = A
	AA = ARRAY
        MASK = IS_NOT_MISSING(ARRAY, MISSING=MISSING)
        W = WHERE(MASK EQ 0, COUNT)
        IF COUNT GT 0 THEN AA[W] = 0
;
;  Insert the data array and mask into the larger arrays, and smooth them.
;
	A[WX,WY] = AA
	N[WX,WY] = MASK
	A = SMOOTH(A,WIDTH)
	N = SMOOTH(N,WIDTH)
;
;  Correct for the total number of pixels actually smoothed.
;
	W = WHERE((N NE 0) AND (N NE 1), COUNT)
	IF COUNT GT 0 THEN A[W] = A[W] / N[W]
;
;  Make sure that missing pixels are properly set, and extract the part
;  corresponding to the original array.
;
	W = WHERE(N EQ 0, COUNT)
	IF (COUNT GT 0) AND (N_ELEMENTS(MISSING) EQ 1) THEN $
          FLAG_MISSING, A, W, MISSING=MISSING
	IF SZ[0] EQ 1 THEN A = A[WX:NX+WX-1] ELSE A = A[WX:NX+WX-1,WY:NY+WY-1]
;
	RETURN, A
	END

	PRO FILL_MISSING, ARRAY, MISSING, DIMENSION, EXTRAPOLATE=EXTRAPOLATE
;+
; Project     :	SOHO - CDS
;
; Name        :	FILL_MISSING
;
; Purpose     :	Fill in missing pixels in a data array
;
; Category    :	Class3, Analysis, Interpolation
;
; Explanation :	Uses bilinear interpolation to fill in missing pixels in a data
;		array
;
; Syntax      :	FILL_MISSING, ARRAY, MISSING  [, DIMENSION ]
;
; Examples    :	
;
; Inputs      :	ARRAY	= Array containing missing pixels to fill in.
;		MISSING = Value flagging missing pixels.
;
; Opt. Inputs :	DIMENSION = When ARRAY is multi-dimensional, then the dimension
;			  to use
;
; Outputs     :	ARRAY	= The input array is modified to fill in missing pixels
;			  with interpolated values.
;
; Opt. Outputs:	None.
;
; Keywords    :	EXTRAPOLATE = If set, the extrapolation is used at the ends of
;			      the array.  Otherwise, the nearest good value is
;			      extended to the end of the array.
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
; History     :	Version 1, 26-Mar-1996, William Thompson, GSFC
;		Version 2, 02-Apr-1996, William Thompson, GSFC
;			Corrected bug when several pixels are missing at end of
;			array.
;		Version 3, 25-Apr-1996, William Thompson, GSFC
;			Corrected bug when array contains only one good pixel.
;		Version 4, 07-Jun-1996, William Thompson, GSFC
;			Fix bug where interpolation goes to missing value.
;		Version 5, 08-Aug-1997, William Thompson, GSFC
;			Change so that ends are extended rather than
;			extrapolated by default.  Added /EXTRAPOLATE keyword.
;               Version 6, 11-May-2005, William Thompson, GSFC
;                       Handle NaN values
;
; Contact     :	WTHOMPSON
;-
;
;
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 2 THEN MESSAGE,	$
		'Syntax:  FILL_MISSING, ARRAY, MISSING  [, DIMENSION ]'
;
;  Check the size of the input array.
;
	IF N_ELEMENTS(ARRAY) LE 1 THEN MESSAGE, 'ARRAY must be an array'
	SZ = SIZE(ARRAY)
;
;  If the array contains more than one dimension, then fill in the specified
;  dimension.
;
	IF SZ(0) GT 1 THEN BEGIN
	    IF N_PARAMS() NE 3 THEN MESSAGE,	$
		    'DIMENSION must be passed when ARRAY is multi-dimensional'
	    IF DIMENSION NE LONG(DIMENSION) THEN MESSAGE,	$
		    'DIMENSION must be an integer'
	    IF (DIMENSION LT 1) OR (DIMENSION GT SZ(0)) THEN MESSAGE,	$
		    'DIMENSION must be between 1 and ' + TRIM(SZ(0))
	    IF SZ(DIMENSION) EQ 1 THEN MESSAGE, 'Dimension ' +	$
		    TRIM(DIMENSION) + ' is only one value deep'
;
;  Rearrange the dimensions of the array to put the specified dimension as the
;  middle one of three.
;
	    IF DIMENSION EQ 1 THEN N1 = 1 ELSE N1 = PRODUCT(SZ(1:DIMENSION-1))
	    N2 = SZ(DIMENSION)
	    IF DIMENSION EQ SZ(0) THEN N3 = 1 ELSE	$
		    N3 = PRODUCT(SZ(DIMENSION+1:SZ(0)))
	    ARRAY = REFORM(ARRAY, N1, N2, N3, /OVERWRITE)
;
;  Reiteratively fill in each pixel over the specified dimension.
;
	    FOR J=0,N3-1 DO FOR I=0,N1-1 DO BEGIN
		AA = REFORM(ARRAY(I,*,J))
		FILL_MISSING, AA, MISSING
		ARRAY(I,*,J) = AA
	    ENDFOR
;
;  Reformat the array back into it's original dimensions and return.
;
	    ARRAY = REFORM(ARRAY, SZ(1:SZ(0)), /OVERWRITE)
	    RETURN
	ENDIF
;
;  Keep reiterating until all the pixels are filled in.  Determine how many
;  pixels are missing.
;
	REPEAT BEGIN
	    W_MISSING = WHERE_MISSING(ARRAY, MISSING=MISSING, COUNT, $
                                     COMPLEMENT=W_GOOD, NCOMPLEMENT=COUNT2)
	    IF (COUNT EQ 0) OR (COUNT EQ N_ELEMENTS(ARRAY)) THEN RETURN
;
;  Find the good pixels.  If only one good pixel is found, then replace the
;  entire array with that value.
;
	    IF COUNT2 EQ 1 THEN BEGIN
		    ARRAY(*) = ARRAY(W_GOOD(0))
;
;  Otherwise, select out the first missing pixel, and find the points to use in
;  the interpolation.
;
	    END ELSE BEGIN
		W = W_MISSING(0)
		IF W EQ 0 THEN BEGIN
		    W1 = W_GOOD(0)
		    IF KEYWORD_SET(EXTRAPOLATE) THEN W2 = W_GOOD(1) ELSE $
			    W2 = W_GOOD(0)
		    I1 = 0
		    I2 = W1-1
		END ELSE IF W GT W_GOOD(COUNT2-1) THEN BEGIN
		    IF KEYWORD_SET(EXTRAPOLATE) THEN W1 = W_GOOD(COUNT2-2) $
			    ELSE W1 = W_GOOD(COUNT2-1)
		    W2 = W_GOOD(COUNT2-1)
		    I1 = W2+1
		    I2 = N_ELEMENTS(ARRAY) - 1
		END ELSE BEGIN
		    W1 = MAX(W_GOOD(WHERE(W_GOOD LT W)))
		    W2 = MIN(W_GOOD(WHERE(W_GOOD GT W)))
		    I1 = W1 + 1
		    I2 = W2 - 1
		ENDELSE
;
;  Perform the interpolation.
;
		X = LINDGEN(I2-I1+1) + I1
		IF W1 EQ W2 THEN ARRAY(X) = ARRAY(W1) ELSE ARRAY(X) =	$
			(ARRAY(W2)*(X-W1) - ARRAY(W1)*(X-W2)) / FLOAT(W2-W1)
;
;  Make sure that the interpolation doesn't set something to the missing pixel
;  value.  If it does, then use the minimum of the two values used for the
;  interpolation.
;
		WW = WHERE_MISSING(ARRAY(X), MISSING=MISSING, COUNT_WW)
		IF COUNT_WW GT 0 THEN ARRAY(X(WW)) = ARRAY(W1) < ARRAY(W2)
	    ENDELSE
	ENDREP UNTIL COUNT EQ 0
;
	END

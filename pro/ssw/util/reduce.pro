	FUNCTION REDUCE, ARRAY, I_REDUCE, J_REDUCE, AVERAGE=K_AVERAGE, $
                         TOTAL=K_TOTAL, MISSING=MISSING
;+
; Project     :	SOHO - CDS
;
; Name        :	REDUCE()
;
; Purpose     :	Reduce an array by box averaging to a more useful size.
;
; Category    :	
;
; Explanation :	Uses the REBIN function to reduce the size of the array by an
;		integer amount.  Allows one to reduce the array, even if the
;		reduction amount does not evenly divide into the array size.
;		Optionally, the user can choose to let the computer pick the
;		reduction amount.
;
; Syntax      :	A_NEW = REDUCE( ARRAY  [, I_REDUCE  [, J_REDUCE ]] )
;
; Examples    :	
;
; Inputs      :	ARRAY = Array to be reduced.  Can be one- or two-dimensional.
;
; Opt. Inputs :	I_REDUCE = Size of box in the first dimension to average over.
;			   If not passed, then the procedure selects what it
;			   thinks is a suitable value.
;
;		J_REDUCE = Size of box in the second dimension.  If not passed,
;			   then it has the same value as I_REDUCE.
;
; Outputs     :	The output of the function is the reduced array.
;
; Opt. Outputs:	None.
;
; Keywords    :	AVERAGE	= If set, then the pixels are averaged together.  The
;			  default is to simply subsample the image.
;
;               TOTAL   = If set, then the pixels are summed together.  This is
;                         equivalent to using /AVERAGE and multiplying by the
;                         degree of reduction.
;
;		MISSING = When used in conjunction with /AVERAGE, sets the
;			  value specifying missing pixels.  Pixels set to this
;			  value are not included in the average.  (The AVERAGE
;			  function is used instead of REBIN.)
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	
;	William Thompson	Applied Research Corporation
;	May, 1987		8201 Corporate Drive
;				Landover, MD  20785
;
; History     :	Version 1, 14 June 1996, William Thompson, GSFC
;			Incorporated into CDS library
;			Use LONG instead of FIX
;		Version 2, 17 December 1997, William Thompson, GSFC
;			Added keyword AVERAGE.
;		Version 3, 24-Jul-1998, William Thompson, GSFC
;			Added keyword MISSING
;               Version 4, 28-Jul-2004, William Thompson, GSFC
;                       Added keyword TOTAL
;               Version 5, 11-May-2005, William Thompson, GSFC
;                       Handle NaN values
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
	S = SIZE(ARRAY)
;
;  Check the number of dimensions of ARRAY.
;
	N_DIM = S(0)
	IF N_DIM EQ 1 THEN BEGIN
		NX = S(1)
		NY = NX
	END ELSE IF N_DIM EQ 2 THEN BEGIN
		NX = S(1)
		NY = S(2)
	END ELSE MESSAGE, 'ARRAY must have one or two dimensions'
;
;  If only two parameters were passed, then reduce ARRAY by the same amount in 
;  the two dimensions.  If ARRAY only has one dimension, then JJ is ignored.
;
	IF N_PARAMS(0) EQ 2 THEN BEGIN
		IF I_REDUCE LT 2 THEN MESSAGE, 'I_REDUCE must be GE 2'
		II = LONG(I_REDUCE)
		JJ = II
;
;  If all three parameters were passed, then reduce ARRAY by different amounts 
;  in the two dimensions.  If ARRAY only has one dimension, then JJ is ignored.
;
	END ELSE IF N_PARAMS(0) EQ 3 THEN BEGIN
		IF (I_REDUCE > J_REDUCE) LT 2 THEN BEGIN
			IF J_REDUCE GT I_REDUCE THEN BEGIN
				MESSAGE, 'J_REDUCE must be GE 2'
			END ELSE BEGIN
				MESSAGE, 'I_REDUCE must be GE 2'
			ENDELSE
		ENDIF
		II = LONG(I_REDUCE) > 1
		JJ = LONG(J_REDUCE) > 1
;
;  If only ARRAY was passed, then calculate an optimum reduction factor.  Don't
;  reduce the array if one dimension is less than four.
;
	END ELSE BEGIN
		N_MAX = NX > NY
		N_MIN = NX < NY
		IF N_MIN LT 4 THEN MESSAGE, 'ARRAY is too small to reduce'
;
;  First try reducing by either the square root of the smallest dimension or
;  the largest dimension over sixty, whichever is smaller.  In the latter case,
;  this will try to make the resulting size of the larger dimension to be on
;  the order of sixty pixels.
;
		I = LONG(SQRT(N_MIN) < (N_MAX/60)) > 2
		II = I
		JJ = II
;
;  Keep increasing the reduction factor by one until either the square root of 
;  the larger dimension or half the smaller dimension is reached.  With each 
;  reduction factor, find the number of elements that would be not be included 
;  in the reduction.  Use the reduction factor with smallest number of
;  remaining elements.  The remainder can never be greater than the total
;  number of elements. 
;
		BEST = N_ELEMENTS(ARRAY)
		WHILE ((I LE SQRT(N_MAX)) AND (I LT (N_MIN/2))) DO BEGIN
;
;  Calculate the number of elements remaining.
;
			N = LONG(N_MAX/I)
			REMAIN = N_MAX - N*I
			IF N_DIM EQ 2 THEN BEGIN
				N = LONG(N_MIN/I)
				R2 = N_MIN - N*I
				REMAIN = REMAIN*(N_MIN - R2) + N_MAX*R2
			ENDIF
;
;  If the number of elements remaining is smaller than the best value found so 
;  far, then set II and JJ to the current reduction factor.
;
			IF REMAIN LT BEST THEN BEGIN
				BEST = REMAIN
				II = I
				JJ = II
			ENDIF
;
;  If no elements remain, then stop looking.  Otherwise increase I by one and 
;  loop.
;
			IF BEST EQ 0 THEN GOTO,FOUND_BEST
			I = I + 1
		ENDWHILE
	ENDELSE
;
;  Reduce the array.
;
FOUND_BEST:
	MX = LONG(NX/II)
	MY = LONG(NY/JJ)
	IF KEYWORD_SET(K_AVERAGE) OR KEYWORD_SET(K_TOTAL) THEN SAMPLE = 0 $
                                                          ELSE SAMPLE = 1
	IF N_DIM EQ 1 THEN BEGIN
	    A = ARRAY(0:II*MX-1)
            WMISSING = WHERE_MISSING(A, N_MISSING, MISSING=MISSING)
	    IF KEYWORD_SET(K_AVERAGE) AND (DATATYPE(A,2) LT 4) THEN	$
		    A = FLOAT(A)
	    IF KEYWORD_SET(K_AVERAGE) AND (N_MISSING GT 0) THEN BEGIN
		A = REFORM(A, II, MX, /OVERWRITE)
		A = AVERAGE(TEMPORARY(A),1,MISSING=MISSING)
	    END ELSE A = REBIN(A, MX, SAMPLE=SAMPLE)
	END ELSE BEGIN
	    A = ARRAY(0:II*MX-1,0:JJ*MY-1)
            WMISSING = WHERE_MISSING(A, N_MISSING, MISSING=MISSING)
	    IF KEYWORD_SET(K_AVERAGE) AND (DATATYPE(A,2) LT 4) THEN	$
		    A = FLOAT(A)
	    IF KEYWORD_SET(K_AVERAGE) AND (N_MISSING GT 0) THEN BEGIN
		A = REFORM(A, II, MX, JJ, MY, /OVERWRITE)
		A = AVERAGE(TEMPORARY(A),1,MISSING=MISSING)
		A = AVERAGE(TEMPORARY(A),2,MISSING=MISSING)
	    END ELSE A = REBIN(A, MX, MY, SAMPLE=SAMPLE)
        ENDELSE
;
        IF KEYWORD_SET(K_TOTAL) THEN BEGIN
            IF N_DIM EQ 1 THEN A = II*A ELSE A = (II*JJ)*A
        ENDIF
;
	RETURN,A
	END

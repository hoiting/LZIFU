	FUNCTION SIG_ARRAY,ARRAY,DIMENSION,N_PAR=N_PAR,MISSING=MISSING
;+
; Project     :	SOHO - CDS
;
; Name        :	SIG_ARRAY
;
; Purpose     :	Returns the standard deviation of an array.
;
; Category    :	Class3, Numerical, Error-analysis, Statistics
;
; Explanation :	Calculate the standard deviation value of an array, or over one
;		dimension of an array as a function of all the other
;		dimensions.
;
; Syntax      :	Result = SIG_ARRAY( ARRAY  [, DIMENSION] )
;
; Examples    :	
;
; Inputs      :	ARRAY	  = The array to determine the standard deviation from.
;
; Opt. Inputs :	DIMENSION = The dimension to calculate the standard deviation
;			    over.
;
; Outputs     :	The result of the function is the standard deviation value of
;		the array when called with one parameter. 
;
;		If DIMENSION is passed, then the result is an array with all
;		the dimensions of the input array except for the dimension
;		specified, each element of which is the standard deviation of
;		the corresponding vector in the input array.
;
;		For example, if A is an array with dimensions of (3,4,5), then
;		the command:
;
;			B = SIG_ARRAY(A,2)
;
;		is equivalent to
;
;			B = FLTARR(3,5)
;			FOR J = 0,4 DO BEGIN
;				FOR I = 0,2 DO BEGIN
;				B(I,J) = SIG_ARRAY(A(I,*,J), N)
;				ENDFOR
;			ENDFOR
;
; Opt. Outputs:	None.
;
; Keywords    :	MISSING	= Value signifying missing pixels.  Any pixels with
;			  this value are not included in the calculation.  If
;			  there are no non-missing pixels, then MISSING is
;			  returned.
;
;		N_PAR	= The number of fitted parameters to take into account
;			  when determining the standard deviation.  The default
;			  value is one.  The number of degrees of freedom is
;			  N_ELEMENTS(ARRAY) - N_PAR.  The value of SIG_ARRAY
;			  varies as one over the square root of the number of
;			  degrees of freedom.
;
; Calls       :	AVERAGE
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Based on an earlier routine called SIGMA by W. Thompson, 1986.
;
; History     :	Version 1, 26-Mar-1996, William Thompson, GSFC
;		Version 2, 26-Feb-1997, William Thompson, GSFC
;			Corrected problem with roundoff error when the
;			distribution width is small compared to the data.
;		Version 3, 25-Feb-1997, William Thompson, GSFC
;			Make sure that one doesn't try to take square root of a
;			negative number due to roundoff error.
;		Version 4, 11-Apr-1998, William Thompson, GSFC
;			Corrected bug involving incorrect application of NPAR
;			adjustment.
;		Version 5, 25-Sep-1998, William Thompson, GSFC
;			Improved way that round-off error is handled when the
;			DIMENSION parameter is used.  Rather than normalizing
;			to a single average over the array, a separate average
;			is calculated for each pixel of the reduced array.
;               Version 6, 20-Sep-2005, William Thompson, GSFC
;                       Fixed bug with calculation for integer arrays
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2                      ;Return to caller if an error occurs
;
;  Check the number of parameters passed.
;
	IF N_PARAMS() EQ 0 THEN MESSAGE,	$
		'Syntax:  Result = SIG_ARRAY( ARRAY  [, DIMENSION ] )
;
;  Get the number of dimensions of the array.
;
	S = SIZE(ARRAY)
	IF S(0) EQ 0 THEN MESSAGE, 'Variable ARRAY must be an array'
;
;  If the DIMENSION parameter was passed, then check it for validity.
;  over that dimension.
;
	IF N_PARAMS() EQ 2 THEN BEGIN
		IF ((DIMENSION LT 1) OR (DIMENSION GT S(0))) THEN MESSAGE, $
			'DIMENSION out of range'
	ENDIF
;
;  Renormalize the data to the average value.  This avoids problems with
;  roundoff error.
;
	IF (N_PARAMS() EQ 2) AND (S(0) GT 1) THEN BEGIN
	    STEMP = LONARR(3)
	    IF DIMENSION EQ 1 THEN STEMP(0) = 1 ELSE	$
		STEMP(0) = PRODUCT(S(1:DIMENSION-1))
	    STEMP(1) = S(DIMENSION)
	    IF DIMENSION EQ S(0) THEN STEMP(2) = 1 ELSE	$
		STEMP(2) = PRODUCT(S(DIMENSION+1:S(0)))
	    TEMP = REFORM(ARRAY, STEMP)
            DT = DATATYPE(TEMP,2)
            IF (DT LE 2) OR (DT EQ 12) THEN TEMP = FLOAT(TEMP)
            IF (DT GE 13) THEN TEMP = DOUBLE(TEMP)
	    A0 = AVERAGE(ARRAY, DIMENSION, MISSING=MISSING)
	    FOR I = 0,S(DIMENSION)-1 DO TEMP(*,I,*) = TEMP(*,I,*) - A0
	    TEMP = REFORM(TEMP, S(1:S(0)), /OVERWRITE)
	END ELSE BEGIN
	    A0 = AVERAGE(ARRAY, MISSING=MISSING)
	    TEMP = ARRAY - A0
	ENDELSE
;
;  Change the missing value to reflect the renormalized data.
;
	IF N_ELEMENTS(MISSING) EQ 1 THEN BEGIN
	    W = WHERE(ARRAY NE MISSING, COUNT)
	    IF COUNT GT 0 THEN BEGIN
		TMISSING = MIN(ARRAY(W))
		IF TMISSING LT 0 THEN TMISSING = 1.1*TMISSING
		IF TMISSING GT 0 THEN TMISSING = 0.9*TMISSING
		IF TMISSING EQ 0 THEN TMISSING = -1
		W = WHERE(ARRAY EQ MISSING, COUNT)
		IF COUNT GT 0 THEN TEMP(W) = TMISSING
	    END ELSE TMISSING = TEMP(0)		;All pixels are missing
	ENDIF
;
;  Form the square of the array, taking into account any missing pixels.
;
	A_SQR = TEMP^2
	IF N_ELEMENTS(TMISSING) EQ 1 THEN BEGIN
		W = WHERE(TEMP EQ TMISSING, COUNT)
		IF COUNT GT 0 THEN A_SQR(W) = TMISSING
	ENDIF
;
;  Calculate the average of the array and of the square of the array.
;
	IF N_PARAMS() EQ 2 THEN BEGIN
		A_AVG = AVERAGE(TEMP, DIMENSION, MISSING=TMISSING)
		A_SQR = AVERAGE(A_SQR, DIMENSION, MISSING=TMISSING)
		N = S(DIMENSION)
	END ELSE BEGIN
		A_AVG = 0
		A_SQR = AVERAGE(A_SQR, MISSING=TMISSING)
		N = N_ELEMENTS(TEMP)
	ENDELSE
;
;  Take into account the number of free parameters.
;
	IF N_ELEMENTS(N_PAR) EQ 1 THEN NPAR = N_PAR ELSE NPAR = 1
	SIG = SQRT(ABS(A_SQR - A_AVG^2) * (N / ((N - NPAR) > 1.)))
;
;  Set any missing pixels to the missing pixel flag value.
;
	IF N_ELEMENTS(TMISSING) EQ 1 THEN BEGIN
		W = WHERE(A_AVG EQ TMISSING, COUNT)
		IF COUNT GT 0 THEN SIG(W) = MISSING
	ENDIF
;
	RETURN, SIG
	END

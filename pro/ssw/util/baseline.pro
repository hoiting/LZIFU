	FUNCTION BASELINE, ARRAY, A_SIG, MISSING=MISSING
;+
; Project     :	SOHO - CDS
;
; Name        :	BASELINE()
;
; Purpose     :	Returns baseline value of the input array.
;
; Category    :	Class3, Analysis
;
; Explanation :	This function estimates the baseline value of the input array.
;		This is determined by rejecting all points more than two sigma
;		above the average value.  A reiteration is performed until no
;		more points are rejected.
;
;		Two assumptions are made about the data in deriving the
;		baseline:
;
;			1.  That any signal is above the baseline,
;			    i.e. positive.
;
;			2.  That some subset of points in the input array have
;			    no signal, and fluctuate around the average
;			    baseline value.
;
;		Examples of the use of this routine include removing readout
;		bias levels from CCDs, and removing film fog levels from
;		microdensitometered data.
;
; Syntax      :	Result = BASELINE( ARRAY  [, A_SIG ])
;
; Examples    :	ARRAY = ARRAY - BASELINE(ARRAY)
;
; Inputs      :	ARRAY = An input array of values.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the baseline value.  This is a
;		single scalar value.  This routine cannot be used for data
;		with a varying (e.g. linear) baseline.
;
; Opt. Outputs:	A_SIG	= The standard deviation of the points used to
;			  calculate the baseline value.
;
; Keywords    :	MISSING	= Value flagging missing pixels.  These points are not
;			  used to calculate the baseline.  If all the points
;			  have this value, then it is returned as the value of
;			  the function.
;
; Calls       :	AVERAGE, STDEV
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Originally written for the SERTS project.
;
; History     :	Version 1, 22-Jan-1996, William Thompson, GSFC.
;			Incorporated into CDS library
;			Added MISSING keyword.
;		Version 2, 18-Feb-1996, William Thompson, GSFC
;			Fixed bug with A_SIG when all values are missing.
;		Version 3, 05-Apr-1996, William Thompson, GSFC
;			Fixed bug with A_SIG when there is only one valid
;			pixel.
;               Version 4, 11-May-2005, William Thompson, GSFC
;                       Handle NaN values
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
;  Extract only the non-missing pixels.
;
        W = WHERE_NOT_MISSING(ARRAY, MISSING=MISSING, COUNT)
        IF COUNT EQ 0 THEN BEGIN
            A_SIG = ARRAY[0]
            RETURN, ARRAY[0]
        ENDIF
        A = ARRAY(W)
;
;  Keep iterating until convergence is achieved.
;
	N_LAST = 0
	WHILE (N_ELEMENTS(A) NE N_LAST) DO BEGIN
		N_LAST = N_ELEMENTS(A)
		A_AVG = AVERAGE(A)
		IF N_ELEMENTS(A) GT 1 THEN A_SIG = STDEV(A) ELSE A_SIG = 0.
		A = A( WHERE( A LE A_AVG + 2*A_SIG ))
	ENDWHILE
;
	RETURN, A_AVG
	END

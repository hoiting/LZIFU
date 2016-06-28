	FUNCTION WHERE_NEGZERO, ARRAY, COUNT, QUIET=QUIET
;+
; Project     :	SOHO - CDS
;
; Name        :	WHERE_NEGZERO()
;
; Purpose     :	Finds positions of IEEE -0.0 values.
;
; Category    :	Class4, OS
;
; Explanation :	Finds the positions of all values within an array that
;		correspond to the IEEE value -0.0, as determined from the bit
;		pattern.  The VMS operating system has trouble coping with
;		these values.  If using any other operating system, then no
;		action is performed.
;
; Syntax      :	Result = WHERE_NEGZERO( ARRAY [, COUNT ] )
;
; Examples    :	
;
; Inputs      :	ARRAY	= Array to test against the IEEE -0.0 value.  Must be
;			  of either floating point or double-precision.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the indices of all values of
;		ARRAY corresponding to the IEEE -0.0 value, similar to the IDL
;		WHERE function.
;
; Opt. Outputs:	COUNT	= Number of values found corresponding to IEEE -0.0.
;
; Keywords    :	QUIET	= If set, then warning messages are not printed out.
;
; Calls       :	OS_FAMILY()
;
; Common      :	None.
;
; Restrictions:	ARRAY must be of type float or double-precision.
;
; Side effects:	If no -0.0 values are found, or if ARRAY is not of type float,
;		or double precision, or if the operating system is something
;		other than VMS, then -1 is returned, and COUNT is set to 0.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 31-Jan-1997, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 1 THEN MESSAGE,	$
		'Syntax:  Result = WHERE_NEGZERO(ARRAY [,COUNT])'
;
;  Set the default values for RESULT and COUNT.  If not using the VMS operating
;  system, then return immediately.
;
	RESULT = -1
	COUNT  = 0
	IF OS_FAMILY() NE 'vms' THEN RETURN, RESULT
;
;  Parse the input array based on the datatype.
;
	SZ = SIZE(ARRAY)
	CASE SZ(SZ(0)+1) OF
;
;  Single precision floating point.
;
	    4:  BEGIN
		LARRAY = LONG(ARRAY,0,N_ELEMENTS(ARRAY))
		BYTEORDER,LARRAY,/NTOHL
		RESULT = WHERE(LARRAY EQ '80000000'XL, COUNT)
		END
;
;  Double precision floating point.
;
	    5:  BEGIN
		LARRAY = LONG(ARRAY,0,2,N_ELEMENTS(ARRAY))
		BYTEORDER,LARRAY,/NTOHL
		RESULT = WHERE((LARRAY(0,*) EQ '80000000'XL) AND	$
			(LARRAY(1,*) EQ 0), COUNT)
		END
	    ELSE:  BEGIN
		IF NOT KEYWORD_SET(QUIET) THEN MESSAGE, /INFORMATIONAL, $
			'Data type must be either of type FLOAT or DOUBLE'
		RESULT = -1
		COUNT = 0
		END
	ENDCASE
;
	RETURN, RESULT
	END

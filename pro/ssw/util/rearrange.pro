	FUNCTION REARRANGE,ARRAY,DIMENSIONS
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	REARRANGE()
; Purpose     :	
;	Rearranges the dimensions in an array (ala TRANSPOSE).
; Explanation :	
;	Rearranges the dimensions in an array.  The concept is similar to
;	TRANSPOSE or ROTATE, but generalized to N dimensions.
; Use         :	
;	Result = REARRANGE(ARRAY,DIMENSIONS)
;
;	EXAMPLE:  If ARRAY has the dimensions NI x NJ x NK, then
;
;			RESULT = REARRANGE(ARRAY, [3,1,2])
;
;		  will have the dimensions NK x NI x NJ.
;
; Inputs      :	
;	ARRAY		= Input array to be rearranged.
;	DIMENSIONS	= Array containing the order of the original dimensions
;			  once they are rearranged.  Each dimension is
;			  specified by a number from 1 to N.  If any dimension
;			  is negative, then the order of the elements is
;			  reversed in that dimension.
; Opt. Inputs :	
;	None.
; Outputs     :	
;	The result of the function is ARRAY with the dimensions rearranged into
;	the order specified by DIMENSIONS.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	None.
; Env. Vars.  :
;	SSW_EXTERNAL = Points to a sharable object file containing associated C
;		       software callable by CALL_EXTERNAL.  If this environment
;		       variable exists, then the routine uses CALL_EXTERNAL to
;		       perform the rearrangement.  Otherwise the rearrangement
;		       is performed within IDL, which is slower.
;
;		       For backwards compatibility, the software will also look
;		       for the environment variable CDS_EXTERNAL if it doesn't
;		       find SSW_EXTERNAL
;
;	SSW_EXTERNAL_PREFACE = On some operating systems, such as older
;		       versions of SunOS, this needs to be set to the
;		       underscore character "_".  Otherwise, it doesn't need to
;		       be defined.
; Calls       :	
;	None.
; Common      :	
;	None.
; Restrictions:	
;	DIMENSIONS cannot contain the same dimensions more than once each.
;	Each dimension must be accounted for.
;
;	This routine is not very fast for large arrays, unless SSW_EXTERNAL is
;       defined so that CALL_EXTERNAL is used.
; Side effects:	
;	None.
; Category    :	
;	Utilities, Arrays.
; Prev. Hist. :	
;	William Thompson, February 1993.
;	William Thompson, 30 June 1993, modified to allow dimensions to be
;		reversed.
; Written     :	
;	William Thompson, GSFC, February 1993.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 24 August 1994.
;		Combined pure IDL and CALL_EXTERNAL versions into one routine.
;		Ported CALL_EXTERNAL software to OSF.
;	Version 3, William Thompson, GSFC, 27 December 1994
;		Fixed bug where trailing dimensions with one element were lost.
;	Version 4, William Thompson, GSFC, 16 July 1998
;		Look for SSW_EXTERNAL evar before CDS_EXTERNAL
;		Check for SSW_EXTERNAL_PREFACE instead of !version.os
;	Version 5, William Thompson, GSFC, 14 August 2000
;		Using TRANSPOSE where possible.
; Version     :	
;	Version 5, 14 August 2000
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  Result = REARRANGE( ARRAY, DIMENSIONS )'
;
;  Make sure that the parameters are defined.
;
	IF N_ELEMENTS(ARRAY) EQ 0 THEN MESSAGE,'ARRAY not defined'
	IF N_ELEMENTS(DIMENSIONS) EQ 0 THEN MESSAGE,'DIMENSIONS not defined'
;
;  Check the number of dimensions passed against the dimensions of the array.
;
	SZ = SIZE(ARRAY)
	TYPE = SZ(SZ(0) + 1)
	N_DIM = SZ(0)
	IF N_ELEMENTS(DIMENSIONS) NE N_DIM THEN MESSAGE,	$
		'Dimensions passed do not match array dimensions'
;
;  Check the dimensions passed against the dimensions of the array.  Make sure
;  that each dimension is legal, and that no dimension is specified twice.
;
	FOUND = REPLICATE(0,N_DIM)
	FOR I = 0,N_DIM-1 DO BEGIN
		DIM = ABS(DIMENSIONS(I))
		IF DIM NE LONG(DIM) THEN MESSAGE,	$
			'Fractional dimension specified'
		IF (DIM LT 1) OR (DIM GT N_DIM) THEN MESSAGE,	$
			'Illegal dimension specified'
		IF FOUND(DIM-1) THEN MESSAGE, 'Multiply declared dimension'
		FOUND(DIM-1) = 1
	ENDFOR
;
;  One- and two-dimensional arrays represent trivial cases.
;
	IF (N_DIM EQ 1) THEN	$
		IF (DIMENSIONS(0) EQ 1) THEN	$
			RETURN, ARRAY ELSE RETURN, REVERSE(ARRAY)
;
	IF N_DIM EQ 2 THEN BEGIN
		DIM1 = DIMENSIONS(0)
		DIM2 = DIMENSIONS(1)
		IF (DIM1 EQ 1) AND (DIM2 EQ 2) THEN BEGIN
			RETURN, ARRAY
		END ELSE IF (DIM1 EQ -1) AND (DIM2 EQ  2) THEN BEGIN
			RETURN, REVERSE(ARRAY,1)
		END ELSE IF (DIM1 EQ  1) AND (DIM2 EQ -2) THEN BEGIN
			RETURN, REVERSE(ARRAY,2)
		END ELSE IF (DIM1 EQ -1) AND (DIM2 EQ -2) THEN BEGIN
			RETURN, REVERSE(REVERSE(ARRAY,1),2)
		END ELSE IF (DIM1 EQ  2) AND (DIM2 EQ  1) THEN BEGIN
			RETURN, TRANSPOSE(ARRAY)
		END ELSE IF (DIM1 EQ -2) AND (DIM2 EQ  1) THEN BEGIN
			RETURN, REVERSE(TRANSPOSE(ARRAY),1)
		END ELSE IF (DIM1 EQ  2) AND (DIM2 EQ -1) THEN BEGIN
			RETURN, REVERSE(TRANSPOSE(ARRAY),2)
		END ELSE IF (DIM1 EQ -2) AND (DIM2 EQ -1) THEN BEGIN
			RETURN, REVERSE(REVERSE(TRANSPOSE(ARRAY),1),2)
		ENDIF
	ENDIF
;
;  If the IDL version is 4.0.1 or greater, and no dimension reversals are
;  requested, then use the built-in TRANSPOSE capability.
;
	IF (!VERSION.RELEASE GE '4.0.1') AND (MIN(DIMENSIONS) GT 0) THEN $
		RETURN, TRANSPOSE(ARRAY, DIMENSIONS-1)
;
;  Check to see if any reordering is actually necessary.
;
	TRIVIAL = 1
	FOR I = 0,N_DIM-1 DO IF DIMENSIONS(I) NE I+1 THEN TRIVIAL = 0
	IF TRIVIAL THEN RETURN, ARRAY
;
;  Check to see if the logical name SSW_EXTERNAL exists.  If it does, then use
;  the CALL_EXTERNAL portion of this routine.
;
	SSW_EXTERNAL = GETENV('SSW_EXTERNAL')
	IF SSW_EXTERNAL NE '' THEN BEGIN
	    EVAR_FOUND = "SSW_EXTERNAL"
	    GOTO, CALL_EXTERNAL
	ENDIF
;
;  Also check the CDS_EXTERNAL environment variable.  If this works, then use
;  CALL_EXTERNAL with the value of this environment variable.
;
	SSW_EXTERNAL = GETENV('CDS_EXTERNAL')
	IF SSW_EXTERNAL NE '' THEN BEGIN
	    EVAR_FOUND = "CDS_EXTERNAL"
	    GOTO, CALL_EXTERNAL
	ENDIF
;
;  Calculate the coordinates that map the original array into the new reordered
;  array.
;
	COORDINATES = MAKE_ARRAY(DIMENSION=SZ(ABS(DIMENSIONS)),/LONG)
	INDEX = MAKE_ARRAY(DIMENSION=SZ(ABS(DIMENSIONS)),/LONG,/INDEX)
	FOR I = 0,N_DIM-1 DO BEGIN
		DIM = ABS(DIMENSIONS(I))
		MULTIPLIER = 1L
		IF DIM GT 1 THEN FOR J = 1,DIM-1 DO	$
			MULTIPLIER = MULTIPLIER * SZ(J)
		DIVIDER = 1L
		IF I GT 0 THEN FOR J = 0,I-1 DO		$
			DIVIDER = DIVIDER * SZ(ABS(DIMENSIONS(J)))
		TEMP = (INDEX/DIVIDER) MOD SZ(DIM)
		IF DIMENSIONS(I) LT 0 THEN TEMP = (SZ(DIM)-1) - TEMP
		COORDINATES = TEMPORARY(COORDINATES)  +  MULTIPLIER * TEMP
	ENDFOR
;
;  Return the reordered array.  Make sure that no trivial (one-element)
;  dimensions are lost.
;
	OUT = ARRAY(COORDINATES)
	OUT = REFORM(OUT,SZ(ABS(DIMENSIONS)),/OVERWRITE)
	RETURN, OUT
;
;******************************************************************************
;	This is the beginning of the CALL_EXTERNAL part of the routine.
;******************************************************************************
;
CALL_EXTERNAL:
;
;  Chose the data type that matches the number of bytes per value of the input
;  array.  Depending on the data type, call either C_REARRANGE, S_REARRANGE,
;  L_REARRANGE or D_REARRANGE.
;
	CASE TYPE OF
		0: MESSAGE,'ARRAY not defined.'
		1: ROUTINE_NAME = "C_REARRANGE"		;Byte
		2: ROUTINE_NAME = "S_REARRANGE"		;Short integer
		3: ROUTINE_NAME = "L_REARRANGE"		;Long integer
		4: ROUTINE_NAME = "L_REARRANGE"		;Floating
		5: ROUTINE_NAME = "D_REARRANGE"		;Double precision
		6: ROUTINE_NAME = "D_REARRANGE"		;Complex
		7: MESSAGE,'Operation not supported for string variables.'
		8: MESSAGE,'Operation not supported for structures.'
	ENDCASE
;
;  If Unix, then the routine name will have the form "name_c" instead of
;  "NAME".  If the environment variable SSW_EXTERNAL_PREFACE is set to the "_"
;  character, then this will be prepended to the name.  This is required in
;  some situations, such as older versions of SunOS.
;
	IF !VERSION.OS NE "vms" THEN ROUTINE_NAME =	$
		STRLOWCASE(ROUTINE_NAME) + "_c"
	ROUTINE_NAME = GETENV("SSW_EXTERNAL_PREFACE") + ROUTINE_NAME
;
;  Form the name of the sharable object file.
;
	IF !VERSION.OS EQ "vms" THEN FILENAME = EVAR_FOUND ELSE	$
		FILENAME = SSW_EXTERNAL
;
;  Make the output array the same structure as the input array.  Make sure that
;  no trivial (one-element) dimensions are lost.
;
	DIM = LONG(SZ(1:N_DIM))
	OUT = MAKE_ARRAY(DIM=SZ(ABS(DIMENSIONS)),TYPE=TYPE,/NOZERO)
	OUT = REFORM(OUT,SZ(ABS(DIMENSIONS)),/OVERWRITE)
;
;  Perform the rearrangement.
;
	VALUE = BYTARR(5)
	IF !VERSION.OS EQ 'vms' THEN VALUE(4) = 1B
	TEST1 = CALL_EXTERNAL(FILENAME, ROUTINE_NAME, ARRAY, OUT, DIM,	$
		FIX(DIMENSIONS), FIX(N_ELEMENTS(DIMENSIONS)),VALUE=VALUE)
;
	RETURN, OUT
	END

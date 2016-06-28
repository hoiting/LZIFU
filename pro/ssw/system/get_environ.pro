	FUNCTION GET_ENVIRON, EVAR, PATH=PATH
;+
; Project     :	SOHO - CDS
;
; Name        :	GET_ENVIRON()
;
; Purpose     :	Get environment variables.
;
; Category    :	
;
; Explanation :	In VMS, logical names can be either single valued or
;		multi-valued.  This routine will use TRNLOG,/FULL to get the
;		full translation of a logical name in VMS.  In other operating
;		systems, GETENV is used instead.
;
; Syntax      :	Result = GET_ENVIRON( EVAR )
;
; Examples    :	ZDBASE = GET_ENVIRON('ZDBASE')
;
; Inputs      :	EVAR	= The name of the environment variable.  It can start
;			  with a $ to signal that it is a logical name, but
;			  that isn't necessary.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the value of the environment
;		variable.
;
; Opt. Outputs:	None.
;
; Keywords    :	PATH	= If set, then the value of the environment variable is
;			  returned as a single delimited string, even if the
;			  environment variable is multi-valued.  Ignored in
;			  operating systems other than VMS.
;
; Calls       :	
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, William Thompson, GSFC, 7 August 1996
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 1 THEN MESSAGE,	$
		'Syntax:  Result = GET_ENVIRON( EVAR )'
;
;  If the operating system is VMS, then use TRNLOG to get the value.
;
	IF OS_FAMILY() EQ 'vms' THEN BEGIN
	    DUMMY = EXECUTE('TEST = TRNLOG(EVAR, VALUE, /FULL)')
;
;  If unsuccessful, and the input starts with a dollar sign, then try it
;  without the dollar sign.
;
	    IF (NOT TEST) AND (STRMID(EVAR,0,1) EQ '$') THEN BEGIN
		FOLLOWING = STRMID(EVAR,1,STRLEN(EVAR)-1)
		DUMMY = EXECUTE('TEST = TRNLOG(FOLLOWING, VALUE, /FULL)')
	    ENDIF
	    IF NOT TEST THEN RETURN, ''
	    IF KEYWORD_SET(PATH) THEN BEGIN
		VAL = VALUE
		VALUE = VALUE(0)
		FOR I = 1,N_ELEMENTS(VAL)-1 DO VALUE = VALUE + ',' + VAL(I)
	    ENDIF
;
;  For other operating systems, use GETENV.
;
	END ELSE BEGIN
	    VALUE = GETENV(EVAR)
	    IF (VALUE EQ '') AND (STRMID(EVAR,0,1) EQ '$') THEN BEGIN
		FOLLOWING = STRMID(EVAR,1,STRLEN(EVAR)-1)
		VALUE = GETENV(FOLLOWING)
	    ENDIF
	ENDELSE
;
	RETURN, VALUE
	END

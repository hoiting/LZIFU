	PRO SETENV, EXPRESSION
;+
; Project     :	SOHO - CDS
;
; Name        :	SETENV
;
; Purpose     :	Emulates the SETENV routine in VMS.
;
; Explanation :	Converts the SETENV syntax used in Unix and Microsoft Windows
;		to the equivalent SETLOG statement in VMS.
;
; Use         :	SETENV, EXPRESSION
;
;		SETENV, 'ZDBASE=SYS$USER1:[CDS.DATA.PLAN.DATABASE]'
;
; Inputs      :	EXPRESSION = A scalar string containing the name of the
;			     environment variable to be defined, followed by
;			     the equals "=" character, and the value to set
;			     this environment variable to.
;
;			     Note that this string must not contain any blanks
;			     before or after the "=" character.  For example,
;
;				SETENV, 'ZDBASE = SYS$USER1:[THOMPSON]'
;
;			     would not work correctly, because of the embedded
;			     blanks.  This behavior is the same in the internal
;			     SETENV procedure in Unix.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	DATATYPE
;
; Common      :	None.
;
; Restrictions:	VMS-only.  In Unix and Microsoft Windows, the built-in SETENV
;		routine is used instead.
;
; Side effects:	None.
;
; Category    :	Utilities, Operating_system.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 27 March 1995
;
; Modified    :	Version 1, William Thompson, 27 March 1995
;
; Version     :	Version 1, 27 March 1995
;-
;
	ON_ERROR, 2
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, "Syntax: SETENV, 'NAME=VALUE'"
	IF N_ELEMENTS(EXPRESSION) NE 1 THEN MESSAGE,		$
		'Input expression must be a scalar'
	IF DATATYPE(EXPRESSION,1) NE 'String' THEN MESSAGE,	$
		'Input expression must be a character string'
;
;  Parse the character string into the environment variable name and the value
;  to apply to it.
;
	POS = STRPOS(EXPRESSION,'=')
	IF POS LE 0 THEN MESSAGE,	$
		'Expression must have the syntax: "NAME=VALUE"'
	NAME = STRMID(EXPRESSION,0,POS)
	VALUE = STRMID(EXPRESSION,POS+1,STRLEN(EXPRESSION)-POS-1)
;
;  Define the environment variable and return.
;
	SETLOG, NAME, VALUE
	RETURN
	END

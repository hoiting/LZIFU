	FUNCTION SAFE_STRING, EXPRESSION, _EXTRA=_EXTRA
;+
; Project     :	SOHO - CDS
;
; Name        :	SAFE_STRING()
;
; Purpose     :	Safe version of STRING
;
; Category    :	
;
; Explanation :	STRING has a limitation of 1024 strings when used with an
;		explicit FORMAT specification.  Using this routine gets around
;		that limitation.
;
; Syntax      :	Result = SAFE_STRING( EXPRESSION )
;
; Examples    :	dd = strmid(safe_string(ext.day+100,format='(i3)'),1,2)
;
; Inputs      :	EXPRESSION = The expression to be converted to string type.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the converted string.
;
; Opt. Outputs:	None.
;
; Keywords    :	Any keywords allowed by the STRING function.
;
; Calls       :	STRING
;
; Common      :	None.
;
; Restrictions:	At the moment, only one expression can be passed to
;		SAFE_STRING, whereas the built-in STRING function can take
;		multiple inputs.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 18-Mar-1998, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	N_EXP = N_ELEMENTS(EXPRESSION)
	IF N_EXP EQ 0 THEN MESSAGE, 'EXPRESSION is undefined'
	IF N_EXP EQ 1 THEN RESULT = STRING(EXPRESSION, _EXTRA=_EXTRA) ELSE BEGIN
	    RESULT = STRARR(N_EXP)
	    I1 = 0
	    WHILE I1 LT N_EXP DO BEGIN
		I2 = (I1 + 1023) < (N_EXP-1)
		RESULT(I1:I2) = STRING(EXPRESSION(I1:I2), _EXTRA=_EXTRA)
		I1 = I2 + 1
	    ENDWHILE
	ENDELSE
;
	RETURN, RESULT
	END

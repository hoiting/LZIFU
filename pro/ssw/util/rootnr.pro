	PRO ROOTNR,FUNC,VARIABLE,START,PARAMS,ACCURACY=ACCURACY,	$
		MAX_ITER=MAX_ITER,VALUE=VALUE
;+
; Project     :	SOHO - CDS
;
; Name        :	ROOTNR
;
; Purpose     :	Finds the value of VARIABLE for which FUNC(VARIABLE) = 0.
;
; Explanation :	Finds the value of VARIABLE for which FUNC(VARIABLE) = 0.
;
;		Approximations to VARIABLE are made by a modified version of
;		the Newton-Raphson method until either MAX_ITER is exceeded or
;		else successive estimates of VARIABLE differ by less than
;		ACCURACY.
;
; Use         :	ROOTNR, FUNC, VARIABLE, START  [, PARAMS ]
;
; Inputs      :	FUNC	  - Character string containing name of function.
;		START	  - Initial guess.
;
; Opt. Inputs :	PARAMS	  - The parameters of the function FUNC.  If passed,
;		FUNC has the form
; 
;			F = FUNC(VARIABLE,PARAMS)
; 
;		Otherwise it has the form
; 
;			F = FUNC(VARIABLE)
;
; Outputs     :	VARIABLE  - Variable to store result in.
;
; Opt. Outputs:	None.
;
; Keywords    :	ACCURACY = Accuracy to cut off at.  Defaults to 1E-5.
;		MAX_ITER = Maximum number of reiterations.  Defaults to 20.
;		VALUE	 = Finds VARIABLE for which FUNC(VARIABLE) = VALUE.
;			   Defaults to zero.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	The function FUNC must have one of the above two forms.
;
; Side effects:	None.
;
; Category    :	Utilities, Curve_Fitting.
;
; Prev. Hist. :	
;	William Thompson, February, 1990, from FORTRAN subroutine written by
;		Roger Thomas.
;	William Thompson, December 1991, modified for IDL version 2.
;
; Written     :	William Thompson, GSFC, February 1990
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;		Version 2, William Thompson, GSFC, 19 July 2000
;			Fixed bug detecting whether or not PARAMS was passed.
;
; Version     :	Version 2, 19 July 2000
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 3 THEN BEGIN
		PRINT,'*** ROOTNR must be called with 3 or 4 parameters:'
		PRINT,'      FUNC, VARIABLE, START  [, PARAMS ]'
		RETURN
	ENDIF
;
;  Set up the default parameters.
;
	ACCUR = 1E-5
	IF N_ELEMENTS(ACCURACY) EQ 1 THEN	$
		IF ACCURACY GT 0 THEN ACCUR = ACCURACY
;
	IF N_ELEMENTS(MAX_ITER) EQ 1 THEN NMAX = MAX_ITER ELSE NMAX = 20
;
	DEL = 1.D-6
	OLDVAR = START
	IF OLDVAR EQ 0 THEN OLDVAR = DEL
	IF ABS(OLDVAR) LT DEL THEN OLDVAR = DEL * OLDVAR / ABS(OLDVAR)
	FOR I = 1,NMAX DO BEGIN
		DELVAR = OLDVAR * (1.D0 + DEL)
		IF N_PARAMS(0) NE 4 THEN PAR = '' ELSE PAR = ',PARAMS'
		TEST = EXECUTE('FUNC1  = ' + FUNC + '(DELVAR' + PAR + ')')
		TEST = EXECUTE('FUNC2  = ' + FUNC + '(OLDVAR' + PAR + ')')
		IF N_ELEMENTS(VALUE) EQ 1 THEN BEGIN
			FUNC1 = FUNC1 - VALUE
			FUNC2 = FUNC2 - VALUE
		ENDIF
		IF FUNC1 EQ FUNC2 THEN BEGIN
			DEL = -DEL
		END ELSE BEGIN
			IF FUNC2 EQ 0 THEN VARIABLE = OLDVAR
			IF FUNC2 NE 0 THEN VARIABLE = OLDVAR * $
				(1.D0 - DEL / (FUNC1/FUNC2 - 1.D0))
			TEST = ABS(VARIABLE - OLDVAR)
			IF TEST LT ACCUR THEN RETURN
			OLDVAR = VARIABLE
		ENDELSE
	ENDFOR
;
	BELL = 7B
	PRINT,BELL,BELL,FORMAT=		$
		"(/1X,A1,'********** LIMIT HAS BEEN EXCEEDED **********',A1/)"
	RETURN
	END

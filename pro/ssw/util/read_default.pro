	PRO READ_DEFAULT,PROMPT,ANSWER,DEFAULT
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	READ_DEFAULT
; Purpose     :	
;	Prompts for a variable with a default value.
; Explanation :	
;	Reads in a variable from the terminal.  If nothing is typed in, then
;	the default is used. 
; Use         :	
;	READ_DEFAULT, PROMPT, ANSWER, DEFAULT
; Inputs      :	
;	PROMPT	= Prompt to READ_DEFAULT for input.
;	DEFAULT	= Default answer if nothing typed in.
; Opt. Inputs :	
;
; Outputs     :	
;	ANSWER	= Answer, either typed in or default.	
; Opt. Outputs:	
;	None.
; Keywords    :	
;	None.
; Calls       :	
;	TRIM
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	None.
; Category    :	
;	Utilities, User_interface.
; Prev. Hist. :	
;	W.T.T., Oct. 1989.
; Written     :	
;	William Thompson, GSFC, October 1989.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
; Version     :	
;	Version 1, 9 July 1993.
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 3 THEN BEGIN
		PRINT,'*** READ_DEFAULT must be called with three parameters:'
		PRINT,'              PROMPT, ANSWER, DEFAULT'
		RETURN
	ENDIF
;
;  Check the size and type of PROMPT.
;
	SZ = SIZE(PROMPT)
	IF SZ(0) NE 0 THEN BEGIN
		PRINT,'*** PROMPT must be scalar, routine READ_DEFAULT.'
		RETURN
	END ELSE IF SZ(1) EQ 0 THEN BEGIN
		PRINT,'*** PROMPT not defined, routine READ_DEFAULT.'
		RETURN
	END ELSE IF SZ(1) NE 7 THEN BEGIN
		PRINT,'*** PROMPT must be of type string, routine READ_DEFAULT.'
		RETURN
	ENDIF
;
;  Check the size of DEFAULT.
;
	SZ = SIZE(DEFAULT)
	IF SZ(0) NE 0 THEN BEGIN
		PRINT,'*** DEFAULT must be scalar, routine READ_DEFAULT.'
		RETURN
	END ELSE IF SZ(1) EQ 0 THEN BEGIN
		PRINT,'*** DEFAULT not defined, routine READ_DEFAULT.'
		RETURN
	ENDIF
	TYPE = SZ(1)
;
;  Read in the answer.  The default answer is displayed surrounded by [].
;
	ANS = 'STRING'
	IF TYPE EQ 1 THEN DEF = FIX(DEFAULT) ELSE DEF = DEFAULT
	READ,PROMPT + " [" + TRIM(DEF) + "]? ",ANS
	IF ANS EQ "" THEN ANSWER = DEFAULT ELSE CASE TYPE OF
		1: ANSWER = BYTE(FIX(ANS))
		2: ANSWER = FIX(ANS)
		3: ANSWER = LONG(ANS)
		4: ANSWER = FLOAT(ANS)
		5: ANSWER = DOUBLE(ANS)
		6: ANSWER = COMPLEX(ANS)
		7: ANSWER = ANS
	ENDCASE
;
	RETURN
	END

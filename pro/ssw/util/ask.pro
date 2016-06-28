	PRO ASK,PROMPT,ANSWER,VALID,FONT=FONT
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	ASK
; Purpose     :	
;	Gets a single letter response from the keyboard.
; Explanation :	
;	Gets a single letter response from the keyboard.  Only responses in the
;	array VALID are allowed.  The prompt string is printed, and GET_KBRD is
;	called to read in the result.
; Use         :	
;	ASK, PROMPT, ANSWER  [, VALID ]
;
;	Example:  ASK, 'Do you want to continue? ', ANSWER
;
; Inputs      :	
;	PROMPT	= Prompt to ask for input.
; Opt. Inputs :	
;	VALID	= List of valid responses, put together into one character
;		  string.  If not passed, then "YN" is assumed.  All characters
;		  are converted to uppercase.
; Outputs     :	
;	ANSWER	= Single letter answer.  This is always returned as uppercase.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	FONT	= Font to use when displaying the prompt widget.  Only
;		  meaningful when the prompt is displayed in a text widget
;		  (currently only in IDL for Windows).  If not passed, then the
;		  first available 20 point font is used.
; Calls       :	
;	SETPLOT
; Common      :	
;	None.
; Restrictions:	
;	Any non-printing key will act just like the return key when used with
;	IDL for Microsoft Windows.  This includes the delete and backspace
;	keys, which otherwise would erase the previous selected character.
; Side effects:	
;	None.
; Category    :	
;	Utilities, User_interface.
; Prev. Hist. :	
;	W.T.T., Oct. 1989.
;	William Thompson, 11 May 1993, converted to use widgets when available.
;		This makes it compatible with IDL for Windows, together with a
;		small change for carriage returns.  Also added FONT keyword.
;	William Thompson, 22 June 1993, converted to use widgets only with IDL
;		for Windows.
; Written     :	
;	William Thompson, GSFC, October 1989.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 11-Aug-1997
;		Changed to be more compatible with IDL v4.
; Version     :	
;	Version 2, 11-Aug-1997
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 2 THEN BEGIN
		PRINT,'*** ASK must be called with 2-3 parameters:'
		PRINT,'          PROMPT, ANSWER  [, VALID ]'
		RETURN
	END ELSE IF N_PARAMS(0) EQ 2 THEN VALID = "YN"
;
;  Check the size and type of PROMPT.
;
	SZ = SIZE(PROMPT)
	IF SZ(0) NE 0 THEN BEGIN
		PRINT,'*** PROMPT must be scalar, routine ASK.'
		RETURN
	END ELSE IF SZ(1) EQ 0 THEN BEGIN
		PRINT,'*** PROMPT not defined, routine ASK.'
		RETURN
	END ELSE IF SZ(1) NE 7 THEN BEGIN
		PRINT,'*** PROMPT must be of type string, routine ASK.'
		RETURN
	ENDIF
;
;  Check the size and type of VALID.
;
	SZ = SIZE(VALID)
	IF SZ(0) NE 0 THEN BEGIN
		PRINT,'*** VALID must be scalar, routine ASK.'
		RETURN
	END ELSE IF SZ(1) EQ 0 THEN BEGIN
		PRINT,'*** VALID not defined, routine ASK.'
		RETURN
	END ELSE IF SZ(1) NE 7 THEN BEGIN
		PRINT,'*** VALID must be of type string, routine ASK.'
		RETURN
	ENDIF
;
;  Parse out all the valid responses.
;
	NV = STRLEN(VALID)
	IF NV LT 1 THEN BEGIN
		PRINT,'*** There are no valid responses, routine ASK.'
		RETURN
	ENDIF
	OKAY = STRARR(1,NV)
	FOR I = 0,NV-1 DO OKAY(I) = STRUPCASE(STRMID(VALID,I,1))
;
;  If the current operating system is Microsoft Windows, then display the
;  prompt in a special text widget.  Also display the possible responses.
;
	IF !VERSION.OS EQ 'windows' THEN BEGIN
		OLD_DEVICE = !D.NAME
		SETPLOT, 'WIN'
		TEST = EXECUTE("BASE = WIDGET_BASE(TITLE='Ask',/ROW)")
		TEXT = PROMPT + '  (' + OKAY(0)
		FOR I = 1,STRLEN(VALID)-1 DO TEXT = TEXT + ',' + OKAY(I)
		TEXT = TEXT + ')'
		IF N_ELEMENTS(FONT) NE 1 THEN FONT = '*20'
		TEST = EXECUTE("LABEL = WIDGET_TEXT(BASE,VALUE=TEXT," +	$
			"FONT=FONT,XSIZE=STRLEN(TEXT))")
		WIDGET_CONTROL,BASE,/REALIZE
;
;  Otherwise, print out the prompt without doing a carriage return.  Do this by
;  opening a special output to the terminal.
;
	END ELSE IF !VERSION.OS EQ 'vms' THEN BEGIN
		OPENW, LUN, FILEPATH(/TERMINAL), /GET_LUN, /FORTRAN
		PRINTF, LUN, FORMAT='(1X,A,$)', PROMPT
	END ELSE BEGIN
		OPENW, LUN, FILEPATH(/TERMINAL), /GET_LUN
		PRINTF, LUN, FORMAT='(A,$)', PROMPT
	ENDELSE
;
;  Get a character from the keyboard until a valid response is generated, and
;  the return key is pressed.
;
	DONE = 0
	ANSWER = ''
	WHILE NOT DONE DO BEGIN
	    CHAR = STRUPCASE(GET_KBRD(1))
;
;  If the character is either a carriage-return or line-feed, and a valid
;  response has already been selected, then mark the loop as done.  In IDL for
;  Windows the carriage return and line-feed characters show up as the null
;  string.
;
	    BCHAR = (BYTE(CHAR))(0)
	    IF ((BCHAR EQ 10) OR (BCHAR EQ 13) OR (BCHAR EQ 0)) AND	$
			(ANSWER NE '') THEN BEGIN
	        DONE = 1
;
;  If the character is either the delete or backspace character, then remove
;  the previously selected answer.
;
	    END ELSE IF (CHAR EQ STRING(127B)) OR (CHAR EQ STRING(8B)) THEN $
	            BEGIN
	        ANSWER = ''
		IF !VERSION.OS EQ 'windows' THEN BEGIN
		    STRPUT,TEXT,' ',STRLEN(PROMPT)
		    WIDGET_CONTROL, LABEL, SET_VALUE=TEXT
	        END ELSE IF !VERSION.OS EQ 'vms' THEN BEGIN
	            PRINTF, LUN, PROMPT+' ', FORMAT='(1H+,A,$)'
	        END ELSE BEGIN
	            PRINTF, LUN, STRING(13B), PROMPT+' ', FORMAT='(A1,A,$)'
	        ENDELSE
;
;  Otherwise, check to see if the character entered is a valid response.  If it
;  is, then print it out.
;
	    END ELSE FOR I = 0,NV-1 DO IF CHAR EQ OKAY(I) THEN BEGIN
                ANSWER = CHAR
		IF !VERSION.OS EQ 'windows' THEN BEGIN
		    STRPUT,TEXT,CHAR,STRLEN(PROMPT)
		    WIDGET_CONTROL, LABEL, SET_VALUE=TEXT
	        END ELSE IF !VERSION.OS EQ 'vms' THEN BEGIN
	            PRINTF, LUN, PROMPT+CHAR, FORMAT='(1H+,A,$)'
	        END ELSE BEGIN
	            PRINTF, LUN, STRING(13B), PROMPT+CHAR, FORMAT='(A1,A,$)'
	        ENDELSE
	    ENDIF
	ENDWHILE
;
;  Close the terminal output.
;
	IF !VERSION.OS EQ 'windows' THEN BEGIN
		WIDGET_CONTROL, /DESTROY, BASE
		SETPLOT, OLD_DEVICE
		PRINT, TEXT
	END ELSE BEGIN
		IF !VERSION.OS NE 'vms' THEN PRINT, ''
		FREE_LUN,LUN
	ENDELSE
;
	RETURN
	END

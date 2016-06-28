	PRO COUNTDOWN, NUMBER, OPEN=OPEN, CLOSE=CLOSE, FONT=FONT
;+
; Project     : SOHO - CDS
;
; Name        : 
;	COUNTDOWN
; Purpose     : 
;	Prints a message showing where you are in a long job.
; Explanation : 
;	Calling COUNTDOWN,n_steps,/OPEN prints a character string consisting of
;	some spaces, a slash, and the total number of steps.  Then each
;	subsequent call prints out the iteration number on the same line in the
;	spaces before the slash.  COUNTDOWN,/CLOSE then resets the behavior of
;	the terminal to the default, and linefeeds to a new line.
;
;	If the graphics device supports widgets, then a text widget is used
;	instead of the terminal screen/window.
;
; Use         : 
;	COUNTDOWN, N_STEPS, /OPEN	;To begin
;	COUNTDOWN, I_STEP		;Each step
;	COUNTDOWN, /CLOSE		;To finish
; Inputs      : 
;	NUMBER	= Either the total number of steps, or the step number.  Not
;		  required when closing the countdown.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	OPEN	= Used to open the countdown.
;	CLOSE	= Used to close the countdown.
;	FONT	= Font to use when displaying the countdown widget.  Only
;		  meaningful when the graphics device supports widgets.  If not
;		  passed, then the first available 20 point font is used.
; Calls       : 
;	TRIM
; Common      : 
;	Common block COUNT_DOWN is used simply to keep track of the logical
;	unit number used, and whether the countdown is open or not.  It also
;	keeps track of those variables used by the widget part of the software,
;	when applicable.
; Restrictions: 
;	No other output can be sent to the screen when countdown is in effect
;	(unless the graphics device uses widgets).  Should not be used in a
;	batch job.
; Side effects: 
;	If the individual steps are too close together in time, then this could
;	slow down the calling routine.
; Category    : 
;	Utilities, User_interface.
; Prev. Hist. : 
;	William Thompson, October 1991.
;	William Thompson, 12 May 1993, converted to use widgets when available.
;		This makes it compatible with IDL for Windows.  Also added FONT
;		keyword.
; Written     : 
;	William Thompson, GSFC, October 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 14 May 1993.
;		Incorporated into CDS library.
; Version     : 
;	Version 1, 14 May 1993.
;-
;
	COMMON COUNT_DOWN, OPENED, LUN, BASE, LABEL, TEXT
;
;  Make sure the common block is properly initialized.
;
	IF N_ELEMENTS(OPENED) EQ 0 THEN OPENED = 0
;
;  First check to see if the CLOSE keyword is set.  If so, all other parameters
;  and keywords are ignored.  If the output has not been opened, print an error
;  message.  Otherwise, close the output.
;
	IF KEYWORD_SET(CLOSE) THEN BEGIN
	    IF NOT OPENED THEN BEGIN
		PRINT,'*** COUNTDOWN output has not been opened.'
		RETURN
	    ENDIF
	    IF HAVE_WIDGETS() THEN BEGIN
		WIDGET_CONTROL, /DESTROY, BASE
	    END ELSE BEGIN
	        IF !VERSION.OS NE 'vms' THEN PRINTF, LUN, ''
	        FREE_LUN, LUN
	    ENDELSE
	    OPENED = 0
	    RETURN
;
;  Otherwise, the NUMBER parameter must be passed.
;
	END ELSE BEGIN
	    IF N_PARAMS() EQ 0 THEN BEGIN
	        PRINT,'*** NUMBER not passed, routine COUNTDOWN.'
	        RETURN
	    ENDIF
;
;  If the OPEN keyword is set, first make sure the output is not already
;  opened.
;
	    IF KEYWORD_SET(OPEN) THEN BEGIN
	        IF OPENED THEN BEGIN
		    PRINT,'*** COUNTDOWN output already opened.'
		    RETURN
	        ENDIF
;
;  If the current graphics device supports widgets, then display the text in
;  a special text widget.
;
	        STR = '           / ' + TRIM(NUMBER)
		IF HAVE_WIDGETS() THEN BEGIN
		    TEST = EXECUTE("BASE = WIDGET_BASE(" +	$
			"TITLE='Countdown',/ROW)")
		    TEXT = STR
		    IF N_ELEMENTS(FONT) NE 1 THEN FONT = '*20'
		    TEST = EXECUTE("LABEL = WIDGET_TEXT(BASE,VALUE=TEXT," + $
			"FONT=FONT,XSIZE=STRLEN(TEXT))")
		    WIDGET_CONTROL,BASE,/REALIZE
;
;  Otherwise, open the output file, and print out the total number of steps.
;  Subsequent writes will appear over the blank space in this message.
;
	        END ELSE IF !VERSION.OS EQ 'vms' THEN BEGIN
	            OPENW, LUN, FILEPATH(/TERMINAL), /GET_LUN, /FORTRAN
	            PRINTF, LUN, STR, FORMAT='(1X,A,$)'
		END ELSE BEGIN
		    OPENW, LUN, FILEPATH(/TERMINAL), /GET_LUN
		    PRINTF, LUN, STR, FORMAT='(A,$)'
		ENDELSE
	        OPENED = 1
;
;  Neither the OPEN nor CLOSE keyword was passed.  If the output has been
;  opened, then print out the step number.
;
	    END ELSE IF OPENED THEN BEGIN
		IF HAVE_WIDGETS() THEN BEGIN
		    STR = STRING(NUMBER,FORMAT='(I10)')
		    STRPUT,TEXT,STR,0
		    WIDGET_CONTROL, LABEL, SET_VALUE=TEXT
		END ELSE IF !VERSION.OS EQ 'vms' THEN BEGIN
		    PRINTF, LUN, NUMBER, FORMAT='(1H+,I10,$)'
		END ELSE BEGIN
	            PRINTF, LUN, STRING(13B), NUMBER, FORMAT='(A1,I10,$)'
		ENDELSE
;
;  Otherwise, if the output hasn't been opened, then print out an error
;  message.
;
	    END ELSE BEGIN
	        PRINT,'*** COUNTDOWN output not initialized yet, ' + $
	            'call with /OPEN keyword.'
	    ENDELSE
	ENDELSE
;
	RETURN
	END

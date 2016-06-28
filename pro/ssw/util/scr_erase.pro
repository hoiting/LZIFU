PRO SCR_ERASE, cmd
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_ERASE
; Purpose     :	
;	To erase portions of the terminal screen.
; Explanation :	
;	To erase portions of the terminal screen.
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_erase [, cmd]
;
; Inputs      :	None.
;
; Opt. Inputs :	
;	cmd  --  An integer telling the procedure what part of the screen to
;	         erase.  If not specified, it is set to 5.  Key:
;	                 0 : From cursor to end-of-line.
;	                 1 : From beginning-of-line to cursor.
;	                 2 : Entire line containing cursor.
;	                 3 : From cursor to end-of-screen.
;	                 4 : from beginning-of-screen to cursor.
;	              ELSE : Entire screen.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	
;	This procedure will only work with DEC compatible equipment (or
;	terminal emulators).
;
; Side effects:	None.
;
; Category    :	Utilities, User_interface
;
; Prev. Hist. :	
;	Written by Michael R. Greason, STX, May 1990.
;
; Written     :	Michael R. Greason, GSFC/UIT (STX), May 1990
;
; Modified    :	Version 1, William Thompson, GSFC, 29 March 1994
;			Incorporated into CDS library
;
; Version     :	Version 1, 29 March 1994
;-
;
;			Check argument.
;
IF n_params(0) LT 1 THEN cmd = 5
;
;			Set up the command string.
;
CASE cmd OF
	   0 : scmd = strtrim(27B,2) + "[0K"	; From cursor to end-of-line.
	   1 : scmd = strtrim(27B,2) + "[1K"	; From beg.-of-line to cursor.
	   2 : scmd = strtrim(27B,2) + "[2K"	; Entire line containing cursor.
	   3 : scmd = strtrim(27B,2) + "[0J"	; From cursor to end-of-screen.
	   4 : scmd = strtrim(27B,2) + "[1J"	; from beg.-of-screen to cursor.
	ELSE : scmd = strtrim(27B,2) + "[2J"	; Entire screen.
ENDCASE
;
;			Issue the command.
;
fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
print, format=fmt, scmd
;
RETURN
END

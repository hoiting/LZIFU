PRO SCR_RESET, dum
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_RESET
; Purpose     :	
;	To reset the terminal.
; Explanation :	
;	To reset the terminal.
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_reset
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
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
;			Set up the command string.
;
scmd = strtrim(27B,2) + 'c'
;
;			Issue the command.
;
fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
print, format=fmt, scmd
;
RETURN
END

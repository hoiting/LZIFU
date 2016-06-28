PRO SCR_SCROLL, top, bot
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_SCROLL
; Purpose     :	
;	Defines the scrolling area on the screen.
; Explanation :	
;	To define the scrolling area on the screen.  Please note that the
;	line coordinates should be counted from 1.
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_scroll [, top, bot]
; Inputs      :	
;	top  --  The line to be the top of the scrolling area.
;	         The default value is 1 and the maximum value is 23.
;	bot  --  The line to be the bottom of the scrolling area.
;	         The default value is 24 and the minimum value is 2.
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
; Side effects:	
;	NOTE:  The screen coordinate system is NOT effected.  (1,1) is not
;	       the top of the scrolling area but the top of the screen.
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
;			Check arguments.
;
IF n_params(0) LT 1 THEN top = 1
top = ((top > 1) < 23)
IF n_params(0) LT 2 THEN bot = 24
bot = ((bot < 24) > 2)
;
;			Set up the command string.
;
scmd = strtrim(27B,2) + "[" + strtrim(top,2) + ";" + strtrim(bot,2) + "r"
;
;			Issue the command.
;
fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
print, format=fmt, scmd
;
RETURN
END

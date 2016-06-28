PRO SCR_CURPOS, lin, col
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_CURPOS
; Purpose     :	
;	Positions the cursor at the specified screen location.
; Explanation :	
;	To position the cursor at the specified screen location.  Unspecified
;	coordinates are set to one.  Please note that the ESCAPE sequence
;	expects the coordinates to be counted from (1,1).
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_curpos [, lin, col]
;
; Inputs      :	
;	lin  --  The screen line coordinate.
;	col  --  The screen column coordinate.
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
;			Check arguments.
;
IF n_params(0) LT 1 THEN lin = 1
IF n_params(0) LT 2 THEN col = 1
;
;			Set up the command string.
;
scmd = strtrim(27B,2) + "[" + strtrim(lin,2) + ";" + strtrim(col,2) + "H"
;
;			Issue the command.
;
fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
print, format=fmt, scmd
;
RETURN
END

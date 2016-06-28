PRO SCR_CHARSET, g, cset
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_CHARSET
; Purpose     :	
;	To change the character sets.
; Explanation :	
;	To change the character sets.
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_charset [, g, cset]
;
; Inputs      :	
;	g     --  The terminal character set to change (either 0, for the
;	          G0 designator, or 1, for the G1 designator).  0 = default.
;	cset  --  The character set to use:
;	               0 : United Kingdom.
;	               1 : United States (USASCII)  --  default.
;	               2 : Special graphics characters and line drawing set.
;	               3 : Alternate character ROM.
;	               4 : Alternate character ROM special graphics chars.
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
IF n_params(0) LT 1 THEN g = 0
IF n_params(0) LT 2 THEN cset = 1
;
;			Set up the command string.
;
IF g EQ 1 THEN mid = ')' ELSE mid = '('
CASE cset OF
	   0 : scmd = strtrim(27B,2) + '[' + mid + 'A'	; Up
	   2 : scmd = strtrim(27B,2) + '[' + mid + '0' ; Left
	   3 : scmd = strtrim(27B,2) + '[' + mid + '1' ; Right
	   4 : scmd = strtrim(27B,2) + '[' + mid + '2' ; Right
	ELSE : scmd = strtrim(27B,2) + '[' + mid + 'B' ; Down
ENDCASE
;
;			Issue the command.
;
fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
print, format=fmt, scmd
;
RETURN
END

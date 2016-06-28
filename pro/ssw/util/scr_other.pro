PRO SCR_OTHER, str
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SCR_OTHER
; Purpose     :	
;	To allow the user to issue any ESCAPE sequence.
; Explanation :	
;	To allow the user to issue any ESCAPE sequence.
;
;	A string containing the appropriate DEC terminal command is put 
;	together and printed.  NOTE:  In general, the DEC commands correspond
;	to the ANSI escape sequences.
;
; Use         :	
;	scr_other, str
;
; Inputs      :	
;	str  --  A string containing the escape sequence.  The initial ESCAPE
;	         should not be included; this will be added by this procedure.
;	         This parameter is NOT optional; if not available, the 
;	         procedure will return without doing anything.
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
;			Check argument.
;
IF n_params(0) GE 1 THEN BEGIN
;
;			Set up the command string.
;
	scmd = strtrim(27B,2) + str
;
;			Issue the command.
;
	fmt = "(A" + strtrim(strlen(scmd),2) + ",$)"
	print, format=fmt, scmd
;
ENDIF
;
RETURN
END

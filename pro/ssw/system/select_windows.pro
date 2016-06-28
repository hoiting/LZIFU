	PRO SELECT_WINDOWS
;+
; Project     :	SOHO - CDS
;
; Name        :	SELECT_WINDOWS
;
; Purpose     :	Select the windows display depending on OS
;
; Category    :	Class4, Display, OS
;
; Explanation :	Select the appropriate windows display depending on the
;		operating system, for example before running a widgets program
;		such as XDOC.  If the current graphics display already supports
;		windows, then do nothing.  Use SETPLOT to retain information
;		about the current graphics device.
;
; Syntax      :	SELECT_WINDOWS
;
; Examples    :	DSAVE = !D.NAME
;		SELECT_WINDOWS
;		... widget software ...
;		IF !D.NAME NE DSAVE THEN SETPLOT, DSAVE
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
; Calls       :	HAVE_WINDOWS, SETPLOT
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 23-Oct-1997, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	IF NOT HAVE_WINDOWS() THEN CASE OS_FAMILY() OF
		'Windows': SETPLOT, 'WIN'
		'MacOS':   SETPLOT, 'MAC'
		ELSE:	   SETPLOT, 'X'
	ENDCASE
;
	RETURN
	END

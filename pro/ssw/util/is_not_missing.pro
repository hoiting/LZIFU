	FUNCTION IS_NOT_MISSING,ARRAY,MISSING=MISSING
;+
; Project     : SOHO - CDS
;
; Name        : IS_NOT_MISSING()
;
; Purpose     : Returns whether or not array pixels are missing
;
; Explanation : Returns a vector array containing a boolean value signalling
;               good pixels, i.e. those pixels with a finite value (e.g. not
;               NaN), and not equal to a missing pixel flag value.
;
; Use         : Result = IS_NOT_MISSING( ARRAY, <keywords> )
;
; Inputs      : ARRAY	= Array to examine for missing pixels.
;
; Opt. Inputs : None.
;
; Outputs     : Result of function is an array containing 0 for missing pixels,
;               and 1 for good pixels.
;
; Opt. Outputs: None.
;
; Keywords    : MISSING = Value flagging missing pixels.
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; Category    : Utilities
;
; Prev. Hist. : None.
;
; Written     : William Thompson, GSFC, 29 April 2005
;
; Modified    : Version 1, William Thompson, GSFC, 29 April 2005
;
; Version     : Version 1, 29 April 2005
;-
;
	IF N_ELEMENTS(MISSING) EQ 1 THEN $
            RETURN, (ARRAY NE MISSING) AND FINITE(ARRAY) $
        ELSE RETURN, FINITE(ARRAY)
;
	END

	FUNCTION IS_MISSING,ARRAY,MISSING=MISSING
;+
; Project     : SOHO - CDS
;
; Name        : IS_MISSING()
;
; Purpose     : Returns whether or not array pixels are missing
;
; Explanation : Returns a vector array containing a boolean value signalling
;               missing pixels, i.e. those pixels with a non-finite value
;               (e.g. NaN), or equal to a missing pixel flag value.
;
; Use         : Result = IS_MISSING( ARRAY, <keywords> )
;
; Inputs      : ARRAY	= Array to examine for missing pixels.
;
; Opt. Inputs : None.
;
; Outputs     : Result of function is an array containing 1 for missing pixels,
;               and 0 for good pixels.
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
            RETURN, (ARRAY EQ MISSING) OR (FINITE(ARRAY) NE 1) $
        ELSE RETURN, FINITE(ARRAY) NE 1
;
	END

function where_missing, array, count, missing=missing, _ref_extra=_extra
;+
; Project     : SOHO - CDS
;
; Name        : WHERE_MISSING()
;
; Purpose     : Returns the position of all missing pixels in an array.
;
; Explanation : Returns a vector array containing the position of missing
;               pixels, i.e. those pixels with a non-finite value (e.g. NaN),
;               or equal to a missing pixel flag value.
;
; Use         : Result = WHERE_MISSING( ARRAY, <keywords> )
;
; Inputs      : ARRAY	= Array to examine for missing pixels.
;
; Opt. Inputs : None.
;
; Outputs     : Result of function is a linear array containing the positions
;               of all missing pixels.
;
; Opt. Outputs: COUNT   = The number of missing pixels found.
;
; Keywords    : MISSING = Value flagging missing pixels.
;
;               COMPLEMENT, NCOMPLEMENT = Returns the position and number of
;                         non-missing pixels.  (IDL 5.4 and higher)
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
;               Version 2, William Thompson, GSFC, 01-Jun-2005
;                       Use EXECUTE for pre-5.4 compatibility
;
; Version     : Version 2, 01-Jun-2005
;-
;
command = 'w = where((finite(array) ne 1)'
if n_elements(missing) eq 1 then command = command + ' or (array eq missing)'
command = command + ', count'
if !version.release ge '5.4' then command = command + ', _extra=_extra'
command = command + ')'
test = execute(command)
return, w
;
end

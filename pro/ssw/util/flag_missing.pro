pro flag_missing, array, index, missing=missing
;+
; Project     : SOHO - CDS
;
; Name        : FLAG_MISSING
;
; Purpose     : Flags pixels in images as missing
;
; Explanation : Sets pixels in an image to a value representing missing
;               pixels.  This flag value is either a specific number, given by
;               the MISSING keyword, or an IEEE Not-a-Number (NaN) value.
;
; Use         : FLAG_MISSING, ARRAY, INDEX  [, MISSING=MISSING]
;
; Inputs      : ARRAY	= Array to flag missing pixels within
;               INDEX   = Positions of missing pixels
;
; Opt. Inputs : None.
;
; Outputs     : The ARRAY variable is modified
;
; Opt. Outputs: None.
;
; Keywords    : MISSING = Value flagging missing pixels.
;
; Calls       : DATATYPE
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
; Written     : William Thompson, GSFC, 12-May-2005
;
; Modified    : Version 1, William Thompson, GSFC, 12-May-2005
;
; Version     : Version 1, 12-May-2005
;-
;
if n_elements(missing) eq 1 then array[index] = missing else $
  case datatype(array,2) of
    4: array[index] = !values.f_nan
    5: array[index] = !values.d_nan
    6: array[index] =  complex(!values.f_nan, !values.f_nan)
    9: array[index] = dcomplex(!values.d_nan, !values.d_nan)
    else: message, /continue, $
      'MISSING keyword must be passed for integer data'
endcase
;
end

;+
; Project     :	SOHO - CDS
;
; Name        :	SHORTHEX()
;
; Purpose     :	Converts an array of short int values into a fixed hex string format.
;
; Explanation :	Converts an array of short integer values into a single string of
;               values in 0xnnnn format separated by spaces.
;               NB On some machines INTs are 64 bit so z4.4 does not work.
;
; Use         : <str = shorthex(array)>
;
; Inputs      : array = short integer array.
;
; Opt. Inputs : None.
;
; Outputs     : Character string containing hex values.
;
; Opt. Outputs:	None.
;
; Keywords    : None.
;
; Calls       :	None.
;                
; Common      :	None.
;
; Restrictions:	There is a limit on how large a formatted string can be of 1024 lines.
;
; Side effects:	None.
;
; Category    :	Command preparation.
;
; Prev. Hist. :	None.
;
; Written     :	Version 0.00, Martin Carter, RAL, 14/10/94
;
; Modified    :	Version 0.01, Martin Carter, RAL, 28/11/94
;                            Added proforma.
;               Version 0.1, MKC, 3/10/95
;                            Converted to accept array input
;               Version 0.2, MKC, 6/10/95
;                            Corrected bug in v0.1
;
; Version     :	Version 0.2, 6/10/95
;
;**********************************************************

FUNCTION shorthex, array

  ; get array of hex strings truncated from the right 

  str = STRING ( FORMAT='(Z0)', array)

  ; get length of each string

  lstr = STRLEN(str)

  ; place hex strings into format '0x0000'

  output_str = ''

  FOR k = 0, N_ELEMENTS(str)-1 DO BEGIN
    
    ostr = ' 0x0000'

    ; only use bottom 4 nibbles of string
    ; so deal correctly with -ve numbers

    IF lstr(k) LE 4 THEN $
      STRPUT, ostr, str(k), 7-lstr(k) $
    ELSE $
      STRPUT, ostr, STRMID(str(k),lstr(k)-4,4), 3

    output_str = output_str + ostr

  ENDFOR

  ; chop off leading blank

  RETURN, STRMID ( output_str, 1, STRLEN(output_str)-1 )

END

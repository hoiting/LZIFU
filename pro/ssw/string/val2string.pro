;---------------------------------------------------------------------------
; Document name: val2string.pro
; Created by:    Andre_Csillaghy, October 30, 2002
;
; Last Modified: Wed Nov  6 10:56:25 2002 (csillag@soleil.cs.fh-aargau.ch)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       VAL2STRING()
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       result = val2string(value)
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURE:
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLES:
;
;
; SEE ALSO:
;
; HISTORY:
;       Version 1, October 30, 2002,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
; MODIFICATIONS:
;       1-Jan-2004, Kim Tolbert as follows:
;         1. Previously handled arrays wrong - e.g. for 9,3 array, it returned 3,9. Added
;            recurse arg.  On first call, if value is an array, it will be transposed.  On
;            recursive calls the recurse arg is passed, so it won't be transposed.
;         2. Changed name of first argument so if we transpose it, the changed value doesn't
;            get back to user.
;         3. For Double values, previously returned e.g. 1.e001D, so check for e and
;            substitute d instead of appending
;         4. Return 'BAD' as value (or array of 'BAD's) if couldn't convert to string
;-
;

; Note: recurse argument only for use internally on recursive calls
FUNCTION val2string, value, recurse

val = value

dim = Size( val, /n_dim )
IF dim gt 0 AND n_elements( val ) EQ 1 THEN BEGIN
    val = val[0]
    dim = 0
ENDIF

IF dim GT 0 THEN BEGIN
; this is becaus stupid idl considers differently scalars and arrays
; with 1 elements

	; if 2nd arg present, this is a recursive call so don't transpose array
	if dim gt 1 and not exist(recurse) then val = transpose(value)

    this_val = '['
    FOR i=0, N_elements( val[*, 0] )-2 DO BEGIN
		this_val = this_val + val2string( reform( val[i, *,*,*,*,*,*] ), 1 )  + ', '
    ENDFOR
    this_val = this_val + val2string( reform( val[i,*,*,*,*,*,*,*] ), 1 ) + ']'
ENDIF ELSE BEGIN
	this_val = 'BAD'
    CASE Size( val, /type ) OF
        1: this_val = Strtrim( Fix( val ) , 2  ) + 'B'
        2: this_val = Strtrim( val, 2 )
        3: this_val = Strtrim( val, 2 ) + 'L'
        4: this_val = Strtrim( val, 2 )
        5: begin
            this_val = strlowcase(strtrim( val, 2 ))
            if strpos(this_val,'e') eq -1 then this_val = this_val + 'D' else $
        	    this_val=repchar(this_val, 'e','d')
           end
        6: message, 'Complex datatype not supported yet', /cont
        7: this_val =  "'" + val + "'"
        12: this_val = Strtrim( val, 2 ) + 'U'
        14: this_val = Strtrim( val, 2 ) + 'UL'
        ELSE: message, 'Datatype > 7 except 12,14 not supported yet', /cont
    ENDCASE
ENDELSE
RETURN, this_val
END


;---------------------------------------------------------------------------
; End of 'val2string.pro'.
;---------------------------------------------------------------------------

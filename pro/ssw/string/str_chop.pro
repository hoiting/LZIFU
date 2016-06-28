;---------------------------------------------------------------------------
; Document name: str_chop.pro
; Created by:    Liyun Wang, GSFC/ARC, January 20, 1995
;
; Last Modified: Mon Apr 10 10:32:23 1995 (lwang@orpheus.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION STR_CHOP, strings, substr
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       STR_CHOP()
;
; PURPOSE:
;       Chop off a substring from a string scalar or vector
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = STR_CHOP(strings, substr)
;
; INPUTS:
;       STRINGS - String scalar or vector from which a substring is chopped
;       SUBSTR  - Substring to be chopped from STRINGS
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - A new string scalar or vector in which STRSUB has been
;                removed from each of its elements.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       GREP, DATATYPE, STR_SEP, ARR2STR
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written January 20, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, January 20, 1995
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 2 THEN BEGIN
      MESSAGE, 'Syntax: result = str_chop(strings, substr)'
   ENDIF
   IF datatype(strings) NE 'STR' OR datatype(substr) NE 'STR' THEN BEGIN
      PRINT, 'Input parameters must be string type.'
      RETURN, -1
   ENDIF
   aa = strings
   bb = grep(substr,aa,index = idx)
   IF bb(0) EQ '' THEN RETURN, aa
   FOR i = 0, N_ELEMENTS(bb)-1 DO BEGIN
      temp = str_sep(bb(i),substr)
      bb(i) = arr2str(temp,'')
   ENDFOR
   aa(idx) = bb(idx)
   RETURN, aa
END

;---------------------------------------------------------------------------
; End of 'str_chop.pro'.
;---------------------------------------------------------------------------

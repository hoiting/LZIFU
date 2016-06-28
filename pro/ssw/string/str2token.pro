;---------------------------------------------------------------------------
; Document name: STR2TOKEN.PRO
; Created by:    Liyun Wang, NASA/GSFC, February 5, 1997
;
; Last Modified: Mon Feb 10 09:46:50 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION str2token, str, error=error, dot=dot, exclamation=exclamation
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       STR2TOKEN()
;
; PURPOSE:
;       Convert a string into an array of tokens
;
; CATEGORY:
;       String, utility
;
; EXPLANATION:
;       A token is defined as an entity which is composed of only alphabetic
;       and numerical letters plus the underscore sign ("_").
;
; SYNTAX:
;       Result = str2token(str)
;
; EXAMPLES:
;       IDL> token = str2token('STRTRIM(STRCOMPRESS(STRING(bstr)), 2)')
;       IDL> help, token
;       <Expression>    STRING    = Array(5)
;       IDL> print, token
;       STRTRIM  STRCOMPRESS  STRING  bstr  2
;       IDL>
;
; INPUTS:
;       STR - String scalar to be examined
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - String array containing tokens in STR; the null string is
;                returned if an error occurrs
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       ERROR - String containing possible error message; the null string is
;               returned if no error
;       DOT   - Set this keyword to allow structure type token
;       EXCLAMATION - Set this keyword to allow system variable
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, February 5, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, February 10, 1997, Liyun Wang, NASA/GSFC
;          Added DOT and EXCLAMATION keyword
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 1
   error = ''
   IF N_ELEMENTS(str) EQ 0 THEN sz = [0,0] ELSE sz = SIZE(str)

   IF sz(sz(0)+1) NE 7 THEN BEGIN
      error = 'Input parameter must be a string.'
      MESSAGE, error, /cont
      RETURN, ''
   ENDIF

   tmp = str

   bstr = BYTARR(STRLEN(tmp))
   mask = 1B+bstr

   bstr = BYTE(tmp)

   ii = WHERE((bstr LT 47B) OR (bstr GT 122B) OR (bstr EQ 96B) OR $
              (bstr GT 57B AND bstr LT 65B) OR $
              (bstr GT 91B AND bstr LT 94B), count)
   IF count NE 0 THEN mask(ii) = 0b

   IF KEYWORD_SET(dot) THEN BEGIN
;---------------------------------------------------------------------------
;     Allow structure type token
;---------------------------------------------------------------------------
      ii = WHERE(bstr EQ 46B, count)
      IF count GT 0 THEN BEGIN
         FOR i = 0, count-1 DO BEGIN
            left = ii(i)-1 > 0
            rite = ii(i)+1 < (N_ELEMENTS(mask)-1)
            IF mask(left)*mask(rite) EQ 1B THEN mask(ii(i)) = 1B
         ENDFOR
      ENDIF
   ENDIF

   IF KEYWORD_SET(exclamation) THEN BEGIN
;---------------------------------------------------------------------------
;     Allow system variable as token
;---------------------------------------------------------------------------
      ii = WHERE(bstr EQ 33B, count)
      IF count GT 0 THEN BEGIN
         FOR i=0, count-1 DO BEGIN
            rite = ii(i)+1 < (N_ELEMENTS(mask)-1)
            IF mask(rite) EQ 1B THEN mask(ii(i)) = 1B
         ENDFOR
      ENDIF
   ENDIF

   ii = WHERE(mask NE 1b, count)
   IF count EQ 0 THEN RETURN, str

   bstr(ii) = 32B
   tmp = STRTRIM(STRCOMPRESS(STRING(bstr)),2)
   bstr = BYTE(tmp)

   ii = WHERE(bstr EQ 32B, count)
   IF count EQ 0 THEN RETURN, tmp

   offset = 0
   token = ''
   FOR i=0, N_ELEMENTS(ii)-1 DO BEGIN
      token = [token, STRING(bstr(offset:ii(i)-1))]
      offset = ii(i)
   ENDFOR
   IF offset LT STRLEN(tmp)-1 THEN token = [token, STRING(bstr(offset:*))]
   token = token(1:*)

   RETURN, token
END

;---------------------------------------------------------------------------
; End of 'STR2TOKEN.PRO'.
;---------------------------------------------------------------------------

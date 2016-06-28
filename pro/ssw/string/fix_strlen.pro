;---------------------------------------------------------------------------
; Document name: fix_strlen.pro
; Created by:    Liyun Wang, NASA/GSFC, January 25, 1995
;
; Last Modified: Wed Jan 25 09:23:52 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION FIX_STRLEN, str, length, prefix=prefix
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       FIX_STRLEN()
;
; PURPOSE:
;       Make a string have a fixed length by appending spaces.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = fix_strlen(str, length=length)
;
; INPUTS:
;       STR    - String to be padded
;       LENGTH - Desired length of resulting str
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
; KEYWORD PARAMETERS:
;       PREFIX - Padding spaces in front of the given string if set
;
; CALLS:
;       None.
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
;       Written January 25, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, January 25, 1995
;
; VERSION:
;       Version 1, January 25, 1995
;-
;
   ON_ERROR, 2
   IF datatype(str) NE 'STR' THEN MESSAGE,'Argument has to be string type.'
   IF N_ELEMENTS(length) EQ 0 THEN BEGIN
      PRINT, 'FIX_STRLEN - Warning: Desired string length not specified.'
      RETURN, str
   ENDIF
   blank = '                                                              '
   aa = STRTRIM(str,2)
   IF STRLEN(aa) GE length THEN RETURN, str
   IF KEYWORD_SET(prefix) THEN BEGIN
      bb = STRMID(blank,0,length-STRLEN(aa))+aa
   ENDIF ELSE BEGIN
      bb = aa+STRMID(blank,0,length-STRLEN(aa))
   ENDELSE
   RETURN, bb
END

;---------------------------------------------------------------------------
; End of 'fix_strlen.pro'.
;---------------------------------------------------------------------------

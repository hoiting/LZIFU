;---------------------------------------------------------------------------
; Document name: str2lines.pro
; Created by:    Liyun Wang, GSFC/ARC, January 25, 1996
;
; Last Modified: Fri Jan 26 22:38:34 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION str2lines, str_in, length=length, reverse=reverse, $
                    warning=warning, just_code=just_code
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       STR2LINES()
;
; PURPOSE:
;       Convert a string into a series lines (string array) at certain length
;
; CATEGORY:
;       Utility
;
; SYNTAX:
;       Result = str2lines(str)
;
; INPUTS:
;       STR - String to be converted
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
;       LENGTH    - Maximum length of output string array elements
;                   (defaults to 72)
;       REVERSE   - Set this keyword to convert sentences to a long string
;       WARNING   - Contains warning message (if any returned line is
;                   longer than LENGTH)
;       JUST_CODE - String scalar, code of justification:
;            '<':  left justification  (this is default)
;            '>':  right justification
;            '|':  center justified
;            '||': full justification (not implemented)
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       Retured string array is compressed (with all whitespace
;       [blanks and tabs] compressed to a single space)
;
; HISTORY:
;       Version 1, January 25, 1996, Liyun Wang, GSFC/ARC. Written
;       24-Jan-2002, Kim Tolbert.  Corrected bug in STRMID call
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2

   warning = ''

   IF KEYWORD_SET(reverse) THEN BEGIN
      num = N_ELEMENTS(str_in)
      temp = ''
      FOR i=0,num-1 DO temp = temp+str_in(i)+' '
      RETURN, STRTRIM(STRCOMPRESS(temp),2)
   ENDIF

   IF datatype(str_in) NE 'STR' THEN RETURN, ''
   IF N_ELEMENTS(length) EQ 0 THEN length = 72
   IF STRLEN(str_in) LE length THEN RETURN, str_in
   IF datatype(just_code) NE 'STR' THEN just_code = '<'

   str = STRCOMPRESS(str_in)
   maxlen = STRLEN(str)
   ok = 1 & off = 0
;---------------------------------------------------------------------------
;  Find indices of white spaces
;---------------------------------------------------------------------------
   WHILE (ok GT 0) DO BEGIN
      ii = STRPOS(str, ' ', off)
      IF ii GE 0 THEN BEGIN
         IF N_ELEMENTS(idx) EQ 0 THEN idx = ii ELSE idx = [idx, ii]
         off = ii+1
      ENDIF ELSE ok = 0
   ENDWHILE

   num = N_ELEMENTS(idx)
   IF num EQ 0 THEN RETURN, str

   off = 0
   line = ''
   IF num GE 2 THEN BEGIN
      FOR i=0, num-2 DO BEGIN
         span = idx(i+1)-off
         IF span GT length THEN BEGIN
            line = [line, STRMID(str, off, idx(i)-off)]
            off = idx(i)+1
         ENDIF
      ENDFOR
      str = STRMID(str,off,maxlen)	; corrected 1/24/2002, Kim. Was STRMID(str_in...
      idx = idx(num-1)-off
      off = 0
   ENDIF
   span = idx(0)-off
   IF STRLEN(str) GT length THEN BEGIN
      line = [line, STRMID(str, off, span)]
      line = [line, STRMID(str, span+1, maxlen)]
   ENDIF ELSE BEGIN
      line = [line, str]
   ENDELSE
   line = line(1:*)

   summary = STRLEN(line)
   ii = WHERE(summary GT length)
   IF ii(0) GE 0 THEN warning = 'Found word(s) with length greater than '+$
      STRTRIM(STRING(length),2)
   IF just_code NE '<' THEN line = justify(line, just=just_code, $
                                           max_length=length)
   RETURN, line
END

;---------------------------------------------------------------------------
; End of 'str2lines.pro'.
;---------------------------------------------------------------------------

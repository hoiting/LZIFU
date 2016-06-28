;---------------------------------------------------------------------------
; Document name: justify.pro
; Created by:    Liyun Wang, GSFC/ARC, April 10, 1995
;
; Last Modified: Fri Jan 26 22:35:52 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION justify, strings, max_length=max_length, just_code=just_code
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       JUSTIFY()
;
; PURPOSE:
;       Make string array right/left/center justified
;
; EXPLANATION:
;       This routine adds necessary space in front of each element of a string
;       array to make the string array right/left/center justified.
;
; CALLING SEQUENCE:
;       Result = justify(strings)
;
; INPUTS:
;       STRINGS - A string array
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
;       JUST_CODE  - String scalar, code of justification: 
;            '<':  left justification  (this is default)
;            '>':  right justification
;            '|':  center justified
;            '||': full justification (not implemented)
;
;       MAX_LENGTH - Maximum length of resultant string. If present, the
;                    actual maximum length of RESULT will be either
;                    MAX_LENGTH or maximum length in STRINGS, whichever is
;                    larger. 
; CALLS:
;       BLANK
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
;       Written April 10, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, April 10, 1995
;       Version 2, January 26, 1996, Liyun Wang, GSFC/ARC
;          Removed keywords LEFT, CENTER, RIGHT; added keyword JUST_CODE
;
; VERSION:
;       Version 2, January 26, 1996
;-
;
   ON_ERROR, 2
   IF datatype(strings) NE 'STR' THEN BEGIN
      MESSAGE, 'Argument must be of striung type.',/cont
      RETURN, -1
   ENDIF

   IF N_ELEMENTS(just_code) EQ 0 THEN just_code = '<'

   max_strlen = MAX(STRLEN(strings))
   IF N_ELEMENTS(max_length) NE 0 THEN max_strlen = (max_strlen > max_length)

   n_str = N_ELEMENTS(strings)
   nstrings = strings

   CASE (just_code) OF
      '>': BEGIN
         FOR i=0, n_str-1 DO BEGIN
            str_tmp = STRTRIM(strings(i), 2)
            nstrings(i) = blank(max_strlen-STRLEN(str_tmp))+str_tmp
         ENDFOR
      END
      '|': BEGIN
         FOR i=0, n_str-1 DO BEGIN
            str_tmp = STRTRIM(strings(i), 2)
            nstrings(i) = blank((max_strlen-STRLEN(str_tmp))/2)+str_tmp
         ENDFOR
      END 
      ELSE: BEGIN
         nstrings = STRTRIM(strings, 1)
      END
   ENDCASE
   
   RETURN, nstrings
END

;---------------------------------------------------------------------------
; End of 'justify.pro'.
;---------------------------------------------------------------------------

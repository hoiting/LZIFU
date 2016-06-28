;---------------------------------------------------------------------------
; Document name: fix_strlen.pro
; Created by:    Liyun Wang, NASA/GSFC, January 25, 1995
;
; Last Modified: Wed Jan 25 09:23:52 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION FIX_STRLEN_ARR, str, length, prefix=prefix, center=center
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       FIX_STRLEN_ARR()
;
; PURPOSE:
;       Make a string have a fixed length by appending spaces.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = fix_strlen_arr(str, length)
;
; INPUTS:
;       STR    - String to be padded (may be an array of strings)
;       LENGTH - Desired length of resulting str (must be scalar)
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
;       CENTER - If set, center text, pad with spaces before and after
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
;       Kim Tolbert, 11/26/2000 - Modified fix_strlen to handle input
;          string arrays and renamed to fix_strlen_arr.
;       Kim Tolbert, 27-Jan-2002, Added center keyword
;       Kim Tolbert, Make loop index long
;
;-
;
   ON_ERROR, 2
   IF datatype(str) NE 'STR' THEN MESSAGE,'Argument has to be string type.'
   IF N_ELEMENTS(length) EQ 0 THEN BEGIN
      PRINT, 'FIX_STRLEN_ARR - Warning: Desired string length not specified.'
      RETURN, str
   ENDIF

   num = n_elements(str)
   retval = strarr(num)

   blank = '                                                              '
   for i = 0L, num-1 do begin
   	 aa = STRTRIM(str[i],2)
   	 IF STRLEN(aa) GE length THEN retval[i] = strmid(str[i], 0, length) else begin
       case 1 of
          KEYWORD_SET(prefix): bb = STRMID(blank,0,length-STRLEN(aa))+aa
          KEYWORD_SET(center): begin
             nbefore = (length - STRLEN(aa) ) /2
             nafter = length - nbefore - STRLEN(aa)
             bb = STRMID(blank, 0, nbefore) + aa + STRMID(blank, 0, nafter)
             END
          ELSE: bb = aa+STRMID(blank,0,length-STRLEN(aa))
       ENDCASE
       retval[i] = bb
     endelse
   endfor
   RETURN, retval
END

;---------------------------------------------------------------------------
; End of 'fix_strlen_arr.pro'.
;---------------------------------------------------------------------------

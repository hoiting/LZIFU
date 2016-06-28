;---------------------------------------------------------------------------
; Document name: blank.pro
; Created by:    Liyun Wang, GSFC/ARC, April 12, 1995
;
; Last Modified: Wed Apr 12 12:11:19 1995 (lwang@orpheus.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION blank, length
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       BLANK()
;
; PURPOSE:
;       To make a blank string with a given length
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = blank(length)
;
; INPUTS:
;       LENGTH - length of resultant string; if missing a null string is
;                returned 
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
;       None.
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
;       Util, string
;
; PREVIOUS HISTORY:
;       Written April 12, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, April 12, 1995
;
; VERSION:
;       Version 1, April 12, 1995
;-
;
   ON_ERROR, 2
   temp = ''
   IF N_ELEMENTS(length) EQ 0 THEN RETURN,temp
   RETURN, STRING(temp,FORMAT='(a'+STRTRIM(FIX(length),2)+')')
END

;---------------------------------------------------------------------------
; End of 'blank.pro'.
;---------------------------------------------------------------------------

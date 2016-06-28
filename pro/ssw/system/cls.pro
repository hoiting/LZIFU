;----------------------------------------------------------------------
; Document name: cls.pro
; Created by:    Liyun Wang, GSFC/ARC, December 29, 1994
;
; Last Modified: Thu Dec 29 11:04:30 1994 (lwang@orpheus.nascom.nasa.gov)
;----------------------------------------------------------------------
;
PRO CLS, bottom=bottom
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       CLS
;
; PURPOSE: 
;       Clear screen (in Xterm's VT102 mode)
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       CLS 
;
; INPUTS:
;       None.
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
;       BOTTOM -- Keep cursor at the bottom line if set.
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
;       Utility, miscellaneous
;
; PREVIOUS HISTORY:
;       Written December 29, 1994, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, December 29, 1994
;-
;
   esc = STRING(27b)
   IF KEYWORD_SET(bottom) THEN $
      PRINT, FORMAT = '(a,$)', esc+'[2J' $
   ELSE $
      PRINT, FORMAT = '(a,$)', esc+'[2J'+esc+'[f' 
END

;----------------------------------------------------------------------
; End of 'cls.pro'.
;----------------------------------------------------------------------

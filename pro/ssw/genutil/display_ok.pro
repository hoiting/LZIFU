;---------------------------------------------------------------------------
; Document name: DISPLAY_OK.PRO
; Created by:    Liyun Wang, NASA/GSFC, December 1, 1996
;
; Last Modified: Sun Dec  1 16:35:12 1996 (LWANG@sumop1.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION display_ok
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       DISPLAY_OK()
;
; PURPOSE: 
;       Detect if device display has been set properly
;
; CATEGORY:
;       
; 
; EXPLANATION:
;       
; SYNTAX: 
;       Result = display_ok()
;
; EXAMPLES:
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
;       Version 1, December 1, 1996, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   CASE (!version.os) OF
      'vms': IF GETENV('DECW$DISPLAY') NE '' THEN RETURN, 1
      'windows': RETURN, 1
      'MacOS': RETURN, 1
      ELSE: IF GETENV('DISPLAY') NE '' THEN RETURN, 1
   ENDCASE
   RETURN, 0
END


;---------------------------------------------------------------------------
; End of 'DISPLAY_OK.PRO'.
;---------------------------------------------------------------------------

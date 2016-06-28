;---------------------------------------------------------------------------
; Document name: LIST_PRINTER_VMS.PRO
; Created by:    Liyun Wang, NASA/GSFC, September 20, 1996
;
; Last Modified: Fri Sep 20 18:19:31 1996 (LWANG@sumop1.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION list_printer_vms, desc, reset=reset, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       LIST_PRINTER_VMS()
;
; PURPOSE:
;       List names of all printer queues
;
; CATEGORY:
;       Utility
;
; SYNTAX:
;       Result = list_printer_vms()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - String array containing printer queue names
;
; OPTIONAL OUTPUTS:
;       DESC - Description of printers listed
;
; KEYWORDS:
;       RESET - Force to make a printer list if set
;       ERROR - String containing possible error message; if no error occurs,
;               the null string is returned
;
; COMMON:
;       pname4vms - Internal common block
;
; RESTRICTIONS:
;       Only work on VMS system
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 20, 1996, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   COMMON pname4vms, printer, descript
   
   error = ''
   IF N_ELEMENTS(printer) EQ 0 OR KEYWORD_SET(reset) THEN BEGIN
      SPAWN, 'show queue /device=printer/brief', out, /noclisym, /nolognam
   ENDIF ELSE BEGIN
      desc = descript
      RETURN, printer
   ENDELSE

   ii = WHERE(STRTRIM(out) NE '')
   IF ii(0) GE 0 THEN out = STRTRIM(out(ii))
   printer = ''
   desc = ''
   FOR i=0, N_ELEMENTS(out)-1 DO BEGIN
      a = out(i)
      j = STRPOS(a, ',')
      printer = [printer, STRMID(a, 14, j-14)]
      b = STRMID(a, j+1, 2000)
      j = STRPOS(b, ',')
      desc = [desc, STRMID(b, j+1, 2000)]
   ENDFOR
   IF N_ELEMENTS(printer) GT 1 THEN BEGIN
      printer = STRTRIM(printer(1:*),2)
      desc = STRTRIM(desc(1:*),2)
   ENDIF
   descript = desc
   RETURN, printer
END

;---------------------------------------------------------------------------
; End of 'LIST_PRINTER_VMS.PRO'.
;---------------------------------------------------------------------------

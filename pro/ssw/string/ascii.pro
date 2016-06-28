;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ascii.pro
; Created by:    Liyun Wang, GSFC/ARC, September 12, 1994
;
; Last Modified: Thu Sep 22 14:39:02 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO ASCII, ext=ext
;+
; NAME:
;       ASCII
;
; PURPOSE: 
;       Print ASCII characters based on its numerical decimal value.
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       ASCII [,/ext]
;
; INPUTS:
;       None.
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
;       EXT -- Prints only extended ASCII characters.
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
; MODIFICATION HISTORY:
;       Written September 12, 1994, by Liyun Wang, GSFC/ARC
;       
; VERSION: Version 1, September 12, 1994
;-
;
   IF KEYWORD_SET(ext) THEN BEGIN
      FOR i = 1, 16 DO BEGIN
         PRINT, FORMAT = '(3x,8(i3.3,a3,3x))', $
            i+127,': '+STRING(BYTE(i+127)), $
            i+143,': '+STRING(BYTE(i+143)), $
            i+159,': '+STRING(BYTE(i+159)), $
            i+175,': '+STRING(BYTE(i+175)), $
            i+191,': '+STRING(BYTE(i+191)), $
            i+207,': '+STRING(BYTE(i+207)), $
            i+223,': '+STRING(BYTE(i+223)), $
            i+239,': '+STRING(BYTE(i+239))
      ENDFOR
   ENDIF ELSE BEGIN
      FOR i = 1, 28 DO BEGIN
         PRINT, FORMAT = '(3x,8(i3.3,a3,3x))', $
            i+31, ': '+STRING(BYTE(i+31)),$
            i+59, ': '+STRING(BYTE(i+59)),$
            i+87, ': '+STRING(BYTE(i+87)),$
            i+115,': '+STRING(BYTE(i+115)),$
            i+143,': '+STRING(BYTE(i+143)),$
            i+171,': '+STRING(BYTE(i+171)),$
            i+199,': '+STRING(BYTE(i+199)),$
            i+227,': '+STRING(BYTE(i+227))
      ENDFOR
   ENDELSE
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ascii.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

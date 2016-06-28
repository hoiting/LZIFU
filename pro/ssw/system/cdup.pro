;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: cdup.pro
; Created by:    Liyun Wang, GSFC/ARC, October 6, 1994
;
; Last Modified: Wed Jan 11 16:06:09 1995 (lwang@achilles.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO CDUP, simple=simple
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       CDUP
;
; PURPOSE: 
;       Change directory path to an upper level
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       CDUP
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
;       SIMPLE -- If set, the IDL prompt is not changed.
;
; CALLS:
;       CDD
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
;       Written October 6, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 6, 1994
;-
;
   IF KEYWORD_SET(simple) THEN BEGIN
      IF !version.os EQ 'vms' THEN cd, '[-]' ELSE $
         cd, '..'
   ENDIF ELSE BEGIN
      IF !version.os EQ 'vms' THEN BEGIN 
         cd, current=curr
         lquote = STRPOS(curr,'[')
         idx = str_index(curr,'.')
         IF idx(0) EQ -1 THEN BEGIN
            up_dir = STRMID(curr,0,lquote+1)+'000000]'
         ENDIF ELSE BEGIN 
            n_idx = N_ELEMENTS(idx)
            up_dir = STRMID(curr,0,idx(n_idx-1))+']'
         ENDELSE
         cdd, up_dir
      ENDIF ELSE cdd, '..'
   ENDELSE
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'cdup.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;---------------------------------------------------------------------------
; Document name: dd.pro
; Created by:    Liyun Wang, GSFC/ARC, January 10, 1995
;
; Last Modified: Fri Feb  3 16:04:06 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO DD
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       DD
;
; PURPOSE: 
;       Display directory stack used by PD and PPD
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       DD
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
;       None.
;
; CALLS:
;       CDD
;
; COMMON BLOCKS:
;	DIR_STACK:  Contains the directory stack.
;       CDD:        Common block used by CDD.
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
;       Written January 10, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, GSFC/ARC, February 3, 1995
;          Renamed from SD to DD
;
; VERSION:
;       Version 2, February 3, 1995
;-
;
   ON_ERROR, 2
   COMMON stack_dir, stack 
   COMMON cdd, home_dir, home_len, idl_path, diskname
   n_stack = N_ELEMENTS(stack) 
   cdd, current = cur_dir
   cdd, cur_dir
   IF !version.os EQ 'vms' THEN BEGIN
      aa = STRPOS(cur_dir,STRMID(home_dir,0,home_len-1))
      IF aa EQ 0 THEN BEGIN
         cur_dir = '[~'+STRMID(cur_dir,home_len-1,2000)
      ENDIF ELSE BEGIN
         IF STRPOS(cur_dir,diskname) EQ 0 THEN $
            cur_dir = STRMID(cur_dir,STRPOS(cur_dir,':')+1,2000) 
      ENDELSE
   ENDIF
   IF n_stack EQ 0 THEN PRINT, cur_dir ELSE PRINT, cur_dir, stack
END

;---------------------------------------------------------------------------
; End of 'dd.pro'.
;---------------------------------------------------------------------------

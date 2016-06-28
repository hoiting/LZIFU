;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: rm_path.pro
; Created by:    Liyun Wang, GSFC/ARC, October 7, 1994
;
; Last Modified: Mon Apr 10 10:32:01 1995 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO RM_PATH, path_name, expand=expand, index=index
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       RM_PATH
;
; PURPOSE: 
;       Remove directory (and optionally its subdirs) from IDL path
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       RM_PATH, path_name [,/expand] [index=index]
;
; INPUTS:
;       PATH_NAME -- A string scalar containing directory name to be
;                    removed
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None. !path may be changed though.
;
; OPTIONAL OUTPUTS:
;       INDEX -- Index of the removed directory in the !path.
;
; KEYWORD PARAMETERS: 
;       EXPAND -- Set this keyword to remove all subdirectories under
;                 PATH_NAME from the IDL path.
;
; CALLS:
;       STR_SEP, ARR2STR, REST_MASK, DATATYPE, OS_FAMILY
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
;       Utilities, OS
;       
; PREVIOUS HISTORY:
;       Written October 7, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, GSFC/ARC, October 19, 1994
;          Added the EXPAND keyword
;	Version 3, William Thompson, GSFC, 29-Aug-1995
;		Changed to use OS_FAMILY
;
; VERSION:
;       Version 3, 29-Aug-1995
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(path_name) EQ 0 THEN MESSAGE, $
      'Syntax: RM_PATH, path_name.'
   
   IF datatype(path_name) NE 'STR' THEN MESSAGE, $
         'The input parameter has to be of string type.'

   max_len = 20000

   CASE OS_FAMILY() OF
      'vms': delimit = ',' 
      'Windows': delimit = ';'
      ELSE: BEGIN
         delimit = ':'
         IF STRMID(path_name,0,2) EQ '~/' THEN $
            path_name = getenv('HOME')+STRMID(path_name,1,max_len)
      END
   ENDCASE

   dir_names = str_sep(!path, delimit)

   IF KEYWORD_SET(expand) THEN BEGIN
      p_name = expand_path('+'+path_name)
   ENDIF ELSE p_name = path_name
   IF p_name NE '' THEN path_name = str_sep(p_name,delimit)

   IF N_ELEMENTS(index) NE 0 THEN delvarx, index
   FOR i = 0, N_ELEMENTS(path_name)-1 DO BEGIN
      id = WHERE(dir_names EQ path_name(i))
      IF id(0) EQ -1 THEN BEGIN
         PRINT, 'RM_PATH: '+path_name(i)+' is NOT in IDL !path.'
      ENDIF ELSE BEGIN
         PRINT, path_name(i)+' removed from the IDL path.'
         IF N_ELEMENTS(index) EQ 0 THEN index = id ELSE $
            index = [index, id]
      ENDELSE
   ENDFOR
   IF N_ELEMENTS(index) EQ 0 THEN RETURN
   
   idd = rest_mask(dir_names, index)
   !path = arr2str(dir_names(idd),delimit)

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'rm_path.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

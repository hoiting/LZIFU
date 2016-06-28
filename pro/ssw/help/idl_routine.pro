;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: idl_routine.pro
; Created by:    Liyun Wang, GSFC/ARC, September 21, 1994
;
; Last Modified: Thu Dec 15 15:18:16 1994 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO IDL_ROUTINE, routine_names ;, hardcopy=hardcopy
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       IDL_ROUTINE
;
; PURPOSE:
;       Create a string array of names of all IDL internal routines
;
; EXPLANATION:
;       Called by WHICH (version 3)
;
; CALLING SEQUENCE:
;       IDL_ROUTINE, routine_names
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       ROUTINE_NAMES -- A string array containing names of all IDL internal
;                        routines
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       CONCAT_DIR, DELVARX
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       A text file named 'idl.routines' must be present in a directory of
;       IDL's !path.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written September 21, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1, September 21, 1994
;-
;
   ON_ERROR, 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Search for the text file 'idl.routines'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   p = !path
   IF !version.os EQ 'vms' THEN dirs =  str_sep(p,',') ELSE $
      dirs = str_sep(p,':')
   
   FOR i = 0,N_ELEMENTS(dirs)-1 DO BEGIN
      filename = concat_dir(dirs(i),'idl.routines')
      OPENR, unit, filename, /GET_LUN, error=rr
      IF rr EQ 0 THEN BEGIN
         strings = ''
         IF N_ELEMENTS(routine_names) NE 0 THEN delvarx, routine_names
         REPEAT BEGIN
            READF, unit, strings
            IF N_ELEMENTS(routine_names) EQ 0 THEN $
               routine_names = str_sep(STRCOMPRESS(strings),' ') $
            ELSE $
               routine_names = [routine_names, $
                                str_sep(STRCOMPRESS(strings),' ')]
         ENDREP UNTIL EOF(unit)
         CLOSE, unit &  FREE_LUN, unit
         RETURN
      ENDIF
   ENDFOR
   PRINT, 'Cannot find file idl.routines.'
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'idl_routine.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: strip_dirname.pro
; Created by:    Liyun Wang, GSFC/ARC, September 19, 1994
;
; Last Modified: Wed Oct 19 11:20:45 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION STRIP_DIRNAME, full_names, path=path
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       STRIP_DIRNAME()
;
; PURPOSE: 
;       Strip off directory name associated with filenames.
;
; EXPLANATION:
;       Given a string array containing full filenames (including
;       directory paths), this routine will strip off directory names
;       and return only the file names.
;
; CALLING SEQUENCE: 
;       Results = STRIP_DIRNAME(full_names [,path=path])
;
; INPUTS:
;       FULL_NAMES -- String array containing full names of files
;                     including directory paths.
;   
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Results -- String array in which directory paths have beeb
;                  stripped off from the full filename.
;
; OPTIONAL OUTPUTS:
;       PATH -- An optional return variable that contains the stripped path
;               string of the file names.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       OS_FAMILY
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
;       Utilities, os
;
; PREVIOUS HISTORY:
;       Written September 19, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Liyun Wang, GSFC/ARC, September 20, 1994
;          Added the PATH keyword.
;	Version 2, 29-Aug-1995, William Thompson, GSFC
;		Changed to use OS_FAMILY
;       Version 3, 09-Jan-2006, William Thompson, GSFC
;               Made FOR loop long integer
;       
; VERSION: 
;       Version 3, 09-Jan-2006
;       
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 1 THEN BEGIN
      PRINT, 'STRIP_DIRNAME -- Syntax error.'
      PRINT, '   Usage: Results = STRIP_DIRNAME(full_names)'
      PRINT, ' '
      RETURN, -1
   ENDIF
   IF datatype(full_names) NE 'STR' THEN $
      MESSAGE, 'Input parameter must be of string type.'
   
   new_files = full_names
   path = full_names

   CASE OS_FAMILY() OF
      'vms': delimit = ']'
      'Windows': delimit = '\'
      ELSE: delimit = '/'
   ENDCASE 

   FOR i = 0L, N_ELEMENTS(full_names)-1 DO BEGIN
      slength = STRLEN(full_names(i))
      idx = rstrpos(full_names(i),delimit)
      new_files(i) = STRMID(full_names(i),idx+1,slength)
      path(i) = STRMID(full_names(i),0,idx+1)
   ENDFOR
   
   RETURN, new_files
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'strip_dirname.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

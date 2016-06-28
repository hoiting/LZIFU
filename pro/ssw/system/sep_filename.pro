;----------------------------------------------------------------------
; Document name: sep_filename.pro
; Created by:    Liyun Wang, NASA/GSFC, December 12, 1994
;
; Last Modified: Mon Dec 12 11:24:48 1994 (lwang@orpheus.nascom.nasa.gov)
;----------------------------------------------------------------------
;
PRO SEP_FILENAME, file, disk_log, dir, filnam, ext, fversion, node
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       SEP_FILENAME
;
; PURPOSE:
;       Separates a filename into its component parts.
;
; EXPLANATION:
;       Given a file name, break the filename into the parts of disk/logical,
;       the directory, the filename, the extension, and the file version
;       (for VMS). The difference of this routine from break_file are:
;       1) It handles only one filename (instead of an array); 2) file
;       extention will not include the "." character, and it may be a
;       string array if the file extension can be further broken into more
;       parts (separated by the "." character).
;
; CALLING SEQUENCE:
;       SEP_FILENAME, file, disk_log, dir, filnam, ext, fversion, node
;
; INPUTS:
;       FILE    - The file name
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       DISK_LOG- The disk or logical (looks for a ":")
;                 This is generally only valid on VMS machines
;       DIR     - The directory
;       FILNAM  - The filename (excluding the ".")
;       EXT     - The filename extension (NOT including the ".")
;       FVERSION- The file version (only VMS)
;       NODE    - The Node name (only VMS)
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
;
; PREVIOUS HISTORY:
;       Written December 12, 1994, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1, December 12, 1994
;-
;
   ON_ERROR, 2
   len=STRLEN(file)
   file0 = file

;----------------------------------------------------------------------
;  If node name presents, strip it off and then add it back later
;----------------------------------------------------------------------
   dcolon=STRPOS(file0,'::')
   IF dcolon GT -1 THEN BEGIN
      node=STRMID(file0,0,dcolon+2)
      file0=STRMID(file0,dcolon+2,1000)
   ENDIF

;----------------------------------------------------------------------
;  Get dir name
;----------------------------------------------------------------------
   IF (!version.os EQ 'vms') THEN BEGIN	;WTT changed 7-May-93
      p=STRPOS(file0,':')
      IF (p NE 1) THEN disk_log=STRMID(file0,0,p+1) ;includes :
      len=len-p+1
      file0=STRMID(file0, p+1, len)
      p=STRPOS(file0,']')
      IF (p NE -1) THEN dir=STRMID(file0,0,p+1) ;includes ]
      len=len-p+1
      file0=STRMID(file0, p+1, len)
   END ELSE IF !version.os EQ 'windows' THEN BEGIN
      p = STRPOS(file0,':')
      IF p NE -1 THEN BEGIN
         disk_log = STRMID(file0,0,p+1) ;Includes :
         len = len - p + 1
         file0 = STRMID(file0,p+1,len)
      ENDIF
      p = -1
      WHILE (STRPOS(file0,'\', p+1) NE -1) DO p = STRPOS(file0,'\',p+1)
      dir = STRMID(file0, 0, p+1)
      file0 = STRMID(file0, p+1, len-(p+1))
   END ELSE BEGIN
      p = -1                    ;WTT changed 7-May-93
      WHILE (STRPOS(file0,'/', p+1) NE -1) DO p = STRPOS(file0,'/',p+1)
      dir = STRMID(file0, 0, p+1)
      file0 = STRMID(file0, p+1, len-(p+1))
   END

;----------------------------------------------------------------------
;  Get file basename (not include ".")
;----------------------------------------------------------------------
   p=STRPOS(file0,'.')
   IF (p EQ -1) THEN BEGIN
      filnam = STRMID(file0,0,len)
      p=len
   END ELSE filnam = STRMID(file0,0,p) ;not include .
   len=len-p
   file0=STRMID(file0, p, len)

;----------------------------------------------------------------------
;  Get file extension (not include ".")
;----------------------------------------------------------------------
   p=STRPOS(file0,';')
   IF (p EQ -1) THEN BEGIN
      ext0 = STRMID(file0,1,len-1)
      p=len
   END ELSE ext0 = STRMID(file0,1,p-1) ; not include "." and ";"
   p1 = STRPOS(ext0,'.')
   IF (p1 EQ -1) THEN ext = ext0 ELSE BEGIN
      ext = str_sep(ext0,'.')
   ENDELSE

   len=len-p
   file0=STRMID(file0, p, len)

;----------------------------------------------------------------------
;  Get file version number
;----------------------------------------------------------------------
   fversion = ''
   IF (len NE 0) THEN fversion = file0

;----------------------------------------------------------------------
;  Now prefix disk name with node name
;----------------------------------------------------------------------
   IF N_ELEMENTS(node) NE 0 THEN disk_log=node+disk_log
END

;----------------------------------------------------------------------
; End of 'sep_filename.pro'.
;----------------------------------------------------------------------

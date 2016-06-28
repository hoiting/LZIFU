;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: peek.pro
; Created by:    Liyun Wang, GSFC/ARC, September 27, 1994
;
; Last Modified: Tue Jan  3 08:44:31 1995 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO PEEK, doc_name, extract=extract
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       PEEK
;
; PURPOSE:
;       Search and print IDL routine.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       PEEK, doc_name
;
; INPUTS:
;       DOC_NAME -- String scalar, name of the IDL routine
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
;       EXTRACT - If set, extract the document to current directory
;
; CALLS:
;       CONCAT_DIR, GET_MOD, GREP
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       Under VMS, if a paging command is to be used (rather than the default
;       "TYPE/PAGE" command), it has to be defined as a symbol with name
;       "page" and can take one argument.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Utility/Help
;
; PREVIOUS HISTORY:
;       Written September 27, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;      Liyun Wang, GSFC/ARC, October 5, 1994
;         Current directory also gets searched now.
;       Version 2, Liyun Wang, GSFC/ARC, December 6, 1994
;          Added the EXTRACT keyword
;       Version 3, Liyun Wang, GSFC/ARC, December 15, 1994
;          Made it work on VMS system
;       Version 4, Liyun Wang, GSFC/ARC, December 29, 1994
;          Use the environment variable (or symbol name under VMS) PAGE,
;             if defined, as the paging command  
;
; VERSION:
;       Version 4, December 29, 1994
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(doc_name) EQ 0 THEN BEGIN
      PRINT, 'PEEK -- Syntax error.'
      PRINT, '   Usage: PEEK, ''IDL_routine_name'''
      PRINT, ' '
      RETURN
   ENDIF
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  In case a file name with an extension is entered, strip off the
;  extension:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ipos =  STRPOS(doc_name,'.')
   IF (ipos NE -1) THEN doc_name = STRMID(doc_name,0,ipos)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Search for the routine first.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   CD, current = cur_dir
   IF !version.os EQ 'vms' THEN BEGIN
      path_sep = ','
      cp =  'copy/log/noconfirm'
      more = get_symbol('page')
      IF more EQ '' THEN more = 'type/page ' ELSE more = 'page '
   ENDIF ELSE IF !version.os EQ 'windows' THEN BEGIN
      path_sep = ':'
      cp =  'copy'
      more = 'type '
   ENDIF ELSE BEGIN
      path_sep = ':'
      cp = 'cp -f'
      more = getenv('PAGE')
      IF more EQ '' THEN more = 'more '
   ENDELSE
   p = cur_dir+path_sep+!path
   dirs = str_sep(p,path_sep)
   CASE (!version.os) OF
;----------------------------------------------------------------------
;     On VMS system, IDL_PATH can contain logical names and text library
;     which reguires GET_MOD and extracting files from the library
;----------------------------------------------------------------------
      'vms': BEGIN
         FOR i = 0, N_ELEMENTS(dirs)-1 DO BEGIN
            allfiles = get_mod(dirs(i))
            ff = grep(doc_name,allfiles)
            IF ff(0) NE '' THEN BEGIN
               IF (STRMID(dirs(i),0,1) NE '@') THEN BEGIN
                  filename = concat_dir(dirs(i),ff(0))
               ENDIF ELSE BEGIN
;----------------------------------------------------------------------
;           It must be on VMS machine and dirs(i) must be a text lib. 
;           In this case, we need to extract the text module out.
;----------------------------------------------------------------------
                  filename = 'sys$login:tmp_file.txt'
                  SPAWN, 'lib/extract=('+ff(0)+')/output='+filename+' '+$
                     STRMID(dirs(i),1,1000)
                  need_clean = 1
               ENDELSE
               IF KEYWORD_SET(extract) THEN BEGIN
                  target = concat_dir(cur_dir,doc_name+'.txt')
                  SPAWN, cp+' '+filename+' '+target
                  PRINT, 'Document saved as '+target+ '.'
               ENDIF ELSE SPAWN, more+filename
               IF N_ELEMENTS(need_clean) NE 0 THEN BEGIN
                  SPAWN, 'DELETE/NOLOG/NOCONFIRM '+filename+';*'
                  look = findfile('sys$login:*._sdac_*;*',count=nf)
                  IF nf GT 0 THEN BEGIN
                     FOR i=0,nf-1 DO BEGIN
                        SPAWN,'DELETE/NOLOG/NOCONFIRM '+look(i)
                     ENDFOR
                  ENDIF
               ENDIF
               RETURN
            ENDIF
         ENDFOR
      END
      ELSE: BEGIN
         FOR i = 0,N_ELEMENTS(dirs)-1 DO BEGIN
            filename = concat_dir(dirs(i),doc_name+'.pro')
            OPENR, unit, filename, /GET_LUN, error=rr
            IF rr EQ 0 THEN BEGIN
               IF KEYWORD_SET(extract) THEN BEGIN
                  target = CONCAT_DIR(cur_dir,doc_name+'.txt')
                  SPAWN, cp+' '+filename+' '+target
                  PRINT, 'Document saved as '+target+ '.'
               ENDIF ELSE SPAWN, more+filename
               CLOSE, unit
               FREE_LUN, unit
               RETURN
            ENDIF
         ENDFOR         
         RETURN
      ENDELSE
   ENDCASE
   PRINT, 'Routine '+STRUPCASE(doc_name)+' not found in the current IDL path.'
   RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'peek.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

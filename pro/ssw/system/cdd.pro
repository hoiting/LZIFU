;---------------------------------------------------------------------------
; Document name: cdd.pro
; Created by:    Liyun Wang, GSFC/ARC, October 6, 1994
;
; Last Modified: Wed Sep 24 09:49:33 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO CDD, dir_name, current=dir_str, last=last, reset=reset
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       CDD
;
; PURPOSE:
;       Change directory and set IDL prompt to current path name
;
; EXPLANATION:
;       CDD stands for CD with directory name displayed. It is intended to
;       replace CD. It offers several advantages that CD lacks: It makes the
;       the IDL prompt to reflect the current directory path; it does not bomb
;       if cd fails. 
;
;       It's better that you add the following lines in your IDL_STARTUP 
;       file so that CDD takes into effect as soon as you get into IDL:
;     
;           cd, current=dir
;           cdd, dir
;
;       Another IDL routine that can be used with CDD is CDUP (cd to an
;       upper level of dir).
;
; CALLING SEQUENCE:
;       CDD [, dir_name]
;
; INPUTS:
;       None required. If no directory name is given, user's home directory is
;       assumed.
;
; OPTIONAL INPUTS:
;       DIR_NAME -- A string, name of the destination directory
;
; OUTPUTS:
;       None. IDL prompt can be changed though.
;
; OPTIONAL OUTPUTS:
;       CURRENT -- The current directory before CDD takes action.
;
; KEYWORD PARAMETERS:
;       LAST -- Prompt the last part of a directory path if set. It
;               has no effect if user's home directory is part of the
;               directory path.
;
; CALLS:
;       DATATYPE, CHK_DIR
;
; COMMON BLOCKS:
;       CDD -- Internal common block used by CDD
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Utility, miscellaneous
;
; PREVIOUS HISTORY:
;       Written October 6, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;      Liyun Wang, GSFC/ARC, October 9, 1994
;         Added directory validity checking feature.
;      Version 2, Liyun Wang, GSFC/ARC, November 12, 1994
;         Added CURRENT keyword
;      Version 3, Liyun Wang, GSFC/ARC, December 16, 1994
;         Made work on VMS machine
;      Version 4, Liyun Wang, GSFC/ARC, January 11, 1995
;         Added the LAST keyword 
;      Version 5, Liyun Wang, GSFC/ARC, January 13, 1995
;         Made prompt for home dir be [~] under VMS
;      Version 6, September 24, 1997, Liyun Wang, NASA/GSFC
;         Chop off '/tmp_nmt' from directory name for UNIX system
;
; VERSION:
;       Version 6, September 24, 1997
;-
;
   ON_ERROR, 2
   COMMON cdd, home_dir, home_len, idl_path, diskname

   IF N_ELEMENTS(home_dir) EQ 0 OR KEYWORD_SET(reset) THEN BEGIN
      home_dir = STRTRIM(getenv('HOME'))
      home_len = STRLEN(home_dir)
      IF !version.os EQ 'vms' AND home_len GT 0 THEN BEGIN
         home_dir = STRUPCASE(home_dir)
         aa = STRPOS(home_dir,':')
         diskname = STRUPCASE(STRMID(home_dir,0,aa+1))
      ENDIF
   ENDIF
   
   IF N_ELEMENTS(idl_path) EQ 0 THEN BEGIN
      idl_path = !path
   ENDIF

   max_len = 20000

   IF N_ELEMENTS(dir_name) NE 0 THEN BEGIN
      IF datatype(dir_name) NE 'STR' THEN MESSAGE, 'Syntax: CDD [, string]'
      IF chk_dir(dir_name,output) THEN BEGIN
         IF (!version.os NE 'vms') THEN $
            cd, dir_name, current = old_dir $
         ELSE cd, output, current = old_dir
      ENDIF ELSE MESSAGE, dir_name+' is not a valid directory name.'
   ENDIF ELSE cd, home_dir, current = old_dir
   i = STRPOS(old_dir, '/tmp_mnt')
   IF i EQ 0 THEN old_dir = STRMID(old_dir, 8, 100)
   
   IF STRPOS(old_dir, home_dir) EQ 0 THEN BEGIN
      IF !version.os NE 'vms' THEN BEGIN
         cd_len = STRLEN(old_dir)
         dir_str = '~'+STRMID(old_dir,home_len,cd_len-1)
      ENDIF ELSE BEGIN
         dir_str = STRMID(old_dir,STRPOS(old_dir,diskname),2000)
      ENDELSE
   ENDIF ELSE dir_str = old_dir

   cd, current=curr_dir
   i = STRPOS(curr_dir, '/tmp_mnt')
   IF i EQ 0 THEN curr_dir = STRMID(curr_dir, 8, 100)
   IF !version.os EQ 'vms' THEN BEGIN
      aa = STRPOS(curr_dir,STRMID(home_dir,0,home_len-1))
      IF aa EQ 0 THEN BEGIN
         temp = STRMID(curr_dir,home_len-1,max_len)
         !prompt = 'IDL:[~'+temp+'> ' 
      ENDIF ELSE BEGIN
         IF KEYWORD_SET(last) THEN BEGIN 
            temp = str_sep(curr_dir,'.')
            n_last = N_ELEMENTS(temp)
            IF n_last GT 1 THEN !prompt = 'IDL:[.'+temp(n_last-1)+'> ' $
            ELSE !prompt = 'IDL:'+curr_dir+'> ' 
         ENDIF ELSE BEGIN
            aa = STRPOS(curr_dir,diskname)
            IF aa EQ 0 THEN !prompt = $
               'IDL:'+STRMID(curr_dir,STRLEN(diskname),max_len)+'> '$
            ELSE !prompt = 'IDL:'+curr_dir+'> '
         ENDELSE
      ENDELSE
   ENDIF ELSE BEGIN
      IF STRPOS(curr_dir,home_dir) EQ 0 THEN BEGIN
         cd_len = STRLEN(curr_dir)
         !prompt = 'IDL:~'+STRMID(curr_dir,home_len,cd_len-1)+'> '
      ENDIF ELSE BEGIN
         IF KEYWORD_SET(last) THEN BEGIN
            IF !version.os EQ 'windows' THEN BEGIN
               temp = str_sep(curr_dir,'\')
            ENDIF ELSE BEGIN
               temp = str_sep(curr_dir,'/')
            ENDELSE
            n_last = N_ELEMENTS(temp)
            !prompt = 'IDL:'+temp(n_last-1)+'> '
         ENDIF ELSE !prompt = 'IDL:'+curr_dir+'> '
      ENDELSE
   ENDELSE
END

;---------------------------------------------------------------------------
; End of 'cdd.pro'.
;---------------------------------------------------------------------------

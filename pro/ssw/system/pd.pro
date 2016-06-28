;---------------------------------------------------------------------------
; Document name: pd.pro
; Created by:    Liyun Wang, GSFC/ARC, November 12, 1994
;
; Last Modified: Wed Sep 24 09:47:33 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;+
; NAME:
;	PD
;
; PURPOSE:
;	Push a directory onto the top of a directory stack
;
; CALLING SEQUENCE:
;	PD [, dir] [,rotate=rot_num]
;
; EXAMPLE:
;       Suppose the current directory stack is:
;
;          ~ ~/doc ~/idl /usr/local/bin
;
;       Result of "pd":        ~/doc ~ ~/idl /usr/local/bin
;       Result of "pd,r=2":    ~/idl ~ ~/doc /usr/local/bin
;       Result of "pd,r=3":    /usr/local/bin ~ ~/doc ~/idl 
;       Result of "pd,'~/cds': ~/cds ~ ~/doc ~/idl /usr/local/bin
;
; OPTIONAL INPUTS:
;	DIR     - The directory to be pushed. If DIR is not present, or is
;		  an undefined variable, PD will swap the first tow directory
;                 on the top of the stack, or rotate the directory stack if
;                 keyword ROTATE is set.
;       ROT_NUM - Number of the directory to be rotated to the top of
;                 stack.
;
; CALLS:
;       CDD
;
; OTHER RELATED ROUTINES:
;       CDD, PPD, SD, and CDUP
;
; SIDE EFFECTS:
;       None.
;
; COMMON BLOCKS:
;	DIR_STACK:  Contains the stack.
;       CDD:        Common block used by CDD.
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, November 12, 1994
;          Modified from PUSHD for use with CDD.
;       Version 2, Liyun Wang, GSFC/ARC, January 11, 1995
;          Added the ROTATE keyword
;       Version 3, Liyun Wang, GSFC/ARC, January 18, 1995
;          Fixed problem of changing directories from one disk to the
;             other on VMS system
;       Version 4, September 24, 1997, Liyun Wang, NASA/GSFC
;          Chopped off '/tmp_mnt' from directory name for UNIX system
;
; VERSION:
;       Version 4, September 24, 1997
;-
PRO pd, dir, rotate=rotate
   COMMON cdd, home_dir, home_len, idl_path, diskname
   COMMON stack_dir, stack 
   ON_ERROR, 2                  ; Return to caller on error
   n_stack = N_ELEMENTS(stack) 
   IF N_ELEMENTS(dir) NE 0 THEN BEGIN
;---------------------------------------------------------------------------
;     New dir is introduced and should be added to the dir stack
;---------------------------------------------------------------------------
      cdd, dir, current=cwd
      i = STRPOS(cwd, '/tmp_mnt')
      IF i EQ 0 THEN cwd = STRMID(cwd, 8, 100)
      IF !version.os EQ 'vms' THEN BEGIN
         IF STRPOS(cwd,diskname) EQ 0 THEN $
            cwd = STRMID(cwd,STRPOS(cwd,':')+1,2000)
      ENDIF
      IF n_stack EQ 0 THEN stack = [cwd] ELSE stack = [cwd, stack]
      cd, current=curr_dir
      i = STRPOS(curr_dir, '/tmp_mnt')
      IF i EQ 0 THEN curr_dir = STRMID(curr_dir, 8, 100)
      IF !version.os EQ 'vms' THEN BEGIN
         IF STRPOS(curr_dir,home_dir) EQ 0 THEN $
            PRINT, '[~'+STRMID(curr_dir,home_len-1,2000), stack $
         ELSE BEGIN
            aa = STRPOS(curr_dir,diskname)
            IF aa EQ 0 THEN $
               PRINT, STRMID(curr_dir,STRLEN(diskname),2000), stack $
            ELSE $
               PRINT, curr_dir, stack
         ENDELSE
      ENDIF ELSE BEGIN
         IF STRPOS(curr_dir,home_dir) EQ 0 THEN BEGIN
            cd_len = STRLEN(curr_dir)
            PRINT, '~'+STRMID(curr_dir,home_len,cd_len-1), stack
         ENDIF ELSE PRINT, curr_dir, stack
      ENDELSE
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     No new dir is introduced. Just do rotation
;---------------------------------------------------------------------------
      IF n_stack NE 0 THEN BEGIN
         IF N_ELEMENTS(rotate) EQ 0 THEN rot = 1 ELSE BEGIN
            rot = ABS(FIX(rotate))
            IF rot EQ 0 THEN rot = 1
         ENDELSE
         IF rot GT n_stack THEN $
            PRINT, '% PD: Directory stack not that deep.' $
         ELSE BEGIN
;---------------------------------------------------------------------------
;           Rotate the directory stack
;---------------------------------------------------------------------------
            stack = SHIFT(stack,1-rot)
            temp = stack(0)
            IF STRPOS(temp,'[') EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;              VMS system implied; attach the original diskname before cdd
;---------------------------------------------------------------------------
               temp = diskname+temp
            ENDIF
            cdd, temp, current=cwd
            i = STRPOS(cwd, '/tmp_mnt')
            IF i EQ 0 THEN cwd = STRMID(cwd, 8, 100)
            IF !version.os EQ 'vms' THEN BEGIN
               IF STRPOS(cwd,diskname) EQ 0 THEN $
                  cwd = STRMID(cwd,STRPOS(cwd,':')+1,2000)
            ENDIF
            curr_dir = stack(0)
            stack(0) = cwd
            PRINT, curr_dir, stack
         ENDELSE
      ENDIF ELSE BEGIN
         PRINT, '% PD: No other directory!'
      ENDELSE
   ENDELSE
END

;---------------------------------------------------------------------------
; End of 'pd.pro'.
;---------------------------------------------------------------------------

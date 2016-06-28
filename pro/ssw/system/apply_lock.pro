;+
; Project     : SOHO - CDS, STEREO - SECCHI
;                   
; Name        : APPLY_LOCK
;               
; Purpose     : create a LOCK file 
;               
; Category    : Planning, pipeline
;               
; Explanation : creates a LOCK file with the creation date saved in file.
;               
; Syntax      : IDL> apply_lock,lock_file
;
; Inputs      : LOCK_FILE = lock file name (with path)
;               
; Keywords    : ERR - message string
;               QUIET - turn off printing
;               EXPIRE - seconds after which LOCK file expires
;   	    	NOCHMOD - Do not do chmod g+w (saves 5+ sec.)
;
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;     07.03.12, N.Rich - Add /NOCHMOD option for SECCHI pipeline
;     15-March-2007, Zarro - cleaned up a bit.
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-   
; $Id: apply_lock.pro,v 1.2 2007/03/13 13:38:04 nathan Exp $         

pro apply_lock,lock_file,err=err,quiet=quiet,expire=expire,status=status, $
    	    	NOCHMOD=nochmod

err='' & status=1
verbose=(1-keyword_set(quiet))

;-- valid input string filename?

if is_blank(lock_file) then begin
 err='Invalid input LOCK filename'
 if verbose then message,err,/cont
 status=0
 return
endif

;-- check for write access

dir=file_break(lock_file,/path)
if is_blank(dir) then begin
 dir=curdir() & lock=concat_dir(dir,lock_file)
endif

if not write_dir(dir) then begin
 err='Write permission denied. No LOCK file created'
 if verbose then message,err,/cont
 status=0
 return
endif

;-- create lock file

openw,lun,lock,/get_lun,err=error
if error then begin
 err='Write permission denied. No LOCK file created'
 if verbose then message,err,/cont
 status=0
 return
endif
if not exist(lun) then return

;-- insert creation time 

user_id=chklog('USER_ID')
if is_blank(user_id) then user_id=get_user_id()
user_pid=get_pid('/idl',tty=user_tty,count=count)
if exist(expire) then expiration=float(expire) else expiration=0.
get_utc,utc,/ecs
printf,lun,utc
printf,lun,expiration
printf,lun,user_id
printf,lun,user_pid[0]
printf,lun,user_tty[0]
close_lun,lun 

;-- allow GROUP write access to LOCK file

IF (1-keyword_set(NOCHMOD)) THEN chmod,lock,/g_write

if verbose then message,'Created LOCK file - '+lock,/cont
status=1

return & end



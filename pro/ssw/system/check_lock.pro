;+
; Project     : SOHO - CDS     
;                   
; Name        : CHECK_LOCK
;               
; Purpose     : check if a LOCK file created by APPLY_LOCK has expired
;               
; Category    : Planning
;               
; Explanation : checks creation date of LOCK file saved in file.
;               
; Syntax      : IDL> expired=check_lock(lock_file)
;
; Inputs      : LOCK_FILE = lock file name (with path)
;               
; Outputs     : EXPIRED  = 1 if expired
;
; Keywords    :
;               QUIET    = set to suppress messages
;               ERR      = output messages
;               TIME     = LOCK file creation time
;
; Restrictions: LOCK file must be created by APPLY_LOCK
;               
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function check_lock,lock_file,quiet=quiet,err=err,time=time,expired=expired

verbose=(1-keyword_set(quiet))
time='' & err=''

;-- valid input string filename?

if is_blank(lock_file) then return,1

;-- if file doesn't exist, then it has expired

chk=loc_file(lock_file,count=count)
if count ne 1 then begin
 if verbose then message,'LOCK file does not exist',/cont
 return,1
endif

;-- does user have permission to delete it?

chk=test_open(lock_file,/write,/quiet)
if not chk then begin
 err='Denied permission to remove LOCK file - '+lock_file
 if verbose then message,err,/cont
 return,0
endif

;-- read it and see if creation time is older than expiration time

openr,lun,lock_file,/get_lun,error=error
if error then begin
 err='Cannot read LOCK file - '+lock_file
 if verbose then message,err,/cont
 return,0
endif

rok=0
lock_date=''
lock_id=''
lock_expiry=0.
lock_pid=0l
lock_tty=''
on_ioerror,quit
readf,lun,lock_date
readf,lun,lock_expiry
readf,lun,lock_id
readf,lun,lock_pid
readf,lun,lock_tty
rok=1
quit:on_ioerror,null
close,lun & free_lun,lun

if not rok then begin
 merr='Error reading LOCK file - '+lock_file
 if verbose then message,merr,/cont
; return,0
endif

err=''
ldate=anytim2tai(lock_date,err=err)
if err ne '' then begin
 if verbose then message,err,/cont
 return,0
endif

;-- has lock file expired? If so, then anyone can remove it

get_utc,utc,/ecs
if lock_expiry gt 0 then begin
 expired=(anytim2tai(utc)-ldate) ge lock_expiry
endif else expired=0

;-- if not expired, then only last user to apply lock can remove it

remove=1b
if expired or is_blank(lock_id) then begin
 if verbose then message,'LOCK file has expired',/cont
endif else begin
 user_id=chklog('USER_ID')
 if is_blank(user_id) then user_id=get_user_id()
 user_pid=get_pid('/idl',tty=user_tty,count=count)
 if count eq 0 then begin
  user_pid=lock_pid & user_tty=lock_tty
 endif
 if count gt 1 then begin
  user_pid=user_pid(0)
  user_tty=user_tty(0)
 endif

; expired=(lock_id eq user_id) and (user_pid eq lock_pid) and (user_tty eq lock_tty)

 if (lock_tty eq '') or (user_tty eq '') then begin
  lock_tty='' & user_tty=''
 endif

 remove=(lock_id eq user_id) and (user_tty eq lock_tty)
 if not remove then err='Procedure locked by '+lock_id+' at '+lock_date+' on TTY '+lock_tty else $
  if verbose then message,'LOCK file can be removed by current user',/cont
endelse

if verbose and (err ne '') then message,err,/cont
time=utc
return,remove

end


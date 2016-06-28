;+
; Project     : SOHO - CDS     
;                   
; Name        : RM_LOCK
;               
; Purpose     : remove LOCK file created by APPLY_LOCK
;               
; Category    : Planning
;               
; Syntax      : IDL> rm_lock,file
;    
; Inputs      : FILE = lock file name (with full path)
;               
; Keywords    :
;               QUIET    = set to suppress messages
;               ERR      = output messages
;               STATUS = 1/0 for success/failure
;               TIMER  = seconds to wait before retrying
;               OVER   = override protection checks
;               RETRY = no of retries if timer is set (def =0)
;
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro rm_lock,file,quiet=quiet,err=err,timer=timer,status=status,over=over,$
                 retry=retry

err='' & status=1
verbose=1-keyword_set(quiet)

if is_string(file) then lock_file=file else return
clook=loc_file(lock_file,count=count)
if count eq 0 then begin
 if verbose then message,'LOCK file already removed',/cont
 return
endif

over=keyword_set(over)
if exist(timer) then twait=abs(timer) else twait=0
if exist(retry) then retries=abs(retry) else retries=10000l
if twait eq 0 then retries=0

;-- owner override

if over then begin
 rm_file,lock_file,err=err
 if (err eq '') then return
endif

;-- keep trying until LOCK expires

k=1
repeat begin
 k=k+1
 expired=check_lock(lock_file,err=err,quiet=quiet)
 if expired then rm_file,lock_file,err=err 
 if (twait gt 0) and (err ne '') then begin
  if verbose then message,'Waiting for file to be unlocked...',/cont
  wait,twait
 endif
endrep until ((err eq '') or (twait eq 0) or (k gt retries))

if (err eq '') and verbose then message,'Removed LOCK file - '+lock_file,/cont
if err ne '' then status=0

return & end


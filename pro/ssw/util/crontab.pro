;+
; Project     : HESSI
;
; Name        : CRONTAB
;
; Purpose     : Simulate running IDL commands in a cron job
;
; Category    : Utility 
;
; Syntax      : IDL> cron,command,tstart
;
; Inputs      : COMMAND = command to execute
;               TSTART = time after which to start
;
; Optional 
; Inputs      : NTIMES = # of times to run [def=1]
; 
; Outputs     : None
;
; Keywords    : TEND = time to stop execution
;               WAIT_TIME = seconds to wait between execution
;               VERBOSE = send message output
;
; History     : Written 3 July 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----

pro crontab,command,tstart,ntimes,tend=tend,wait_time=wait_time,verbose=verbose

verbose=keyword_set(verbose)
if is_blank(command) then return
if not valid_time(tstart) then return
if not exist(ntimes) then ntimes=1 else ntimes=ntimes > 1
if not exist(wait_time) then wait_time=10

i=0
ts=anytim2tai(tstart)
if valid_time(tend) then te=anytim2tai(tend)
ncmd=n_elements(command)

repeat begin
 if i gt 0 then wait,wait_time
 now=anytim2tai(!stime)
 do_it=(now gt ts) and (i lt ntimes)
 if exist(te) then $
  do_it=(now gt ts) and (now lt te) and (i lt ntimes)
 if do_it then begin
  if verbose then message,trim(string(i+1))+' executing at '+!stime,/cont
  if ncmd gt 1 then scmd=arr2str(command,delim=' & ') else scmd=command
  s=execute(scmd)
  i=i+1
 endif
 quit=(i ge ntimes)
 if exist(te) then quit=(i ge ntimes) or (now ge te)
endrep until quit

return & end
  


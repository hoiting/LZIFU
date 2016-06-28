;+
; Project     : SOHO - CDS     
;                   
; Name        : GET_PID
;               
; Purpose     : return user PID and TTY for given process
;               
; Category    : utility
;               
; Syntax      : IDL> pid=get_pid(process)
;    
; Examples    : pid=get_pid('/idl')
;
; Inputs      : PROCESS = string process name (e.g. 'idl')
;               
; Outputs     : PID = user PID from PS
;
; Opt. Outputs: None
;               
; Keywords    : TTY = terminal at which process was initiated
;               ERR = error string
;               COUNT = # of PID's associated with PROCESS
;               ALL = get PID's for all terminals
;
; History     : Version 1,  17-Aug-1996,  D M Zarro.  Written
;             : 26-Mar-2002, Zarro (EER/GSFC) - sped up with caching
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function get_pid,process,tty=tty,err=err,count=count,all=all

err='' & count=0 & tty='' & pid=0

if is_batch() then return,pid


all=keyword_set(all)

if is_blank(process) then begin
 message,'Syntax: pid = get_pid(process)',/cont
 return,pid
endif

if os_family(/lower) eq 'vms' then begin
 espawn,'write sys$output f$getjpi(f$pid(pid), "terminal")',out,count=count
 if count eq 1 then tty=out[0] else return,pid
 espawn,'write sys$output f$getjpi(f$pid(pid), "pid")',out,count=count
 if count eq 1 then pid=out[0]
 return,pid
endif

;-- get PID

espawn,'ps',out,count=count,/noshell,/cache
if count eq 0 then begin
 err='Cannot determine PID'
 message,err,/cont
 return,pid
endif

;-- filter out TTY from PS output

tpos=where(strpos(strlowcase(out),'tty') gt -1,count)
if count eq 0 then begin
 err='Cannot find TTY in PS output'
 message,err,/cont
 return,pid
endif
out=out[tpos]

;-- filter out PROCESS from PS output

ppos=where(strpos(out,process) gt -1,count)
if count eq 0 then begin
 err='Cannot find process in PS output'
 message,err,/cont
 return,pid
endif

;-- get PID and TTY

out=out[ppos]
tpos=strpos(strlowcase(out),'tty')
term=strarr(count) & pid=lonarr(count) 
for i=0,count-1 do begin
 ps=out[i]
 pid[i]=strmid(ps,0,tpos[i])
 term[i]=strmid(ps,tpos[i],8)
endfor

if not all then begin
 espawn,'tty',out,count=count,/noshell,/cache
 if count eq 0 then begin
  err='Cannot determine terminal'
  message,err,/cont
 endif else begin
  var=grep(out(0),'/dev/'+term,index=tpos)
  if var[0] ne '' then begin
   tty=term(tpos)
   pid=pid(tpos)
  endif
 endelse
endif else tty=term

tty=trim2(tty)
count=n_elements(pid)
if count eq 1 then begin
 pid=pid[0] & tty=tty[0]
endif

return,pid
end


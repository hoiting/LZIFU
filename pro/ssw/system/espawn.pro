;+
; Project     : SOHO - CDS
;
; Name        : ESPAWN
;
; Purpose     : spawn a shell command and return STDIO and STDERR
;
; Category    : System
;
; Explanation : regular IDL spawn command doesn't return an error message
;
; Syntax      : IDL> espawn,cmd,out
;
; Inputs      : CMD = command(s) to spawn
;
; Keywords    : NOERROR = inhibit error output
;               COUNT = n_elements(out)
;               BACKGROUND = background the commands (UNIX only)
;               UNIQUE = make commands unique
;               CACHE = use cached results
;               CLEAR = clear cached results
;
; Outputs     : OUT = output of CMD
;
; History     : Version 1,  24-Jan-1996, Zarro (ARC/GSFC) - written
;               Modified, 12-Nov-1999, Zarro (SM&A/GSFC) - made 
;                Windows compliant
;               Modified, 12-March-2000, Zarro (SM&A/GSFC) - sped
;                up with /NOSHELL (Unix only)
;               Modified, 22-May-2000, Zarro (EIT/GSFC) - added
;                /UNIQUE
;               Modified, 26-Mar-2002, Zarro (EER/GSFC) - sped up with caching 
;               
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro espawn,cmd,out,count=count,unique=unique,_extra=extra,cache=cache,clear=clear

common espawn,last_result

if keyword_set(clear) then delvarx,last_result,/free

out='' & count=0
if is_blank(cmd) then return

;-- check if last result is in cache memory

use_cache=keyword_set(cache) and (n_elements(cmd) eq 1)
if use_cache then begin
 if is_struct(last_result) then begin
  chk=where(last_result.cmd eq strtrim(cmd[0],2),rcount)
  if rcount gt 0 then begin
   k=chk[0]
   if (last_result[k].count gt 0) then begin
    if ptr_exist(last_result[k].out) then begin
     out=*(last_result[k].out)
     count=last_result[k].count
     return
    endif
   endif
  endif
 endif
endif

os=os_family(/lower)
want_out=n_params() eq 2

if keyword_set(unique) then begin
 ucmd=get_uniq(cmd)
endif else ucmd=cmd

;-- Windows

if (os eq 'windows') then begin
 state='win_spawn,ucmd,/delete,_extra=extra'
 if want_out then state=state+',out,count=count'
 s=execute(state)
 goto,done
endif
    
;-- VMS

if (os eq 'vms') then begin
 arg=''
 keys='/nowait,/nolog,/nocli'
 if want_out then begin
  arg=',out' & keys=keys+',count=count'
 endif
 state=trim2("spawn,'"+trim2(ucmd)+"'"+arg+keys)
 s=execute(state)
 goto,done
endif

;-- Unix

state='unix_spawn,ucmd,_extra=extra'
if want_out then state=state+',out,count=count'
s=execute(state)

done:

if (count gt 0) and use_cache then begin
 new_result={cmd:cmd[0],out:ptr_new(out),count:count}
 last_result=merge_struct(last_result,new_result)
endif

return

end

;+
; NAME:   
;      get_tape
; PURPOSE:
;      get and mount available tape drive unit
; CALLING SEQUENCE:
;      get_tape,tunit
; OUTPUTS:
;      tunit = tape unit number
; RESTRICTIONS: 
;      VMS only
; MODIFICATION HISTORY:
;      written DMZ (ARC Jul'92)
;-

 pro get_tape,tunit

 on_error,1

;-- tape already mounted?

 mt_unit=chklog('drive')
 if mt_unit ne '' then begin
  message,'current mounted drive: '+mt_unit,/contin
  ans='' & read,'* dismount this unit [def=n]? ',ans
  ans=strupcase(strmid(ans,0,1))
  if ans ne 'Y' then begin
   tunit=fix(strmid(mt_unit,2,1))
   return
  endif
  dellog,'drive'
  st='dismount/nounload '+mt_unit & spawn,st
 endif

;-- start mounting

 spawn,'sh log mt*'
 repeat begin
  unit='' 
  read,'* load tape and enter corresponding drive number from above (q to quit): ',unit 
  if strupcase(strmid(unit,0,1)) eq 'Q' then message,'quitting..'
  mt_unit=strcompress('mt'+unit)
  s='$mount/for '+mt_unit
  message,'do not interrupt, mounting '+mt_unit,/contin
  spawn,s,o
  offline=(strpos(o(0),'VOLINV') ne -1) 
  alloc=(strpos(o(0),'ALLOC') ne -1)
  invalid=(strpos(o(0),'IVDEVNA') ne -1)
  nosuch=(strpos(o(0),'NOSUCH') ne -1)
  if offline or alloc or invalid or nosuch then begin
   message,o(0)+', please try again',/contin
   ok=0
  endif else begin
   ok=1 & message,o(0),/contin 
  endelse
 endrep until ok
 setlog,'drive',mt_unit & tunit=fix(unit)
 return & end

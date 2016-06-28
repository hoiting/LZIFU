;+
; NAME:
;       is_open
; PURPOSE:
;       check if a file unit is open
; CALLING SEQUENCE:
;       chk=is_open(file)
; INPUTS:
;       file = file to check
; OUTPUTS:
;       chk = 1 (open) or 0 (closed)
; KEYWORDS:
;       unit = file unit number
; PROCEDURE:
;       uses fstat (now uses HELP)
; HISTORY:
;       Written Jun'94 (DMZ,ARC)
;       Modified, Zarro (SM&A/GSFC), 8 Oct 1999
;        -- more accurate use of grep
;-

function is_open,file,unit=unit

chk=0b
delvarx,unit
if is_blank(file) then return,chk

ver5=idl_release(lower=5,/inc)
if ver5 then begin
 call_procedure,'help',/files,out=out
 out=strtrim(out,2)
 full_name=chklog(file,/pre)
 nout=n_elements(out)
 if (nout gt 0) and (out(0) ne '') then begin
  for i=0,nout-1 do begin
   temp=strcompress(out(i))
   temp=str2arr(temp,delim=' ')
   findit=grep(full_name(0),temp,index=index,/exact)
   if findit(0) ne '' then begin
    unit=temp(0)
    chk=is_number(unit) 
    if chk then unit=long(unit)
    return,chk
   endif
  endfor
 endif
endif else begin
 if !d.unit ne 0 then begin
  status=fstat(!d.unit)
  if strpos(strlowcase(file),strlowcase(status(0).name)) ge 0 then chk=1b
 endif
endelse

return,chk & end

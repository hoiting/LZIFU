;+
; Project     : HESSI
;
; Name        : WHERE_VAL
;
; Purpose     : Wrapper around WHERE that applies checks to data
;
; Category    : Utility
;
; Syntax      : IDL> chk=where_val(data,','< 10',count)
;
; Inputs      : DATA = data array to check
;               CHECK = check string (e.g. '< 10')
;
; Outputs     : COUNT = # of matches found
;               CHK = matching indicies
;
; History     : Written, 3-Feb-2004, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function where_val,data,check,count

count=0

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return,-1
endif

if not exist(data) then return,-1
if is_blank(check) then return,-1

;-- convert symbols

tcheck=check
sym=['<','>','=','<=','>=','~=']
tsym=[' lt ',' gt ',' eq ',' le ',' ge ',' ne ']
for i=n_elements(sym)-1,0,-1 do begin
 if stregex(tcheck,sym[i],/bool) then begin
  tcheck=str_replace(tcheck,sym[i],tsym[i])
  break
 endif
endfor

chk=-1
runit='chk=where(data '+tcheck+',count)'
s=execute(runit,1)

if s eq 0 then message,'Invalid check expression: '+tcheck,/cont

return,chk
end

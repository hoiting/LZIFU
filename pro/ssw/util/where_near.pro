;+
; Project     : Solar-B/EIS
;
; Name        : WHERE_NEAR
;
; Purpose     : find indicies of source target with values nearest target
;
; Category    : utility 
;
; Syntax      : IDL> index=where_near(source,target)
;                   
; Inputs      : source = source values to check
;               target = values to check against
;
; Outputs     : INDEX = indicies of source
;
; Keywords    : COUNT = number of indicies
;
; History     : 2-Sep-2006 D.M. Zarro (ADNET/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function where_near,source,target,count=count

count=0l
ssource=size(source,/type)
starget=size(target,/type)

ok=(ssource gt 0) and (ssource lt 6) and (starget gt 0) and (starget lt 6)  
if ~ok then return,-1

np=n_elements(target)
output=lonarr(np)
temp=source
for i=0,np-1 do begin
 diff=abs(target[i]-temp)
 chk=where(diff eq min(diff),complement=complement,ncomplement=ncomplement)
 val=temp[chk[0]]
 ival=where(val eq source)
 output[i]=ival[0] 
 if ncomplement eq 0 then break
 temp=temp[complement]
endfor

output=output[0: i < (np-1)]
count=n_elements(output)

return,output
end

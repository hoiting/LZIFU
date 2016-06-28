;+
; Project     : VSO
;
; Name        : str_near
;
; Purpose     : Find nearest string element to input token
;               (useful for finding files nearest in time to time-based
;                filenames)
;
; Category    : utility string
;
; Syntax      : IDL> near=str_nearest(input,token)
;
; Inputs      : INPUT = input string array
;               TOKEN = string token 
;
; Outputs     : NEAR = index of INPUT element nearest TOKEN
;
; Keywords    : ERR = error string
;
; History     : 28-Dec-2005, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function str_near,input,token

if not is_string(token,/blank) then return,-1
if not is_string(input,/blank) then return,-1

;-- check if exact match

chk=where(token[0] eq input,count)
if count gt 0 then return,chk[0]

;-- else sort to find nearest match

temp=[token,input]
s=bsort(temp)
stemp=temp[s]
chk=where(token[0] eq stemp)

if chk[0] gt 0 then nearest=chk[0]-1 else nearest=0

return,nearest

end


;+
; Project     : SOHO - CDS
;
; Name        : str_key
;
; Purpose     : Extract keyword/values pairs into a structure
;
; Category    : Utility
;
; Syntax      : IDL> stc=stc_key(array)
;
; Inputs      : ARRAY = array to parse
;
; Outputs     : STC = structure with keywords as tag names, and corresponding
;                     value
;
; Keywords    : None
;
; History     : 25-June-2002,  Zarro (LAC/GSFC)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function stc_key,array


if is_blank(array) then return,-1

chk=stregex(array,'(.+)=(.+)',/extra,/sub)
sz=size(chk)
if sz[1] ne 3 then return,1
if sz[0] eq 1 then np=1 else np=sz[2]
for i=0,np-1 do begin
 key=chk[1,i] & value=chk[2,i]
 if trim(key) ne '' then stc=add_tag(stc,value,trim(key),/quiet)
endfor

if is_struct(stc) then return,stc else return,-1

end 

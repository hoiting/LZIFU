;+
; Project     : EIS
;
; Name        : MATCH_TAGS
;
; Purpose     : Match strings with tag names in a structure
;
; Category    : utility structures string
;
; Inputs      : SEARCH = comma delimited string with elements 
;               [e.g. 'TEST1 = 1, TEST2=2']
;               STC = structure to match against [e.g. {test1:1, test3:3)
;
; Outputs     : RSEARCH = result string with only matching elements
;
; Example     : IDL> rsearch=match_tags(search,stc) 
;                    will return: rsearch='TEST1=1'
;
; Keywords    : None
;
; History     : 14-Sept-2007,  D.M. Zarro (ADNET) - Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function match_tags,search,stc

if is_blank(search) or (1-is_struct(stc)) then return,''

pieces=strup(str2arr(search,delim=','))
tags=tag_names(stc)
for i=0,n_elements(tags)-1 do begin
 chk=where(stregex(pieces,tags[i],/bool),count)
 if count gt 0 then begin
  keep=pieces[chk]
  if is_blank(rsearch) then rsearch=keep else rsearch=[rsearch,keep]
 endif
endfor

if is_string(rsearch) then rsearch=arr2str(rsearch,delim=',') else rsearch=''
return,rsearch 
end
 



;+
; Project     :	HESSI
;
; Name        :	stc_sum
;
; Purpose     :	Sum structure tag values into one huge string
;               (used by STC_UNIQ for sorting structure arrays)
;
; Category    :	Structure handling
;
; Syntax      : IDL> output=stc_sum(input)
;
; Inputs      :	INPUT = input structure array
;
; Outputs     :	SUM = string array of summed tag values
;
; Keywords    :	EXCLUDE = tag names to exclude
;               SKIP_BAD   = skip non-string/numeric/scalar values
;               CASE_SENSITIVE = set for case sensitivity
;
; Restrictions: Structure elements cannot be arrays or structures
;
; Written     : Zarro (EIT/GSFC), 10 July 2001
;
; Contact     : dzarro@solar.stanford.edu
;-


function stc_sum,input,exclude=exclude,skip_bad=skip_bad,$
                 case_sensitive=case_sensitive

if not exist(input) then return,''
if size(input,/tname) ne 'STRUCT' then return,''

;-- check for non-string/non-numeric/non-scalar structure fields
;-- create one humongous string by summing each field

no_case=1-keyword_set(case_sensitive)
skip=keyword_set(skip_bad)
sum=''
chk=is_string(exclude,etags)
etags=strupcase(trim(etags))
no_good=[6,8,9,10,11]
tags=tag_names(input)
ntags=n_elements(tags)
for i=0,ntags-1 do begin
 tag=tags[i] & add_it=1b
 chk=where(tag eq etags,count)
 if count eq 0 then begin
  chk=size(input[0].(i),/n_dimen)
  if chk gt 0 then begin
   if skip then add_it=0b else begin
    err='all structure tags must be scalar'
    message,err,/cont
    return,input
   endelse
  endif
  chk=where(size(input[0].(i),/type) eq no_good,count)
  if count gt 0 then begin
   if skip then add_it=0b else begin
    err='all structure tags must be string/numeric'
    message,err,/cont
    return,input
   endelse
  endif
  if add_it then begin
   if no_case then $
    sum=sum+strlowcase(strcompress(input.(i),/remove)) else $
     sum=sum+strcompress(input.(i),/remove) 
  endif
 endif
endfor

return,sum

end


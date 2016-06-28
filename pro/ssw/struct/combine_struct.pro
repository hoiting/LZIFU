;+
; Project     :	SOHO - CDS
;
; Name        :	COMBINE_STRUCT
;
; Purpose     :	Combine two structures
;
; Explanation :	Combines two structures by using STRUCT_ASSIGN
;               to mitigate problems caused by nested anonymous 
;               structures.
;
; Use         : NEW_STRUCT=COMBINE_STRUCT(STRUCT1,STRUCT2)
;
; Inputs      :	STRUCT1,2 = input structures
;
; Outputs     :	NEW_STRUCT = concatanated structure
;
; Keywords    :	ERR = err string
;               NOTAG_CHECK = don't check if tag names match.
;               NOCHECK = skip input checking
;
; Category    :	Structure handling
;
; Written     :	3-Oct-2000, Dominic Zarro (EIT/GSFC) - to avoid and 
;               handle variable sized tags
; Modified    : 20-Dec-2002, Zarro (EER/GSFC) - take advantage of relaxed
;               structure assignment
;
; Contact     : dzarro@solar.stanford.edu
;
;-

function combine_struct,struct1,struct2,err=err,notag_check=notag_check,$
                nocheck=nocheck


err=''
if (1-keyword_set(nocheck)) then begin
 if (not is_struct(struct1)) or (not is_struct(struct2))  then begin
  if is_struct(struct1) then return,struct1
  if is_struct(struct2) then return,struct2
  err='invalid input structures'
  message,err,/cont
  return,0
 endif
endif

s1=tag_names(struct1,/struct)
s2=tag_names(struct2,/struct)

if (1-keyword_set(notag_check)) and (1-since_version('5.4'))then begin
 smatch=match_struct(struct1,struct2,/tags) 
 if not smatch then begin
  err='Input structures do not have matching tag names'
  message,err,/cont
  return,struct1
 endif
endif

;-- if 5.4 or later, then we have relaxed structure assignment

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err='Error combining structures'
 message,err,/cont
 return,0
endif
if ((s1 eq s2) and (s1 ne '')) or since_version('5.4') then return,[struct1,struct2]

;------------------------------------------------------------------------------

n1=n_elements(struct1) & n2=n_elements(struct2)

new_ver=idl_release(lower=5,/inc)
if new_ver then copier='struct_assign' else copier='copy_struct'

target=struct1(0)
out_struct=replicate(target,n1+n2)
for i=0,n1-1 do begin
 call_procedure,copier,struct1(i),target
 out_struct(i)=target
endfor
for i=0,n2-1 do begin
 call_procedure,copier,struct2(i),target
 out_struct(i+n1)=target
endfor

return,out_struct

end

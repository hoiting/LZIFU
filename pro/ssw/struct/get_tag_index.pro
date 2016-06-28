;+
; Project     : SOHO - CDS
;
; Name        : GET_TAG_INDEX
;
; Purpose     : Return index of structure tag name
;
; Category    : Utility
;
; Explanation : Same as TAG_INDEX, except input can be both name or index
;               (If index, then check for validity)

;
; Syntax      : IDL> index=get_tag_index(stc,tag_name)
;
; Inputs      : STC = input structure
;               TAG_NAME = input tag name 
;
; Outputs     : INDEX = index location of named tag
;
; Keywords    : VALID = return only valid indexes
;               UNIQUE_VAL = return unique values
;
; History     : 23-Jan-1998,  D.M. Zarro.  Written
;               4-Oct-2000, Zarro, vectorized

; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_tag_index,stc,tag_name,err=err,valid=valid,unique_val=unique_val

err=''
tag_no=-1
if (datatype(stc) ne 'STC') or (not exist(tag_name)) then return,-1

tags=tag_names(stc)
ntags=n_elements(tags)

if is_string(tag_name) then begin
 tag_no=tag_index(stc,tag_name)
endif else begin
 chk=where(is_number(tag_name),count)
 if count gt 0 then begin
  tag_no=tag_name(chk)
  nok=where( (tag_no ge ntags) or (tag_no lt 0),count)
  if count gt 0 then tag_no(nok)=-1
 endif
endelse

if keyword_set(valid) then begin
 ok=where(tag_no gt -1,count)
 if count gt 0 then tag_no=tag_no(ok) else tag_no=-1
endif

if n_elements(tag_no) eq 1 then begin
 tag_no=tag_no(0)
 if tag_no eq -1 then err='invalid input tag name/index'
endif

if keyword_set(unique_val) then tag_no=get_uniq(tag_no)

return,tag_no

end


;+
; Project     : SOHO - CDS
;
; Name        : BOOST_TAG
;
; Category    : Utility
;
; Purpose     :	boost a tag value
;
; Explanation :	Useful for updating history tags in structures
;
; Syntax      : IDL> new_struct=boost_tag(struct,value,tag_name)
;
; Inputs      : STRUCT = structure to modify
;               TAG_VALUE  = value to boost current value
;               TAG_NAME = tag name to boost
;
; Outputs     : NEW_STRUCT = modified structure
;
; Keywords    : ERR = error string
;               NAME = optional new name for output structure
;               QUIET = don't echo messages
;               RECURSE = recursively search for tag name
;
; History     : Version 1,  13-April-1997,  D.M. Zarro.  Written
;               Version 2,  29-Sept-2000, Zarro (added /NO_RECURSE)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function boost_tag,struct,tag_value,tag_name,name=name,err=err,$
                       quiet=quiet,no_recurse=no_recurse,$
                       no_check=no_check

on_error,1
err=''

verbose=1-keyword_set(quiet)
recurse=1-keyword_set(no_recurse) 
do_check=1-keyword_set(no_check)

if do_check then begin

 if (not exist(tag_value)) or (not is_string(tag_name)) then begin
  pr_syntax,'new_struct=boost_tag(struct,tag_value,tag_name)'
  if exist(struct) then return,struct else return,0
 endif

 if n_elements(tag_name) ne 1 then begin
  if verbose then message,'restricted to boosting one tag at a time',/cont
  if exist(struct) then return,struct else return,0
 endif

endif

tags=tag_names(struct) & ntags=n_elements(tags)

;-- create if doesn't exist

if is_string(tag_name) then begin
 if not have_tag(struct,tag_name,/exact) then $
  return,add_tag(struct,tag_value,tag_name)
 str_tag_name=strup(tag_name)
 tag_no=get_tag_index(struct,str_tag_name,/valid)
endif else begin
 tag_no=get_tag_index(struct,tag_name,/valid,err=err)
 if err ne '' then begin
  if verbose then message,err,/cont
  return,struct
 endif
 str_tag_name=tags(tag_no)
endelse

new_ver=idl_release(lower=5,/inc)
if new_ver then copier='struct_assign' else copier='copy_struct'

;-- loop thru each structure

nstruct=n_elements(struct)
for i=0,nstruct-1 do begin

 new_struct=struct(i)
 if recurse then begin
  for k=0,ntags-1 do begin
   if (k ne tag_no) then begin  
    if datatype(struct(0).(k)) eq 'STC' then begin
     tstruct=boost_tag(new_struct.(k),tag_value,str_tag_name,err=err,$
                       /no_check)
     if err eq '' then begin
      new_struct=rep_tag_value(new_struct,tstruct,tags(k),/no_copy,$
                           /no_check,/no_recurse)
     endif
    endif
   endif
  endfor
 endif

 if tag_no gt -1 then begin

;-- some checks first

  old_value=new_struct.(tag_no)
  if datatype(old_value) ne datatype(tag_value) then begin
   if (datatype(old_value,2) gt 5) or (datatype(tag_value,2) gt 5) then begin
    err='new tag value must be of same type as old value'
    if verbose then message,err,/cont
    return,struct
   endif
  endif

  if datatype(old_value) eq 'STC' then begin
   new_value=merge_struct(old_value,tag_value,err=err) 
   if err ne '' then begin
    if verbose then message,err,/cont
    return,struct
   endif
  endif else new_value=[old_value,tag_value]

;-- replace here

  err=''
  temp_struct=rep_tag_value(new_struct,new_value,str_tag_name,$
                            err=err,/no_copy,/no_recurse,/quiet)
  if err ne '' then begin
   if verbose then message,err,/cont
   return,struct
  endif

  new_struct=copy_var(temp_struct)
 endif

;-- have to use COPY_STRUCT in case of nested anonymous structures

 if (nstruct gt 1) then begin
  if (i eq 0) then begin
   target=copy_var(new_struct)
   out_struct=replicate(target,nstruct)
  endif else begin
   call_procedure,copier,new_struct,target
   out_struct(i)=target
  endelse
 endif else out_struct=copy_var(new_struct)

endfor

delvarx,new_struct,temp_struct

return,out_struct

end


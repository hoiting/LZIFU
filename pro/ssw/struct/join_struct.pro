;+
; Project     : HESSI
;
; Name        : JOIN_STRUCT
;
; Purpose     : join two structures together
;
; Syntax      : new_struct=join_struct(struct1,struct2)
;
; Inputs      : STRUCT1, 2 = input structures to join (array or scalar)
;               Tag values in STRUCT1 override those in STRUCT2
;
; Outputs     : NEW_STRUCT = new structure
;
; Keywords    : ERR = error string
;
; Category    : Structure handling
;
; Written     : 1-Dec-02, Zarro (EER/GSFC)
; Modified    : 24-Dec-04, Zarro (L-3Com/GSFC) - vectorized
;
;-
     
function join_struct,struct1,struct2,_extra=extra,err=err

;-- bypass for old IDL versions

forward_function join_struct2

if (1-since_version('5.4')) then begin
 if have_proc('join_struct2') then $
  return,join_struct2(struct1,struct2,_extra=extra,err=err)
  message,'no longer supported for this version of IDL - '+!version.release,/cont
  if exist(struct1) then return,struct1 else return,-1
endif

;-- catch errors

err=''
error=0
catch,error
if error ne 0 then begin
 err=err_state()
 message,err,/cont
 catch,/cancel
 if exist(struct1) then return,struct1
 if exist(struct2) then return,struct2
 return,-1
endif

if is_struct(struct1) and (not is_struct(struct2)) then return,struct1
if is_struct(struct2) and (not is_struct(struct1)) then return,struct2

err='Both inputs must be structures with equal dimensions' 
if ((not is_struct(struct1)) and (not is_struct(struct2))) or $
   (n_elements(struct1) ne n_elements(struct2)) then begin
 pr_syntax,'new_struct=join_struct(struct1,struct2)'
 if exist(struct1) then return,struct1 else return,-1
endif

err=''

;-- check for duplicate tag names
;-- tags in struct1 override those in struct2

tags_1=tag_names(struct1[0])
tags_2=tag_names(struct2[0])

ntags_2=n_elements(tags_2)
for i=0,ntags_2-1 do begin
 chk=where(tags_2[i] eq tags_1,count)
 if count gt 0 then begin
  if exist(rtag) then rtag=[rtag,tags_2[i]] else rtag=tags_2[i]
 endif
endfor

;-- return if all tags duplicated

nrtag=n_elements(rtag)
if nrtag eq ntags_2 then return,struct1

out=create_struct(struct1[0],rem_tag(struct2[0],rtag,/quiet),_extra=extra)

;-- rebuild if structure array

dims_arr = size( struct1, /dim )
if total( dims_arr ) gt 1 then begin
 out=replicate2(temporary(out),dims_arr)
 struct_assign,struct1,out,/nozero
 struct_assign,struct2,out,/nozero
endif

return,out

end

;+
; Project     : HESSI
;
; Name        : REM_TAG
;
; Purpose     : remove tags from a structure
;
; Syntax      : NEW_STRUCT=REM_TAG(STRUCT,TAG)
;
; Inputs      : STRUCT = input structure (array or scalar)
;             : TAG = array of tag names or indexes to remove
;
; Outputs     : NEW_STRUCT = new structure
;
; Keywords    : NAME = new name for structure (use with care)
;
; Category    : Structure handling
;
; Written     : 1-Dec-02, Zarro (EER/GSFC)
;
; Modified    : 24-Dec-04, Zarro (L-3Com/GSFC) 
;                - vectorized, and removed dangerous /free_mem
;               01-Feb-05, Csillaghy (Univ. Applied Sciences NW Switzerland)
;                - changed n_elements( struct ) to size(struct /dim ), see at the end.
;-

function rem_tag,struct,tags,_extra=extra,quiet=quiet,err=err,name=name

verbose=1-keyword_set(quiet)

;-- bypass for older IDL versions

forward_function rem_tag2

if (1-since_version('5.4')) then begin
 if have_proc('rem_tag2') then $
  return,rem_tag2(struct,tags,_extra=extra,name=name,err=err)
  message,'no longer supported for this version of IDL - '+!version.release,/cont
  if exist(struct) then return,struct else return,-1
endif

;-- catch errors

err=''
error=0
catch,error
if error ne 0 then begin
 err=err_state()
 if verbose then message,err,/cont
 catch,/cancel
 if exist(struct) then return,struct else return,-1
endif

if (1-is_struct(struct)) then begin
 err='invalid input'
 pr_syntax,'new_struct=rem_tag(struct,tag_name)'
 if exist(struct) then return,struct else return,-1
endif

sz=size(tags,/type)
index_input=(sz gt 1) and (sz lt 6)
string_input=(sz eq 7)
err='input tag names or tag indexes required'
if (not index_input) and (not string_input) then begin
 if verbose then message,err,/cont & return,struct
endif
if string_input and is_blank(tags) then begin
 if verbose then message,err,/cont & return,struct
endif

;-- create structure template with tags removed

err=''
stag_names=tag_names(struct)
ntags=n_elements(stag_names) & stag_index=lindgen(ntags)
for i=0,ntags-1 do begin
 if string_input then chk=where(strup(tags) eq stag_names[i],count) else $
  chk=where(long(tags) eq stag_index[i],count)
 if count eq 0 then begin
  if is_struct(temp) then $
   temp=create_struct(temp,stag_names[i],struct[0].(i)) else $
    temp=create_struct(stag_names[i],struct[0].(i))
 endif
endfor

;-- all tags removed

if not is_struct(temp) then return,-1

;-- no tags removed

rtags=tag_names(temp)
if n_elements(rtags) eq ntags then return,struct

;-- rename if requested

if is_string(name) then temp=create_struct(temp,name=strup(name))

dims_arr =size(struct, /dim)
if total(dims_arr) GT 1 then $
 temp=replicate2(temporary(temp),dims_arr)

struct_assign,struct,temp,/nozero

return,temp

end


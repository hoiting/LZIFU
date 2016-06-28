;+
; Project     :	SDAC
;
; Name        :	REM_TAG
;
; Purpose     :	remove a tag from a structure
;
; Use         : NEW_STRUCT=REM_TAG(STRUCT,TAG)
;
; Inputs      :	STRUCT = input structure (array or scalar)
;             : TAG = array of tag names to remove
;
; Outputs     :	NEW_STRUCT = new structure
;
; Opt. Outputs:	None.
;
; Keywords    :	NAME = new name for output structure
;
; Category    :	Structure handling
;
; Written     :	Dominic Zarro (ARC)
;
; Modified    : Version 2, S.V.H. Haugan (UiO), 13 June 1996
;                       Stopped using undocumented REMOVE keyword that
;                       tripped an internal bug in normal create_struct
;                       calls.
;               Version 3, Zarro (GSFC) 16 June 1996 -- cleaned up
;               Version 4, Zarro (GSFC) 8 Oct 1998 -- use CREATE_STRUCT
;               Version 5, Zarro (EIT/GSFC) 30 Sept 2000 
;                          -- added recursion
;                          -- disabled NAME keyword
;               Modified, 1-Dec-02, Zarro (EER/GSFC) 
;                       made NO_RECURSE the default
;               10-Jan-03, Zarro (EER/GSFC) - added call to improved 
;                REM_TAG for newer versions of IDL.
;
;-

function rem_tag2,struct,tag_name,name=name,no_recurse=no_recurse,$
                 no_check=no_check,recurse=recurse,err=err


dprint,'% calling rem_tag2'

err=''

;recurse=1-keyword_set(no_recurse)

recurse=keyword_set(recurse)
do_check=1-keyword_set(no_check)

if do_check then begin
 if datatype(struct) ne 'STC' then begin
  if exist(struct) then return,struct else return,-1
 endif
endif

tags=tag_names(struct)
ntags=n_elements(tags)

;-- check for string or index input

if is_string(tag_name) then begin
 if not have_tag(struct,tag_name) then return,struct
 tag_rem=get_uniq(strup(tag_name))
 tag_no=get_tag_index(struct,tag_rem,/valid,err=err)
endif else begin
 chk=where(is_number(tag_name),count)
 if count eq 0 then return,struct
 tag_no=get_tag_index(struct,tag_name,/valid,err=err,/unique)
 if err ne '' then return,struct
 tag_rem=tags(tag_no)
endelse

;-- if tag is not present then we search recursively. If we
;-- are removing all tags, then we bail out

count=n_elements(tag_no)
if (count ne 1) or (tag_no(0) gt -1) then begin
 if (count eq ntags) then return,-1
endif

new_ver=idl_release(lower=5,/inc)
if new_ver then copier='struct_assign' else copier='copy_struct'
nstruct=n_elements(struct)

for i=0,nstruct-1 do begin

 new_struct=struct(i)

;-- recurse on structure tags

 if recurse then begin
  for k=0,ntags-1 do begin
   do_recurse=where(k ne tag_no,count)
   if count gt 0 then begin
    if datatype(struct(i).(k)) eq 'STC' then begin
     temp_struct=rem_tag(struct(i).(k),tag_rem,/no_check)
     if datatype(temp_struct) eq 'STC' then begin
      new_struct=rep_tag_value(new_struct,temp_struct,tags(k),$
                 /no_copy,/no_recurse,/no_check)
     endif else new_struct=rem_tag(new_struct,tags(k),/no_recurse,/no_check)
    endif
   endif
  endfor
 endif

;-- bail out if all tags removed

 if datatype(new_struct) ne 'STC' then return,-1

;-- bail out if nothing left to remove

 if i eq 0 then begin
  ntags=n_elements(tag_names(new_struct))
  chk=where_vector(tag_no,indgen(ntags),rest=rest,rcount=rcount)
 endif

 if rcount gt 0 then begin
  pairs=pair_struct(new_struct)
  keep=pairs(rest)
  temp_struct=exec_struct(keep,s=new_struct,err=err)
  if err eq '' then new_struct=copy_var(temp_struct)
 endif else return,-1 

;-- have to use COPY_STRUCT in case of nested anonymous structures

 if datatype(new_struct) eq 'STC' then begin
  if (nstruct gt 1) then begin
   if (i eq 0) then begin
    target=copy_var(new_struct)
    out_struct=replicate(target,nstruct)
   endif else begin
    call_procedure,copier,new_struct,target
    out_struct(i)=target
   endelse
  endif else out_struct=copy_var(new_struct)
 endif

endfor

delvarx,temp_struct
if datatype(out_struct) eq 'STC' then return,out_struct else return,-1

end



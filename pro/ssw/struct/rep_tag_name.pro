;+
; Project     :	SDAC
;
; Name        :	REP_TAG_NAME
;
; Purpose     :	replace tag name in a structure
;
; Use         : NEW_STRUCT=REP_TAG_NAME(STRUCT,OLD_NAME,NEW_NAME)
;
; Inputs      :	STRUCT = input structure
;             : OLD_NAME  = old name (can be index)
;             : NEW_NAME = new name
;
; Outputs     :	NEW_STRUCT = new structure
;
; Keywords    :	NO_RECURSE = do not recurse 
;
; Restrictions:	Restricted to changing single tags
;
; Category    :	Structure handling
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 4 May 1995
;               Version 2.0, 23 March 1998 -- added nested search
;               Version 3.0, 8 Oct 1998 -- converted to use CREATE_STRUCT
;		Version 4.0, 10-Dec-1998, William Thompson, GSFC
;			Fixed bug in v3 when structure index passed
;               Modified, 1-Mar-1999, Zarro (SM&A/GSFC) 
;                       Added check for numeric tag index        
;               Modified, 28-Sep-00, Zarro (EIT/GSFC)
;                       Fixed recursion problem
;                       Disabled NAME keyword
;               Modified, 1-Dec-02, Zarro (EER/GSFC) 
;                       Made NO_RECURSE the default
;               Modified, 26-Dec-04, Zarro (L-3Com/GSFC)
;                       Vectorized
;               Modified, 20-May-08, Zarro (ADNET) 
;                       Added /VERBOSE, made QUIET the default
;
;-

function rep_tag_name,struct,old_name,new_name,err=err,$
                      no_check=no_check,found=found,$
                      recurse=recurse,_extra=extra,verbose=verbose

err=''

;-- check inputs

recurse=keyword_set(recurse)
verbose=keyword_set(verbose)
do_check=1-keyword_set(no_check)
found=0b

if do_check then begin

 if (1-is_struct(struct)) or (1-exist(old_name)) then begin
  err='invalid inputs'
  pr_syntax,'new_struct=rep_tag_name(struct,old_name,new_name)'
  if exist(struct) then return,struct else return,-1
 endif

 if is_blank(new_name) then begin
  err='new name must be non-blank string'
  if verbose then message,err,/cont
  return,struct 
 endif
                                  
 if (n_elements(old_name) ne 1) or (n_elements(new_name) ne 1) then begin
  err='restricted to replacing single tag names'
  if verbose then message,err,/cont
  return,struct
 endif

 if (1-is_string(old_name)) and (1-is_number(old_name)) then begin
  err='replacement tag name must be string or index'
  if verbose then message,err,/cont
  return,struct
 endif

endif

;-- determine tag no to replace

tags=tag_names(struct) & ntags=n_elements(tags)

if is_string(old_name) then begin      
 if not have_tag(struct,old_name,/exact) and (not recurse) then begin
  err='no such tag name at main level- '+old_name
  if verbose then message,err,/cont
  if exist(struct) then return,struct else return,-1
 endif
 in_name=strup(old_name)
 tag_no=get_tag_index(struct,in_name,/valid)
endif else begin
 tag_no=get_tag_index(struct,old_name,/valid,err=err)
 if err ne '' then begin
  if verbose then message,err,/cont
  if exist(struct) then return,struct else return,-1
 endif
 in_name=tags[tag_no]
endelse

out_name=strup(new_name)
if in_name eq out_name then return,struct

;-- replace by finding index location of old name, removing tag value at
;   that location, and then adding value with new name in its place

;-- do recursive replace first. If tag to be replaced is a structure, then
;   we skip recursing since we replace with renamed tag later

new_struct=struct
if recurse then begin
 for k=0,ntags-1 do begin
  err=''
  if (k ne tag_no) then begin
   if is_struct(new_struct[0].(k)) then begin
    tstruct=rep_tag_name(new_struct.(k),in_name,out_name,$
                         err=err,/no_check,/recurse,$
                         name='s'+get_rid(/time),found=tfound)
    if tfound and (err eq '') then begin
     found_it=1b
     new_struct=rep_tag_value(new_struct,tstruct,tags[k],/no_copy,$
                         /no_check,_extra=extra)
    endif
   endif
  endif
 endfor
endif

;-- bail out if not found

if (tag_no eq -1) then return,new_struct

;-- replace at main level

found=1b
tag_value=new_struct.(tag_no)
temp_struct=rem_tag(new_struct,tag_no,err=err)
if err eq '' then new_struct=add_tag(temp_struct,tag_value,new_name,$
                             index=tag_no-1,err=err,_extra=extra)

if err eq '' then return,new_struct else return,struct

end


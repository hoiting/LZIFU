;+
; Project     :	SDAC
;
; Name        :	REP_TAG_VALUE
;
; Purpose     :	replace tag value in a structure
;
; Use         : NEW_STRUCT=REP_TAG_VALUE(STRUCT,TAG_VALUE,TAG_NAME)
;
; Inputs      :	STRUCT = input structure
;             : TAG_VALUE = value to give tag
;             : TAG_NAME = string tag name to modify (or index value)
;
; Outputs     :	NEW_STRUCT = new structure
;
; Keywords    :	NO_COPY = do not make copy of input TAG_VALUE
;                         (it will be destroyed after input)
;               NO_ADD  = do not add new tag if not present
;               RECURSE = recurse on structure tags
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
;                       Fixed recursion problem, added /NO_ADD
;                       Disabled NAME keyword
;               Modified, 1-Dec-02, Zarro (EER/GSFC) 
;                       Made NO_RECURSE the default
;               Modified, 25-Dec-04, Zarro (L-3Com/GSFC)
;                       Vectorized
;               Modified, 20-May-08, Zarro (ADNET)
;                       Added /VERBOSE, made QUIET the default
;
;-

function rep_tag_value,struct,tag_value,tag_name,err=err,$
                       verbose=verbose,found=found,$
                       no_add=no_add,recurse=recurse,$
                       no_check=no_check,_extra=extra

err=''
found=0b
verbose=keyword_set(verbose)
recurse=keyword_set(recurse)
no_add=keyword_set(no_add)
do_check=1-keyword_set(no_check)

;-- skip checks for speed

if do_check then begin

 if (n_params() eq 0) or (not exist(tag_value)) or (not exist(tag_name)) then begin
  err='invalid inputs'
  pr_syntax,'new_struct=rep_tag_value(struct,tag_value,tag_name)'
  if exist(struct) then return,struct else return,-1
 endif

;-- tag name must be scalar string name or index position
                                                  
 if n_elements(tag_name) ne 1 then begin
  err='restricted to replacing single tag values'
  if verbose then message,err,/cont
  if exist(struct) then return,struct else return,-1
 endif

 if (not is_number(tag_name)) and (not is_string(tag_name)) then begin
  err='replacement tag name must be string or index'
  if verbose then message,err,/cont
  if exist(struct) then return,struct else return,-1
 endif
endif

;-- check if string tag_name exists at any level. If it doesn't then
;   we add it at main level (unless /NO_ADD is set)

if (not is_struct(struct)) then begin
 if no_add then begin
  if exist(struct) then return,struct else return,-1
 endif else return,add_tag(struct,tag_value,tag_name,_extra=extra)
endif

tags=tag_names(struct) & ntags=n_elements(tags)
if is_string(tag_name) then begin
 if not have_tag(struct,tag_name,/exact) and (not recurse) then begin
  if no_add then begin
   err='no such tag name at main level- '+tag_name
   if verbose then message,err,/cont
   if exist(struct) then return,struct else return,-1
  endif else return,add_tag(struct,tag_value,tag_name,_extra=extra)
 endif
 str_tag_name=strup(tag_name)
 tag_no=tag_index(struct,str_tag_name)
endif else begin
 tag_no=get_tag_index(struct,tag_name,/valid,err=err)
 if (err ne '') or (tag_no lt 0) then begin
  if (err ne '') and verbose then message,err,/cont
  if exist(struct) then return,struct else return,-1
 endif
 str_tag_name=tags[tag_no]
endelse
          
;-- replace by finding index location of value, removing tag value at
;   that location, and then adding new value in its place

;-- do recursive replace first. If tag to be replaced is a structure, then
;   we skip recursing since we replace it later

found_it=0b
new_struct=struct
if recurse then begin
 for k=0,ntags-1 do begin
  err=''
  if (k ne tag_no) then begin     
   if is_struct(new_struct[0].(k)) then begin
    tstruct=rep_tag_value(new_struct.(k),tag_value,str_tag_name,$
                         err=err,/no_add,/no_check,/recurse,$
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

;-- bail out if not found and not adding

if (tag_no eq -1) then begin
 if found_it then no_add=1b
 if no_add then return,new_struct else $
  return,add_tag(new_struct,tag_value,str_tag_name,err=err,_extra=extra)
endif

;-- replace at main level


found=1b
temp_struct=rem_tag(new_struct,tag_no,err=err)
if err eq '' then new_struct=add_tag(temp_struct,tag_value,str_tag_name,$
                             index=tag_no-1,err=err,_extra=extra)

if err eq '' then return,new_struct else return,struct


end




















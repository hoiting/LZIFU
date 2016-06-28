;+
; Project     :	SDAC
;
; Name        :	ADD_TAG
;
; Purpose     :	add a tag to a structure
;
; Use         : NEW_STRUCT=ADD_TAG(STRUCT,TAG,TAG_NAME)
;
; Inputs      :	STRUCT = input structure (array or scalar)
;             : TAG_VALUE = tag variable to add 
;             : TAG_NAME = tag name 
;
; Outputs     :	NEW_STRUCT = new structure
;
; Opt. Outputs:	None.
;
; Keywords    :	NAME = new name for structure
;               INDEX = index or tag name where to append new tag [def = last]
;               ERR   = error message [blank if ok]
;               DUPLICATE = set to allow duplicate tag names
;		TOP_LEVEL = If set, then only the top level is searched to
;			    determine if the tag already exists.
;               NO_COPY = do not make copy of input TAG variable
;                         (it will be destroyed after input)
;
; Restrictions:	Cannot add more than one tag at a time
;
; Category    :	Structure handling
;
; Written     :	Dominic Zarro (ARC)
;               
; Version     :	Version 1.0, 7 November 1994 -- written
;               Version 2.0, 16 June 1996    -- cleaned up
;		Version 3, 11-Aug-1997, William Thompson, GSFC
;			Added keyword TOP_LEVEL
;		Version 4 8-Oct-1998, Zarro (SMA/GSFC) - converted to using
;                       CREATE_STRUCT
;-
;----------------------------------------------------------------------------

function add_tag_err,val,err
mess='syntax --> NEW_STRUCT=ADD_TAG(STRUCT,TAG_VALUE,TAG_NAME)'
err=mess & message,err,/cont
if exist(val) then return,val else return,0
end

;----------------------------------------------------------------------------

function add_tag2,struct,tag_value,tag_name,name=name,index=index,err=err,$
                 duplicate=duplicate,top_level=top_level,no_copy=no_copy,$
                 quiet=quiet

on_error,1

err=''
if not exist(tag_value) then return,add_tag_err(struct,err)
if datatype(name) ne 'STR' then name=''

;-- just tag value and name entered

new_struct=-1
if  (n_params() eq 2) then begin
 if (datatype(tag_value) eq 'STR') then begin
  if (trim(tag_value) ne '') then begin
   if datatype(struct) ne 'STC' then begin
    new_struct=create_struct(tag_value,struct,name=name)
    goto,done
   endif
  endif
 endif 
 return,add_tag_err(struct,err)
endif

;-- no tag name was entered

if datatype(tag_name) eq 'STR' then tname=tag_name else tname=''
tname=strtrim(tname(0),2)
if tname eq '' then begin
 err='tag name must be non-blank string'
 message,err,/cont
 if exist(struct) then return,struct else return,0
endif
tname=strupcase(tname)

if n_elements(tname) ne 1 then begin
 err='restricted to adding one tag at a time'
 message,err,/cont
 if exist(struct) then return,struct else return,0
endif

;-- input structure undefined

if (datatype(struct) ne 'STC') and exist(tag_value) then begin
 new_struct=create_struct(tname,tag_value,name=name)
 goto,done
endif

;-- does tag already exist

verbose=1-keyword_set(quiet)
idl5=idl_release(lower=5)
if (not keyword_set(duplicate) or idl5) then begin
 if datatype(struct) eq 'STC' then begin
  if tag_exist(struct,tname,top_level=top_level) then begin
   if idl5 and verbose then message,'duplicate tag - '+tname+' - not added',/cont
   return,struct
  endif
 endif
endif

;-- determine location of added tag

tags=tag_names(struct)
ntags=n_elements(tags)
aindex=ntags-1
if exist(index) then begin
 if datatype(index) eq 'STR' then begin
  ilook=where(strupcase(trim(index)) eq tags,icount)
  if icount gt 0 then aindex=ilook(0)
 endif else aindex=index(0)
endif
aindex= -1 > (aindex+1) < (ntags-1)
no_copy=keyword_set(no_copy)

temp=create_struct(tname,tag_value)
delvarx,new_struct
for k=0,n_elements(struct)-1 do begin
 delvarx,temp_struct
 case 1 of
  aindex ge (ntags-1): temp_struct=create_struct(struct(k),tname,tag_value,name=name)
  (aindex le 0): temp_struct=create_struct(tname,tag_value,struct(k),name=name)
  else: begin
   split_struct,struct(k),aindex,s1,s2
   temp_struct=create_struct(s1,temp,s2,name=name)
  end
 endcase
 new_struct=merge_struct(new_struct,temp_struct)
endfor

if keyword_set(no_copy) then delvarx,tag_value

done: delvarx,temp_struct

return,new_struct & end



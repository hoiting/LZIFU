;+
; Project     :	SOHO - CDS
;
; Name        :	CONCAT_STRUCT
;
; Purpose     :	concatanate two structures
;
; Explanation :	concatanates two structures by using COPY_STRUCT to
;               avoid the problem of concatanating two differently named
;               structures.
;
; Use         : NEW_STRUCT=CONCAT_STRUCT(STRUCT1,STRUCT2)
;
; Inputs      :	STRUCT1,2 = input structures
;
; Opt. Inputs :	None.
;
; Outputs     :	NEW_STRUCT = concatanated structure
;
; Opt. Outputs:	None.
;
; Keywords    :	ERR = err string
;               NOTAG_CHECK = don't check if tag names match.
;               NONEST_CHECK = don't check if nested elements differ
;
; Category    :	Structure handling

; History     :	22 September 1994, Zarro (ARC) - written
;               22 April 2006, Zarro (L-3Com/GSFC) - improved with STRUCT_ASSIGN
;
; Contact     :	dzarro@solar.stanford.edu
;-


function concat_struct,struct1,struct2,_extra=extra,err=err,$
         notag_check=notag_check,nonest_check=nonest_check,$
         no_copy=no_copy

no_copy=keyword_set(no_copy)

err=''
if (1-is_struct(struct1)) or (1-is_struct(struct2))  then begin
 if is_struct(struct1) then return,struct1
 if is_struct(struct2) then return,struct2
 err='invalid input structures'
 message,err,/cont
 return,0
endif

s1=tag_names(struct1,/struct)
s2=tag_names(struct2,/struct)

;-- do the obvious first

if (s1 eq s2) and (s1 ne '') then return,[struct1,struct2]

dim1=get_max_tag(struct1,/nest)
dim2=get_max_tag(struct2,/nest)
n1=n_elements(struct1)
n2=n_elements(struct2)

;-- try STRUCT_ASSIGN 

if since_version('5.1') then begin
 if dim1 gt dim2 then temp=struct1[0] else temp=struct2[0]
 temp1=replicate(temp,n1) & temp2=replicate(temp,n2)
 struct_assign,struct1,temp1 & struct_assign,struct2,temp2
 if no_copy then delvarx,struct1,struct2
 return,[temporary(temp1),temporary(temp2)]
endif

;-- rest is for backwards compatibility

if (1-keyword_set(notag_check)) then begin
 smatch=match_struct(struct1,struct2,/tags) 
 if not smatch then begin
  err='Input structures do not have matching tag names'
  message,err,/cont
  return,struct1
 endif
endif

new_struct=0
 
;-- if input structures have identical nested elements, then faster
;   to merge directly without using COPY_STRUCT

nonest=keyword_set(nonest_check)
if nonest then return,merge_struct(struct1,struct2,/notag,/nocheck)

;-- make sure destination structure can accomodate source

if dim1 eq dim2 then begin
 if n1 lt n2 then begin
  temp_struct=replicate(clear_struct(struct2(0)),n1)
  copy_struct,struct1,temp_struct
  new_struct=[temporary(temp_struct),struct2]
 endif else begin
  temp_struct=replicate(clear_struct(struct1(0)),n2)
  copy_struct,struct2,temp_struct
  new_struct=[struct1,temporary(temp_struct)]
 endelse
endif else begin
 if dim1 gt dim2 then new_struct=replicate(struct1(0),n1+n2) else $
  new_struct=replicate(struct2(0),n1+n2) 
 dprint,'% CONCAT_STRUCT: looping...',n1
 temp=new_struct(0)
 for i=0,n1-1 do begin
  copy_struct,struct1(i),temp,_extra=extra & new_struct(i)=temp
 endfor

 for i=n1,n1+n2-1 do begin
  copy_struct,struct2(i-n1),temp,_extra=extra & new_struct(i)=temp
 endfor

endelse

if no_copy then delvarx,struct1,struct2

return,new_struct & end


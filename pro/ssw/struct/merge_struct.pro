;+
; Project     :	SOHO - CDS
;
; Name        :	MERGE_STRUCT
;
; Purpose     :	merge/concatanate two structures
;
; Explanation :	concatanates two structures by using CREATE_STRUCT to
;               ensure that input structures have the same name and, thus, 
;               avoid the problem of concatanating two differently named
;               structures. 
;
; Use         : NEW_STRUCT=MERGE_STRUCT(STRUCT1,STRUCT2)
;
; Inputs      :	STRUCT1,2 = input structures
;
; Outputs     :	NEW_STRUCT = concatanated structure
;
; Opt. Outputs:	None.
;
; Keywords    :	ERR = err string
;               NOTAG_CHECK = don't check if tag names match.
;               NOCHECK = skip input checking
;
; Category    :	Structure handling
;
; Written     :	1-Apr-1999, Zarro (SAC/GSFC)
;
; Modified    : 31-July-2001, Zarro (EITI/GSFC) - use faster STRUCT_ASSIGN 
;               to avoid and handle variable sized tags
;               20-Dec-2002, Zarro (EER/GSFC) - take advantage of relaxed
;               structure assignment
;               1-Feb-2007, Zarro (ADNET/GSFC) - disabled /RELAXED
;
; Contact     : dzarro@solar.stanford.edu
;
;-

function merge_struct,struct1,struct2,err=err,notag_check=notag_check,$
                nocheck=nocheck,_extra=extra,relaxed=relaxed

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
 err='Error merging structures'
 message,err,/cont
 return,0
endif

relaxed=keyword_set(relaxed)
if ((s1 eq s2) and (s1 ne '')) or (relaxed and since_version('5.4')) then return,[struct1,struct2]

;-- use faster, better, cheaper STRUCT_ASSIGN

if since_version('5.3') then begin
 n1=n_elements(struct1)
 n2=n_elements(struct2)
 temp=create_struct(struct1[0],name='')
 temp1=replicate(temp,n1)
 temp2=replicate(temp,n2)
 call_procedure,'struct_assign',struct1,temp1,_extra=extra
 call_procedure,'struct_assign',struct2,temp2,_extra=extra
 return,[temporary(temp1),temporary(temp2)]
endif

case 1 of
 (s1 eq '') and (s2 ne ''): begin
   name=s2
   for i=0,n_elements(struct1)-1 do begin
    temp=create_struct(struct1(i),name=s2)
    if i eq 0 then new=temporary(temp) else new=[temporary(new),temporary(temp)]
   endfor
   return,[temporary(new),struct2]
  end
 (s2 eq '') and (s1 ne ''): begin
   name=s1
   for i=0,n_elements(struct2)-1 do begin
    temp=create_struct(struct2(i),name=s1)
    if i eq 0 then new=temporary(temp) else new=[temporary(new),temporary(temp)]
   endfor
   return,[struct1,temporary(new)]
  end
 else: begin
  sname=make_str(1,/noexe)
  for i=0l,n_elements(struct1)-1l do begin
   temp=create_struct(struct1(i),name=sname)
   if i eq 0 then new1=temporary(temp) else new1=[temporary(new1),temporary(temp)]
  endfor
  for i=0l,n_elements(struct2)-1l do begin
   temp=create_struct(struct2(i),name=sname)
   if i eq 0 then new2=temporary(temp) else new2=[temporary(new2),temporary(temp)]
  endfor
  return,[temporary(new1),temporary(new2)]
 end
endcase

end

;+
; Project     :	SDAC
;
; Name        :	JOIN_STRUCT
;
; Purpose     :	join two structures
;
; Explanation :	
;
; Use         : NEW_STRUCT=JOIN_STRUCT(S1,S2)
;
; Inputs      :	S1,S2 input structures
;
; Opt. Inputs :	None.
;
; Outputs     :	NEW_STRUCT = new structure
;
; Opt. Outputs:	None.
;
; Keywords    :	NAME = new name for structure
;               DUPLICATE = keep duplicate tag names
;
; Restrictions:	Input structures must have same dimension
;
; Side effects:	None.
;
; Category    :	Structure handling
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC), 7 November 1994
;               Modified, 9 April 1997, Zarro (ARC), added DUPLICATE
;               Modified, 19 Sept 1997, Zarro (SAC), removed CREATE_STRUCT
;               Modified, 16 Oct 1998, Zarro (SAC), restored use of CREATE_STRUCT
;               Modified, 19 Oct 1998, Zarro (SAC), fixed bug with input structure arrays
;               Modified, 2 Nov 1999, Zarro (SM&A), allowed duplicate tag names
;                for anonymous structures
;               Modified, 22 March 00, Zarro (SM&A), reduced # of calls to
;                DATATYPE
;               10-Jan-03, Zarro (EER/GSFC)- added call to improved 
;                JOIN_STRUCT for newer versions of IDL.
;
;-


function join_struct2,s1,s2,name=name,duplicate=duplicate,err=err

err=''

d_s1=datatype(s1) & d_s2=datatype(s2)
if (d_s1 ne 'STC') and (d_s2 ne 'STC') then begin
 pr_syntax,'new_struct=join_struct(s1,s2,name=name)'
 return,0
endif

if (d_s1 ne 'STC') and (d_s2 eq 'STC') then return,s2
if (d_s2 ne 'STC') and (d_s1 eq 'STC') then return,s1

if (n_elements(s1) ne n_elements(s2)) then begin
 message,'input structures must have same dimensions',/cont
 return,0
endif

if datatype(name) ne 'STR' then name='' else name=trim(name)

;-- any duplicates?

nstruct=n_elements(s1)
t1=tag_names(s1)
t2=tag_names(s2)
tags=[t1,t2]
rs=uniq([tags],sort([tags]))
utags=tags(rs) 
has_dup=n_elements(utags) ne n_elements(tags) 
no_dup=1-keyword_set(duplicate)
idl5=idl_release(lower=5,/inc)
idl4=idl_release(upper=4,/inc)
anon=name eq ''
allow_dup=idl4 or (idl5 and anon)
rem_dup=has_dup and (no_dup or not allow_dup)
          
if has_dup then begin
 if not allow_dup then dprint,'% JOIN_STRUCT: duplicate tags not allowed'
 for k=0,nstruct-1 do begin
  if rem_dup then begin
   p1=pair_struct(s1(k),'s1')
   p2=pair_struct(s2(k),'s2')
   p3=p1
   for i=0,n_elements(t2)-1 do begin
    chk=where(t2(i) eq t1,count)
    if count eq 0 then p3=append_arr(p3,p2(i))
   endfor
   new_struct=merge_struct(new_struct,$
              exec_struct(p3,name=name,s2=s2(k),s1=s1(k)))
  endif else begin
   p1=pair_struct(s1(k),'s1',/equal,/duplicate)
   p2=pair_struct(s2(k),'s2',/equal,/duplicate)
   p3=p1+','+p2
   state='temp_struct=make_struct('+p3+')'
   status=execute(state)
   if status then new_struct=merge_struct(new_struct,temp_struct)
  endelse
  
 endfor
endif else begin
; dprint,'% JOIN_STRUCT: using CREATE_STRUCT'
 for k=0,nstruct-1 do begin
  new_struct=merge_struct(new_struct,create_struct(s1(k),s2(k),name=name))
 endfor
endelse

return,new_struct & end


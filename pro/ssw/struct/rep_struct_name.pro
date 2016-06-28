;+
; Project     :	SDAC
;
; Name        :	REP_STRUCT_NAME
;
; Purpose     :	Replace structure name 
;
; Use         : NEW_STRUCT=REP_STRUCT_NAME(STRUCT,NEW_NAME)
;
; Inputs      :	STRUCT = input structure
;             : NEW_NAME= new structure name
;
; Outputs     :	NEW_STRUCT = new structure
;
; Category    :	Structure handling
;
; Written     : 7 July 1995, Zarro (ARC/GSFC)
;
; Modified    : 4 Jan 2005, Zarro (L-3Com/GSFC) - vectorized
;-

function rep_struct_name,struct,new_name

if (not is_struct(struct)) then begin
 pr_syntax,'NEW_STRUCT=REP_STRUCT_NAME(STRUCT,NEW_NAME)'
 if exist(struct) then return,struct else return,-1
endif

;-- check if same name

cur_name=strupcase(trim(tag_names(struct,/struct)))
if is_string(new_name) then sname=new_name else sname=''
sname=strup(sname)
if cur_name eq sname then return,struct

;-- check if new name is unique

status=1b
if sname ne '' then status=chk_struct_name(sname,temp=temp)

if (not status) and is_struct(temp) and (sname ne '') then begin
 if not match_struct(struct,temp,/type) then begin
  message,'Structure type already defined: '+new_name,/cont
  return,struct
 endif
endif

new_struct=create_struct(struct[0],name=sname)
nstruct=n_elements(struct)
if nstruct gt 1 then begin
 new_struct=replicate(new_struct,nstruct)
 struct_assign,struct,new_struct,/nozero
endif

return,new_struct

end


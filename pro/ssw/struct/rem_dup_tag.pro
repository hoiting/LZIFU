;+
; Project     :	SDAC
;
; Name        :	REM_DUP_TAG
;
; Purpose     :	remove duplicate tags from a structure
;
; Explanation :	
;
; Use         : NEW_STRUCT=REM_DUP_TAG(STRUCT)
;
; Inputs      :	STRUCT = input structure (array or scalar)
;
; Opt. Inputs :	None.
;
; Outputs     :	NEW_STRUCT = new structure
;
; Opt. Outputs:	None.
;
; Keywords    :	NAME = new name for output structure
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Structure handling
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC), April 7, 1997
;		Version 1.1: Fixed vectorization bug. Craig DeForest (Stanford), May 13, 1997
;		Version 2, 14 Oct 1998, Zarro -- converted to CREATE_STRUCT
;
; Version     :	Version 2
;-

function rem_dup_tag,s,name=name

if (datatype(s) ne 'STC') then begin
 message,'syntax --> NEW_STRUCT=REM_DUP_TAG(STRUCT)',/cont
 if exist(struct) then return,struct else return,0
endif

;-- any duplicates?

tags=tag_names(s)
rs=uniq([tags],sort([tags]))
utags=tags(rs) 
if n_elements(utags) eq n_elements(tags) then return,s

for k=0,n_elements(s)-1 do begin
 pairs=pair_struct(s(k))
 temp_struct=exec_struct(pairs,s=s(k),err=err,name=name)
 if err eq '' then new_struct=merge_struct(new_struct,temp_struct)
endfor

delvarx,temp_struct

return,new_struct & end



;+
; Project     :	SDAC
;
; Name        :	REM_ANON_TAG
;
; Purpose     :	Find and remove anonymous structure tags from within structure
;
; Explanation :	Need this to enable concatanating structures
;
; Use         : NEW_STRUCT=REM_ANON_TAG(STRUCT)
;
; Inputs      :	STRUCT = input structure
;
; Opt. Inputs :	None.
;
; Outputs     :	NEW_STRUCT = new structure
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
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
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 7 June 1997
;-

function rem_anon_tag,struct,name=name,verbose=verbose

if (datatype(struct) ne 'STC') then begin
 message,'syntax --> NEW_STRUCT=REM_ANON_TAGS(STRUCT)',/cont
 if exist(struct) then return,struct else return,0
endif
verb=keyword_set(verbose)

tags=tag_names(struct) & ntags=n_elements(tags)
for k=0,n_elements(struct)-1 do begin
 temp_struct=struct(k)
 for i=0,ntags-1 do begin
  tag_value=struct(k).(i)
  tag_name=tags(i)
  if datatype(tag_value) eq 'STC' then begin
   stc_name=tag_names(tag_value,/struct)
   if stc_name eq '' then begin
    if verb then message,'removing anonymous tag - '+tag_name,/cont
    temp_struct=rem_tag(temp_struct,tag_name)
   endif else begin
    no_anon=rem_anon_tag(tag_value)
    temp_struct=rep_tag_value(temp_struct,no_anon,tag_name)
   endelse
  endif
 endfor
 new_struct=merge_struct(new_struct,temp_struct)
endfor

new_struct=rep_struct_name(new_struct,name)
delvarx,temp_struct

return,new_struct & end


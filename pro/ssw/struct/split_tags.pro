;+
; Project     :	SDAC
;
; Name        :	SPLIT_TAGS
;
; Purpose     :	split duplicate tags from a structure
;
; Explanation :	
;
; Use         : split_tags,struct,s1,s2
;
; Inputs      :	struct = input structure (array or scalar)
;
; Opt. Inputs :	None.
;
; Outputs     :	s1,s2 = new structures with unique tags
;
; Opt. Outputs:	None
;
; Keywords    :	None
;
; Common      :	None
;
; Restrictions:	None
;
; Side effects:	None
;
; Category    :	Structure handling
;
; Written     :	Dominic Zarro (SMA/GSFC), Jan 4, 1998
;
; Contact     : zarro@smmdac.nascom.nasa.gov
;-

pro split_tags,s,s1,s2

on_error,1

delvarx,s1,s2

if (datatype(s) ne 'STC') then begin
 message,'syntax --> split_tags,s,s1,s2',/cont
 return
endif

;-- cycle thru each tag and build-up new structures

tags=tag_names(s)
for i=0,n_elements(tags)-1 do begin
 if not have_tag(s1,tags(i)) then s1=add_tag(s1,s.(i),tags(i)) else $
  if not have_tag(s2,tags(i)) then s2=add_tag(s2,s.(i),tags(i))
endfor

return & end



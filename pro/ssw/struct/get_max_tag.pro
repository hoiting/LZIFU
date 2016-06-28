;+
; Project     :	SOHO - CDS
;
; Name        :	GET_MAX_TAG
;
; Purpose     :	find max dimension of a tag in a structure
;
; Use         : MAX=GET_MAX_TAG(STRUCT)
;
; Inputs      :	STRUCT = input structure
;
; Opt. Inputs :	None.
;
; Outputs     :	MAX = max dimension of tags
;
; Opt. Outputs:	None.
;
; Keywords    :	NEST = check nested structure dimensions only
;
; Category    :	Structure handling
;
; History     :	22 May 1995, Zarro (ARC) - written
;               22 April 2006, Zarro (L-3Com/GSFC) - modified to use
;                                                    IS_STRUCT
; Contact     :	dzarro@solar.stanford.edu
;-

function get_max_tag,struct,nest=nest

if (1-is_struct(struct)) then begin
 message,'syntax --> MAX = GET_MAX_TAG(STRUCT)',/cont
 return,0
endif

tags=tag_names(struct)
nest=keyword_set(nest)

ndim=0

check_it=1
for i=0,n_elements(tags)-1 do begin
 if nest then check_it=is_struct(struct[0].(i))
 if check_it then ndim=n_elements(struct[0].(i)) > ndim
endfor

return,ndim & end


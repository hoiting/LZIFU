;+
; Project     :	HESSI
;
; Name        :	stc_uniq
;
; Purpose     :	return unique structures from an array
;
; Category    :	Structure handling
;
; Syntax      : IDL> output=stc_uniq(input)
;
; Inputs      :	INPUT = input structure array
;
; Outputs     :	OUTPUT = array of unique structures
;
; Optional Out: SORDER = sorted indicies
;
; Keywords    :	EXCLUDE = tag names to exclude
;
; Restrictions: Structure elements cannot be arrays or structures
;
; Written     : Zarro (EIT/GSFC), 10 July 2001
;
; Contact     : dzarro@solar.stanford.edu
;-

function stc_uniq,input,sorder,_extra=extra

if size(input,/tname) ne 'STRUCT' then return,-1

if n_elements(input) eq 1 then return,input

sum=stc_sum(input,_extra=extra)

if is_blank(sum[0]) then return,-1

new=get_uniq(sum,sorder,_extra=extra)

return,input[sorder]

end



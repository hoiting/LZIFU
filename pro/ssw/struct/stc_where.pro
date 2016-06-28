;+
; Project     :	HESSI
;
; Name        :	stc_where
;
; Purpose     :	Fast, cheap WHERE function for structures
;
; Category    : Structure handling
;
; Syntax      : IDL> chk=stc_where(input,structs)
;
; Inputs      :	INPUT = input structure array to test
;               STRUCTS = structure array to test against
;
; Outputs     :	CHK = indicies where INPUT matches STRUCTS
;
; Keywords    :	EXCLUDE = tag names to exclude
;               COUNT = # of matches
;
; Restrictions: Structure elements cannot be arrays, structures, pointers, or
;               objects
;
; Written     : Zarro (EIT/GSFC), 13 Aug 2001
;
; Contact     : dzarro@solar.stanford.edu
;-

function stc_where,input,structs,_extra=extra,count=count

count=0
if size(input,/tname) ne 'STRUCT' then return,-1
if size(structs,/tname) ne 'STRUCT' then return,-1

if (n_elements(input) ne 1) and (n_elements(structs) ne 1) then begin
 message,'at least one input structure must be scalar',/cont
 return,-1
endif


sum1=stc_sum(input,_extra=extra,/skip)
sum2=stc_sum(structs,_extra=extra,/skip)

if is_blank(sum1) or is_blank(sum2) then return,-1

chk=where(sum1 eq sum2,count)

if count eq 1 then chk=chk[0]
return,chk
end


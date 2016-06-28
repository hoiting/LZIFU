;+
; Project     :	HESSI
;
; Name        :	stc_compress
;
; Purpose     :	compress all string fields in a structure
;
; Category    :	Structure handling
;
; Syntax      : IDL> output=stc_compress(input)
;
; Inputs      :	INPUT = input structure array
;
; Outputs     :	OUTPUT = array of compressed string structures
;
; Keywords    :	REM = compress all whitespace
;               NO_COPY = don't make new copy of input
;
; Written     : Zarro (EIT/GSFC), 10 AUG 2001
;
; Contact     : dzarro@solar.stanford.edu
;-

function stc_compress,input,_extra=extra,no_copy=no_copy

if size(input,/tname) ne 'STRUCT' then return,-1

if keyword_set(no_copy) then output=temporary(input) else output=input

tags=tag_names(output)
ntags=n_elements(tags)
for i=0,ntags-1 do begin
 type=size(output.(i),/tname)
 if type eq 'STRING' then output.(i)=strcompress(strtrim(output.(i),2),_extra=extra)
 if type eq 'STRUCT' then output.(i)=stc_compress(output.(i),_extra=extra)
endfor

return,output

end



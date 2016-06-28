;+
; Project     :	HESSI
;
; Name        :	is_byte
;
; Purpose     :	returns, 1/0 if input is a byte variable, or not
;
; Category    :	util
;
; Syntax      : IDL> output=is_byte(input)
;
; Inputs      :	INPUT = input structure array
;
; Outputs     :	OUTPUT = 1/0
;
; Written     : 17 January, 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-


function is_byte,input

sz=size(input)
return,sz[n_elements(sz)-2] eq 1

end

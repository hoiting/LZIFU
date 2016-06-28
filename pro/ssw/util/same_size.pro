;+
; Project     : Hinode/EIS
;
; Name        : SAME_SIZE
;
; Purpose     : Fast check if two arrays have the same dimensions
;
; Category    : imaging util
;
; Syntax      : IDL> same=same_size(a,b)
;
; Inputs      : A,B = input arrays
;
; Outputs     : 1/0 if same dimensions or not
;
; Keywords    : None
;
; History     : Written, 8 May 2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford

function same_size,a,b

sa=size(a,/dimension)
sb=size(b,/dimension)
return,array_equal(sa,sb)

end

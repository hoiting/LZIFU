;+
; Project     : RHESSI
;
; Name        : REPLICATE2
;
; Purpose     : same as REPLICATE, but accepts vector dimensional input
;
; Category    : utility
;
; Syntax      : IDL> output=replicate2(input,dims)
;
; Inputs      : INPUT = input array
;               DIMS = vector of dimensions to replicate to, e.g., [2,3,4]
;
; Outputs     : OUTPUT = replicated input
;
; Keywords    : None
;
; History     : 2-Feb-2005,  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function replicate2,input,dims

if not exist(input) then return,-1
if not exist(dims) then return,input

;-- simple single dimension case

if n_elements(dims) eq 1 then begin
 if dims[0] le 1 then return,input
 return,replicate(input,dims[0])
endif

;-- use new version if appropriate

if since_version('5.5') then return,replicate(input,dims)

;-- have to use reform since old version replicate doesn't support vector
;   dimensions

np=product(dims)
return,reform(replicate(input,np),dims)

end


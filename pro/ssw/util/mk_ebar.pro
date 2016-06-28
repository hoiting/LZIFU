;+
; NAME:
;	mk_ebar
; PURPOSE:
;	to compute error bars for a set of data arrays
; CALLING SEQUENCE:
;	ebar=mk_ebar(a1,a2,a3,a4,a5,a6,a7,a8,a9,10)
; INPUTS:
;	a= input arrays
; OUTPUTS:
;	ebar = uncertainty array
; KEYWORDS:
;       amean = mean of input arrays
; RESTRICTIONS:
;       can handle up to 10 dimensions
; PROCEDURE:
;       takes average of each element in input vector
; MODIFICATION HISTORY:
;	Written by DMZ (ARC) March 1994
;-

function mk_ebar,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,amean=amean

on_error,1

;-- read command line for input vectors


npar=n_params()
if (npar gt 10) or (npar lt 1) then begin
 message,'usage ---> EBAR = MK_EBAR(A1, A2, A3.....)',/cont
 return
endif

np=n_elements(a1)
amean=0.
infinity=99999999.
vmax=replicate(-infinity,np)
vmin=replicate(infinity,np)

for i=0,npar-1 do begin
 s=execute('v = a'+strtrim(string(i+1),2))
 if (s ne 0) then begin
  nv=n_elements(v)
  if nv ne np then begin
   message,'incompatible size for input vector '+string(i+1),/cont
   return
  endif
  amean=amean+v
  vmax = vmax > v
  vmin = vmin < v
 endif
endfor
amean=amean/npar

ebar=[[vmax-amean],[amean-vmin]]

return,ebar
end



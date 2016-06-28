function sxpar2, h, name
;+
;NAME:
;	sxpar2
;PURPOSE:
;	Allow a 2-D array to have the keyword extracted
;SAMPLE CALLING SEQUENCE:
;	out = sxpar2(h, 'REFTIME')
;HISTORY:
;	Written 23-May-96 by M.Morrison
;-
;
if (data_type(h) ne 7) then return, -1		;must be string type
;
n = n_elements(h(0,*))
out0 = sxpar(h(*,0), name)
out = replicate(out0, n)
if (!err eq -1) then return, out		;there was an error
;
for i=1,n-1 do out(i) = sxpar(h(*,i), name)
return, reform(out)
end

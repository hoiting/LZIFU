function  sumit,zz
;+
; NAME:
;	SUM
; PURPOSE:
;  	Function to do a 1-d summation of a 2-d data set.
; CALLING SEQUENCE:  
;	out = SUMIT(in)
; INPUTS:
;	in	2-d input array
; OUTPUTS:
;	out	1-d summation of array
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;	RDB	1990	Emulated IDL version 1 routine
;-
ss = size(zz)
print,ss
if ss(0) eq 1  then return,zz

if ss(0) gt 2 then begin
print,'SUM only works for 2D arrays'
return,zz
endif

inum = ss(2)
cc = zz(*,0)*0
for c=0,inum-1 do cc = cc+zz(*,c)

return, cc

end

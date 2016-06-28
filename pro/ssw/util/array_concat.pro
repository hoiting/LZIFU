pro array_concat,i1,i,x,x_,x_ind,n_ind
;+
; PROJECT:
;	GENERAL
; NAME: 
;	array_concat
; PURPOSE:
;	concatenate a dynamic array with subarrays of variable lengths 
;		x0=fltarr(n0)
;		x1=fltarr(n1)
;	The concatenated array is
;		x_=[x0,x1]
;	with index ranges
;		x_(i1:i2)=xj, i1=x_ind(0,j), i2=x_ind(1,j)
; CALLING SEQUENCE:
;	array_concat,i1,i,x,x_,x_ind,n_ind
; INPUTS:
;	i1	= ID number of first subarray 
;	i	= ID number of subsequent subarrays
;	x	= subarray of any length 
; OUTPUTS:
;	x_	= concatenated array x_=[x_0,x_1,...,x_i]
;	x_ind(2,n_ind) = start and stop indices of subarrays in concatenated array
;	n_ind	= number of concatenated subarrays
; MODIFICATION HISTORY:
;	Version 1, aschwanden@lmsal.com, Written, 1999 Dec 1
;-


if (i eq i1) then begin
 x_	=x
 n	=n_elements(x)
 x_ind  =[0,n-1]
 n_ind	=1
endif
if (i gt i1) then begin
 n	=n_elements(x_)
 x_	=[x_,x]
 nn	=n_elements(x_)
 x_ind  =[[x_ind],[n,nn-1]]
 n_ind	=n_elements(x_ind)/2
endif
end

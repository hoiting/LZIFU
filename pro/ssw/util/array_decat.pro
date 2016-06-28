pro array_decat,i,x_ind,x_,x,ni
;+
; NAME: 
;	array_decat
; PURPOSE:
;	decatenates a dynamic array into subarrays of variable lengths 
;	This procedure is inverse to FWC_CONCATENATE and uses its arguments 
; CALLING SEQUENCE:
;	array_decat,i,x_ind,x_,x,ni
; INPUTS:
;	i	= ID number of subsequent subarrays
;	x_ind(2,n_ind) = start and stop indices of subarrays in concatenated array
;	x_	= concatenated array x_=[x_0,x_1,...,x_i]
; OUTPUTS:
;	x	= subarray with index i
; MODIFICATION HISTORY:
;	Version 1, aschwanden@lmsal.com, Written, 1999 Dec 1
;-

i1	=x_ind(0,i)
i2	=x_ind(1,i)
ni	=i2-i1+1
x	=x_(i1:i2)
end

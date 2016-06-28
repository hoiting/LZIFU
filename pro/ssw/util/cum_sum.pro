;+
; Project     : SDAC
;                   
; Name        : CUM_SUM 
;               
; Purpose     : This function returns the cumulative sum along
;               the first index of an array.
;               
; Category    : UTIL, MATH
;               
; Explanation : A loop is used to sum over each index in a row cumulatively.
;               
; Use         : Result = CUM_SUM( Array )
;    
; Inputs      : Array - an array of up to 8 dimensions.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns an array of the same dimensions.
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       :
;
; Common      : None
;               
; Restrictions: Uses IDL total(/cum, array, 1) if release ge 5.3
;               
; Side effects: None.
;               
; Prev. Hist  : written, richard.schwartz@gsfc.nasa.gov, 24-sep-1997
;
; Modified    : 
;       Changed to long index.  richard.schwartz@gsfc.nasa.gov, 13-oct-1998.
;       Revised to use total(/cum, array, 1) which yields the identical result
;       richard.schwartz@gsfc.nasa.gov, 1-feb-2001
;-            
;==============================================================================
function cum_sum, array

if idl_release(lower=5.3,/incl) then $
	case 1 of
	data_chk(/ndim, array): return, total(/cumulative, array)
	else:  return, total( /cumulative, array, 1)
	endcase

sa  = size(array)
nn  = sa(1:sa(0))

out = reform( array, nn(0), sa(sa(0)+2)/nn(0))

for i=1l,nn(0)-1 do out(i,*) = out(i,*)+out(i-1,*)

return, reform( out, nn) 

end

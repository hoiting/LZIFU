
;+
; Project     :	
;	SSW
; Name        :
;	IBSORT
; Purpose     :
;	Sorts integer arrays into ascending order.
; Explanation :
;	Function to sort data into ascending order, uses histogram
;	and reverse indices to maintain original order when values are equal.
;	Input must be integers, or longwords because it uses a bin size
;	of 1 to do the histogram.
;
; Use         :
;	result = ibsort( array )
;
; Inputs      :
;	Array - array to be sorted
;
; Opt. Inputs :	None.
;
; Outputs     :
;	result - sort subscripts are returned as function value
;
; Opt. Outputs:

;
; Keywords    :

;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Array
;
; Prev. Hist. :
;	Faster bsort made available by powerful sort engine of histogram
;	Meant to replace bsort for integer arrays.
;
; Written     :	Richard.Schwartz@gsfc.nasa.gov, July 2002
;
;-
;
function ibsort, a

h = histogram(a, min=min(a), max=max(a), rev=r)

w = where( h ge 1, nw)
tt = 0
b = long(a)
for ii=0,nw-1 do begin
	i = w[ii]
	b[tt:tt+h[i]-1]= r[r[i]:r[i+1]-1]
	tt = tt + h[i]
	endfor

return, b
end
;+
; Name: xy_dist
;
; Purpose: Calculate distance between points
;
; Project:  HESSI
;
; Calling Sequence:
;	result = xy_dist (p0, p)
;
; Input arguments:
;	p0 - x,y coordinates of starting point
;	p - x, y values of points to find distance from p0.  Can be (2) or (2,n)
;
; Output:
;	Result is distance between p0 and p (scalar or vector depending on p)
;
; Written: Kim Tolbert, 19-Mar-2002
; Modifications:
;
;---------------------------------------------------------------------------------
function xy_dist, p0, p

if n_elements(p0) ne 2 or n_elements(p) lt 2 then begin
	message, 'Syntax: distance = xy_dist(p0, p), p0 is 2-element array, p is (2,n)', /cont
	return, -1
endif

ret = sqrt( (p[0,*] - p0[0])^2 + (p[1,*] - p0[1])^2 )
if n_elements(ret) eq 1 then ret=ret[0] else ret=reform(ret)
return, ret

end
function fit_circle,x,y,a,radius_fix=radius_fix,tolerance=tolerance,	$
		limit_iter=limit_iter,num_iter=num_iter,not_first=not_first
;+
; NAME:
;    fit_circle
; PURPOSE:
;    Fit a circle to vector of points.
; CALLING SEQUENCE:
;    Result_vector = fit_circle(x,y,a,radius_fix=radius_fix,tolerance=tolerance)
; INPUTS:
;    x = Vector of x values
;    y = Vector of y values
; RETURNED:
;    Result_vector = [x1,y1,r1] result of coordinates (x1,y1) and radius (r1).
; OPTIONAL INPUTS:
;    a = Vector of [x0,y0,r0]  = First guesses for the circle (x0,y0,radius)
;        If a is not supplied, x0 and y0 are the averages and and r0 is 
;	 taken to be the average distance of each (x,y) point to (x0,y0).
; OPTIONAL INPUT KEYWORDS:
;    radius_fix = If set, will not vary the radius in the fit.
;    tolerance  = If present and > 0, fit_circle will recursively call itself
;		  until abs(r1-r0)/r0 < tolerance.
;                 For example, setting tolerance = 0.01 will cause the 
;		  calculation to continue until the solution for the radius
;  		  does not vary between iterations by more than 1%.
;		  If radius_fix is set, tolerance will have no effect.
;    limit_iter	= Set the upper limit to the number of times to iterate.
;		  (e.g., limit_iter=10 will limit the number of iterations
;		   to 10 or less.)
; OPTIONAL OUTPUT KEYWORDS:
;    num_iter	= Number of iterations
; MODIFICATION HISTORY:
;  17 Oct 1991, J. R. Lemen, Written (based on routine in HSH's find_limb)
;  26 Feb 1992, J. R. Lemen, Added tolerance keyword
;  24-jan-94, JRL, Added limit_iter keyword
;  19-oct-94, T. Metcalf and K. Shibasaki, Improved initial guess.  Works
;             with partial circles now.
;-

;  Calculate radius vector to each pair
if n_params() eq 0 then return,		$
	'b=f_circle(x,y,a [,/radius_fix,tolerance=tolerance]) ;a=[x0,y0,radius]'

if n_elements(a) eq 0 then begin	; Were the first guesses supplied?
  ;x0 = total(x) / n_elements(x)
  ;y0 = total(y) / n_elements(y)
  ;r0 = total(sqrt((x-x0)^2 + (y-y0)^2)) / n_elements(x)
  ;a  = [x0,y0,r0]

   ; For the initial guess, pick the three points which are furthest
   ; from each other (first point clicked is always used).  Then find
   ; the perpendicular bisector of the lines connecting these points
   ; and take the initial center as the intersection of these lines.
   ; The initial radius is the average distance of the center from the
   ; three selected points.

   ; dist. from 1st point
   d1 = sqrt((x-x(0))^2+(y-y(0))^2)  ; dist. from 1st point
   md1 = max(d1,mxp1)
   ; dist from 1st and 2nd points
   d12 = d1 + sqrt((x-x(mxp1))^2+(y-y(mxp1))^2)
   md12 = max(d12,mxp12)
   ; intermediate values
   x1 = x(0)     & y1 = y(0)
   x2 = x(mxp1)  & y2 = y(mxp1)
   x3 = x(mxp12) & y3 = y(mxp12)
   if y2 EQ y1 then begin
      ; Swap 3 and 1
      t = x1 & x1 = x3 & x3 = t
      t = y1 & y1 = y3 & y3 = t
   endif
   if y3 EQ y1 then begin
      ; Swap 2 and 1
      t = x1 & x1 = x2 & x2 = t
      t = y1 & y1 = y2 & y2 = t
   endif
   if (y2 EQ y1) OR (y3 EQ y1) then $
      message,'Error computing initial guess.  Reorder circle points.'
   x01 = float(x2-x1)
   x02 = float(x3-x1)
   y01 = float(y2-y1)
   y02 = float(y3-y1)
   mx1 = (x1+x2)/2.
   my1 = (y1+y2)/2.
   mx2 = (x1+x3)/2.
   my2 = (y1+y3)/2.
   ; compute intersection of perpendicular bisectors
   x0 = ((my1-my2) + (mx1*x01/y01 - mx2*x02/y02))/(x01/y01-x02/y02)
   y0 = my1 - (x0-mx1)*x01/y01
   ; compute mean radius
   r0 = (sqrt((x1-x0)^2 + (y1-y0)^2) + $
         sqrt((x2-x0)^2 + (y2-y0)^2) + $
         sqrt((x3-x0)^2 + (y3-y0)^2) )/3.0
   a = [x0,y0,r0]

endif

x0 = a(0)				; First guess: x0
y0 = a(1)				; First guess: y0
r0 = a(2)				; First guess: radius

dx = float(x - x0)
dy = float(y - y0)
rad = sqrt(dx^2 + dy^2)
angle = atan(dx,dy)			; returns atan(dy/dx)

;  Sort the vector into increasing angle:

order = sort(angle)
angle = angle(order)
rad   = rad(order)

;  Fit the data

rad = rad - r0
sin_fun = sin(angle)
cos_fun = cos(angle)
sin_1 = poly_fit(sin_fun, rad, 1, sin_fit)
cos_1 = poly_fit(cos_fun, rad, 1, cos_fit)

x1 = x0 + sin_1(1)
y1 = y0 + cos_1(1)
if keyword_set(radius_fix) then r1 = r0 else begin
  dx = float(x - x1)
  dy = float(y - y1)
  r1 = total(sqrt(dx^2 + dy^2)) / n_elements(x)
endelse

b = [x1,y1,r1]			; This is the new version of a

; -------------------------------------------
; Stop the iteration if limit_iter is present:
; not_first is an "internally-used" keyword- use to reset num_iter

if keyword_set(not_first) then num_iter = num_iter + 1 else num_iter = 1
if n_elements(limit_iter) ne 0 then if num_iter ge limit_iter then return,b

; If tolerance > 0 and the radius_fix keyword is not set, then
; call fit_circle recursively until the radius stops changing.
; The check is (r_new-r_old)/r_old < tolerance

if n_elements(tolerance) eq 0 then tolerance = 0
if (tolerance gt 0) and (abs((r1-r0)/r0) gt tolerance) and 	$
		    not keyword_set(radius_fix) then begin
;;print,b,abs((r1-r0)/r0),format='(3f10.4,f15.10)';***
  b = fit_circle(x,y,b,radius_fix=radius_fix,tolerance=tolerance,  $
		num_iter=num_iter,limit_iter=limit_iter,/not_first)
endif

return,b
end

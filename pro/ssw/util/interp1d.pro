 function interp1d, X0, Y0, X1, dx, missing=missing, dX=dX1, new_Y=new_Y, interp=interp
;+
; NAME:
;   interp1d
; PURPOSE:
;   Perform fast linear 1d interpolation 
;
;   Uses the IDL INTERPOLATE procedure, which requires an equally spaced grid.
;   If X0 is not equally spaced, will generate an equally spaced grid first and
;   then use INTERPOLATE to do the interpolation.
;
; CALLING SEQUENCE:
;   result = interp1d(x0,y0,x1)
;   result = interp1d(x0,y0,x1,dx,missing=missing)
;   result = interp1d(x0,y0,x1,missing=missing)
;   result = interp1d(x0,y0,x1,/interp)		; Use spline interpolation to 
;						; generate equally spaced grid
; INPUTS:
;   X0	= The absicissae values for Y0.
;   Y0  = The function to interpolate
;   x1	= The abscissae values for the result.
; OPTIONAL INPUTS:
;   dx  = The step size in X for equally spaced data.  If given,
;	  will eliminate a check to see that X0 is equally spaced.
;	  This is the fastest way to call this routine.
; OPTIONAL INPUT KEYWORDS:
;   missing = Value to points which have X1 gt max(X0) or X1 lt min(X0)
;   interp  = If set will call spline to construct linear grid if dx is
;             not specified.
; OPTIONAL OUTPUT KEYWORDS:
;   dx  = If dx is not specified, dx = abs(total(X0-X0(1:*))) / (n_elements(X0)-1)
;   new_Y = New values interpolated at dx spacing
; Returned:
;   result = a vector N_elements(X1) long 
;
; PROCEDURE:
;   This routine interpolates faster than interpol because it makes use of
;   the fact that the data interpolated by the IDL INTERPOLATE function
;   must be evenly spaced.
;
;   If dx is specified as the fourth paramter, directly interpolate.
;   If dx is not specified, compute std = std(x0(1:*)-x0, dx).  If
;         (std/dx) is lt 1.e-5, interpolate the result.
;   If dx is not specified and (std/dx) is greater than 1.e-5 then:
;      1. Construct a new grid starting at x0(0) and going in dx step sizes.
;      2. Call dspline to construct a linear grid
;      3. Then interpolate.
; RESTRICTIONS:
;   No extrapolation is performed.  If extrapolation is desired, use the
;   IDL user library INTERPOL routine.
; HISTORY:
;   31-aug-94, J. R. Lemen LPARL, Written.
;-

; How many arguments are there?

np = n_params()

if np lt 3 then begin			; Return a diagnostic message
  doc_library,'interp1d'
  message,'Must enter at least 3 parameters'

endif else if np eq 3 then begin	; No dx has been specified
  std = stdev(x0(1:*)-x0,dx1)
  if abs(std/dx1) lt 1.e-5 then begin	; This is our check for linearity in X0
     new_y = y0				; No new interpolation is necessary
  endif else begin
     x3 = x0(0) + findgen((X0(n_elements(X0)-1)-X0(0))/dx1 + 2 ) * dx1
     new_y = dspline(x0,Y0,X3,interp=keyword_set(interp))
  endelse
  x2 = ( x1 - x0(0) ) / dx1		; Grid uses the computed average step size (dx1)
  yy = interpolate(new_y,x2)

endif else begin			; dx is specified
  x2 = ( x1 - x0(0) ) / dx		; Use the provided value of dx
  yy = interpolate(y0,x2)
endelse

; Values outside of the range are set to the end points
; because interpolate does not extrapolate.
;
; This step could have been done by interpolate except that
; it doesn't work properly for the upper limit case at V3.6 and
; before.

if n_elements(missing) ne 0 then begin
  ij = where((x1 lt min(x0)) or (x1 gt max(x0)),nc)
  if nc gt 0 then yy(ij) = replicate(missing,nc)
endif

return,yy
end

;+
;    Subroutine to calculate the line center of a given spectral line
;
;
;   Input:     Line intensity
;     Optional:  pixel start value (if different from 0)
;                variable in which to return error on I (in units of I)
;                number of points on either side of minimum to fit
;                degree of polynomial fit (default = 2, the most reliable)
;                best guess for line center
;
;  For polynomial fits of order greater than 2, there may be more than
;  one real root to the equation setting the derivative to zero so there
;  may be some ambiguity about the line center.  This routine finds the
;  closest root to the minimum grid point.  Degree 2 is the most reliable
;  since there is at most one root.  The degree is required to be even
;  since this guarantees at least one real root if there is a solution
;  to the equation.
;
;        T. Metcalf   Feb 1990
;
;  3/9/90  If best_guess parameter is present fit a parabola about this
;          point rather than the minimum point
;-


function line_cent, Inten, x, pix_start = pixS, I_error = Ierr, $
                    n_points = npts, $
                    degree=ndegree, best_guess=guess, $
                    p_fit = coeff,quiet=quiet

  n = n_elements(Inten)

  if n_elements(x) EQ n then x = double(x) $
  else x = dindgen(n)
  if n_elements(pixS) GT 0 then x = x + pixS

  if n_elements(npts) EQ 0 then npts=3   ;fit 3 points on either side of minimum

  if n_elements(ndegree) EQ 0 then ndegree=2   ;  degree of polynomial fit
  coeff = fltarr(ndegree+1)
  if (ndegree LT 2) then begin
    print, 'ERROR: line_cent: Use at least a degree 2 polynomial in line_cent'
    Ierr = 0
    return,-1.
  endif
  if ((ndegree MOD 2) NE 0) then begin
    print, 'ERROR: line_cent: polynomial degree in line_cent must be EVEN'
    Ierr = 0
    return,-1.
  endif

  if (2*npts+1) LT (ndegree+1) then begin
    print, 'ERROR: line_cent: Too few data points sent, cannot find center'
    Ierr = 0
    return,-1.
  endif


  if (n_elements(guess) NE 0) then min_place=fix(guess+0.5) $ ; nearest integer
  else begin
    Isort = sort(Inten)
    min_place = Isort(0)   ; The index of the minimum array element
  end

  ;if ((min_place - npts) LT 0) then begin
  ;   npts = ((npts-min_place) > ndegree/2)
  ;   if NOT keyword_set(quiet) then $
  ;      message,/info,'Adjusting npts to '+strcompress(string(npts))
  ;endif
  if ((min_place - npts) LT 0) then begin
    if NOT keyword_set(quiet) then $
       print, 'ERROR: line_cent: Line center is too close to left edge!'
    ;Ierr = 0
    ;return,-1.
    min_place = npts
  endif
  ;if (min_place+npts GT (n-1)) then begin
  ;   npts = ((n-1-min_place) > ndegree/2)
  ;   if NOT keyword_set(quiet) then $
  ;      message,/info,'Adjusting npts to '+strcompress(string(npts))
  ;endif
  if (min_place+npts GT (n-1)) then begin
    if NOT keyword_set(quiet) then $
       print, 'ERROR: line_cent: Line center is too close to right edge!'
    ;Ierr = 0
    ;return,-1.
    min_place = n-1-npts
  endif

  subI = Inten(min_place-npts:min_place+npts)
  subX = x(min_place-npts:min_place+npts)

  coeff = poly_fit(subX,subI,ndegree,yfit,yband,Ierr,A)  ; fit the polynomial

; Minimize the resulting polynomial:

  deriv_poly = shift(coeff*dindgen(ndegree+1),-1)  ;  The derivative polynomial
  deriv_poly = deriv_poly(0:ndegree-1)

  if (ndegree gt 4) then begin
    zroots, deriv_poly, roots, 1    ; Find the roots of the derivative (min,max)
    roots = roots - x(min_place) ;the roots relative to the minimum point
    real_part = double(roots)
    order = sort(abs(real_part))
    real_part = real_part(order) ; order by abs(real part)
    imag_part = imaginary(roots(order))
    i = 0
    repeat begin   ;  Find the closest real root to the minimum point
      ;Take the real part
      if (imag_part(i) EQ 0) then center = real_part(i)+x(min_place)
      i = i + 1
    endrep until ((imag_part(i-1) EQ 0.00) or (i-1 EQ ndegree-1))
    if NOT keyword_set(quiet) then print,'high order:',center
  endif  $
  else if (ndegree eq 4) then begin ; solve cubic analytically for speed
    ; These formulae are from Numerical Recipes section 5.5
    deriv_poly = deriv_poly/deriv_poly(3)  ; normalize for these formulae
    Q = (deriv_poly(2)^2 - 3.00*deriv_poly(1))/9.000
    R = (2.00*deriv_poly(2)^3 - 9.00*deriv_poly(2)*deriv_poly(1) $
         + 27.00*deriv_poly(0))/54.00
    if ((Q^3-R^2) ge 0.000) then begin  ; Three real roots
      theta = acos(R/(Q*sqrt(Q)))
      r3 = dblarr(3)
      r3(0) = -2.00*sqrt(Q)*cos(theta/3.00) - deriv_poly(2)/3.00
      r3(1) = -2.00*sqrt(Q)*cos((theta+2.00*!pi)/3.00) - deriv_poly(2)/3.00
      r3(2) = -2.00*sqrt(Q)*cos((theta+4.00*!pi)/3.00) - deriv_poly(2)/3.00
      r3 = r3 - x(min_place)
      order = sort(abs(r3))
      center = r3(order(0)) + x(min_place)  ; Closest to min point
    endif $
    else begin   ; One real root
      center = -(R/abs(R))*( (sqrt(R^2-Q^3)+abs(R))^0.3333 $
                  + Q/((sqrt(R^2-Q^3)+abs(R))^0.3333) ) - deriv_poly(2)/3.000
    endelse
  endif $
  else if (ndegree eq 2) then begin ;If ndegree is 2, do analytically for speed
    center = -coeff(1)/(2.00*coeff(2))
  endif $
  else begin
    print,'ERROR: line_cent: ndegree must be even and greater than 0'
    return, 0.00
  endelse

  if (n_elements(center) EQ 0) then begin
    print,'ERROR: line_cent: Could not find a real root in line_cent!!'
    stop
  endif
  
  return, center

end

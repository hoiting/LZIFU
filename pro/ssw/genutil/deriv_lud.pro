;+
;
; 
;                     NUMERICAL DIFFERENTIATION: 
;
;   This subroutine calculates the derivative of a tabulated function
;   by converting an integral representation of the derivative to a 
;   matrix equation and solving this by the method of regularization 
;   (see Craig and Brown, Inverse Problems in Astronomy).
;
; ***************************************************************************
; *                                                                         *
; * pro deriv_lud, x, y, dydx, midpoints=mid, reg_param=alpha, yerror=error,* 
; *            monte_carlo=MONTE                                            *
; *                                                                         *
; ***************************************************************************
;
;   Input:   Double Arrays x[n] = x coordinate values
;                          y[n] = y coordinate values
;                      error[n] = error on y values 
;             Double      alpha = Regularization Parameter
;
;   Output:  Double Array dydx[n-1] = derivative of y at the MIDPOINTs of the
;                                     x coordiantes supplied (dimension n-1).
;                         mid[n-1]  = midpoints where dydx supplied
;                        error[n-1] = error on dydx[]
;
;   Note: on output, error is replaced by the error on dydx.
;
;   If error is undefined, no error estimation is done.  This can take 
;   alot of CPU time, but gives a good estimate of the errors by 
;   solving the matrix equation MONTE times and recording the 
;   rms deviation of the solutions.  The default value for MONTE is 0
;   so you need to set it to something like 1000 for the error
;   estimation. 
;
;   The regularization parameter (alpha) must be adjusted using the
;   error estimate.  The two numbers printed out are roughly equal 
;   when an appropriate value of the parameter has been selected.
;   Note that alpha=0 implies no smoothing.  If alpha is not input,
;   the routine will guess a value equal to the square of the mean
;   grid point spacing times the number of grid points.  If yerror is
;   set, the default regularization parameter is compute from the
;   error estimate on y.
;
;       T. Metcalf   February 1990
;       T. Metcalf   August 2001, Made some changes to get better
;                                 statistics to figure out the best
;                                 regularization parameter.
;       T. Metcalf   April 19, 2005 Make /quiet really quiet.  Use
;                                   svdc instead of the obsolete svd
;                                   routine.
;       T. Metcalf   April 20, 2005 Made a better estimate of the
;                                   regularization parameter when
;                                   yerror is specified. 
;       T. Metcalf   April 25, 2005 Slight mod to reg parameter
;                                   computation.  Error is no longer
;                                   fractional, it is the error on the
;                                   y values.
;
;-

;***************************************************

function geo, error

; Calculate the geometrical error

  n=n_elements(error)

  if (n EQ 0) then begin
    print,'Error: function geo was passed an undefined array'
    return, undefined
  endif

  geom_err = 1.00D0   ; error contains fractional error on y
  for i=0,n-1 do begin
    if ((error(i) NE 0.00)) then $
      geom_err = geom_err * abs(error(i))
  endfor

  if (geom_err EQ 0.00) then return, 0.00D0

  return, (geom_err^(1.0/n))

end  ; end of function geo

;***************************************************

function rescale, x, y

; Rescale the input of y(0)=0.  Also check to make sure that x in monotonically
; increasing.


  for i=1,(n_elements(x)-1) do begin
    if (x(i) LT x(i-1)) then begin
      print,'ERROR: x not monotonically increasing'
      stop
    endif
  endfor

  ymin = y(0)
  y = y - ymin   ; rescale y so that y(0)=0
  return, ymin

end  ; end of function rescale

;***************************************************

function get_kernel, x, y, data

;  Fill the kernel matrix and the data vector.  Note these have dimesion
;  of n-1 since I have used the trapezoidal rule for the integraton 

  n = n_elements(x)
  K = dblarr(n-1,n-1)

  data = y(1:*);

  for i=0,(n-2) do begin 
    for j=0,(n-2) do begin 
      if (j LE i) then K(i,j) = x(j+1) - x(j) else K(i,j) = 0.00
    endfor
  endfor

  return,K

end  ; end of function get_kernel

;***************************************************

function residual2, K, dydx, data

;                               2                2
;  Find the residual squared:  R  = || K f - g ||
;  using the Euclidean norm.

  Rvec = K#dydx-data
  return, total(Rvec^2)

end  ; end of function residual2

;***************************************************

function find_H, n

; Get the 2nd order smoothing matrix

  H = dblarr(n,n)
  vec = intarr(n)

  if (n LT 3) then begin
    print, 'ERROR: must be at least 3 grid points in find_H:  No smoothing'
    H = 0.00
    return, H
  endif

  for i=0,n-1 do begin
    vec(0:*) = 0
    if (i GT 1) then begin
      vec(i-2) = vec(i-2)+1
      vec(i-1) = vec(i-1)-2
      vec(i) = vec(i)+1
    endif
    if (i GT 0) and (i LT (n-1)) then begin
      vec(i-1) = vec(i-1)-2
      vec(i) = vec(i)+4
      vec(i+1) = vec(i+1)-2
    endif
    if (i LT (n-2)) then begin
      vec(i) = vec(i)+1
      vec(i+1) = vec(i+1)-2
      vec(i+2) = vec(i+2)+1
    endif
    H(i,0:*) = vec
  endfor

  return,H

end  ; end of function find_H

;***************************************************

function get_sign, n, seed

; get a vector of filled randomly with +/- 1.

  sign = intarr(n)
  for i=0,n-1 do begin
    if (randomu(seed) LE 0.500) then sign[i] = (1) else sign[i]= (-1)
  endfor

  return, sign

end ; end of function get_sign

;***************************************************

function get_error, U, W, V, K, g, error, dydx, data, MONTE
;function get_error, A, Alud, indx, g, error, dydx, data, MONTE, K

; Calculate the error on the derivative by randomly perturbing the data
; MONTE times.  The error is taken to be the rms deviation.

  NSIGN = 300

  n = n_elements(g)

  sumsq = dblarr(n)
  sumsq(0:n-1) = 0.00D0
  Ksq = 0.000D0
  KT = transpose(K)

  sign = get_sign(NSIGN)   ; Get a bunch of random signs

  for i=1,MONTE do begin
    splace = fix( randomu(seed,n)*(NSIGN-1) ) ;Select random signs out of sign
    rd = data + randomu(seed,n)*sign(splace)*error
    Gp = KT#rd

    Yout = svsol(U,W,V,Gp,/double)        ; Re-solve the equation
    Y = double(Yout)

    sumsq = sumsq + ((Y-dydx)^2)        ; Find rms deviations
    Ksq = Ksq + residual2(K,Y,data)
  endfor

  error = sqrt(sumsq/MONTE)     ; rms deviation

  return, (Ksq/MONTE)

end  ; end of function get_error

;***************************************************

function solve, data, K, dydx, error, alpha, MONTE

;  solve     T            T
;          (K K + rH)f = K g
;  using SVD.

  n = n_elements(data)

  H = find_H(n)

  KT = transpose(K)
  g = KT#data
  A = KT#K + alpha*H

  svdc,A,W,U,V,/double
  wbad = where(w LT max(w)/1.d8,nwbad)
  if nwbad GT 0 then w[wbad] = 0.0d0
  dydxout = svsol(U,W,V,g,/double)
  dydx = double(dydxout)

  rms_resid2 = 0.000D0
  if (n_elements(error) NE 0) and MONTE GT 0 then begin
    rms_resid2 = get_error(U,W,V,K,g,error,dydx,data,MONTE)
  endif 

  return, rms_resid2

end  ; end of function solve

;***************************************************

pro deriv_lud, x, yin, dydx, midpoints=mid, reg_param=alpha, yerror=error, $
           monte_carlo=MONTE, quiet=quiet

  n = n_elements(x)
  y = yin
  if (n LT 3) then begin
    print, 'ERROR:  must be at least three grid points to find derivative'
    stop
  endif
  if (n_elements(mid) NE (n-1)) then mid = dblarr(n-1)
  for i=0,n-2 do mid(i) = (x(i)+x(i+1))/2.0
  geom_err = 0.00D0
  mean_err = 0.00D0
  if (n_elements(error) NE 0) then begin
    geom_err = geo(error) 
    mean_err = sqrt(total(error^2)/n)
  endif
  if n_elements(MONTE) EQ 0 then MONTE=0   ; Default value
  if n_elements(MONTE) NE 1 then begin
    print,'ERROR (deriv): Number of Monte Carlo solutions must be a scalar'
    stop
  endif

  scale = rescale(x,y)       ; Rescale y so that y(0)=0
  K = get_kernel(x,y,data)   ; Fill the kernel matrix
  y = y + scale              ; Put y back to the way it was
  if (n_elements(alpha) EQ 0) then begin
    if n_elements(error) NE n then $
       alpha=(n)*(total(K((n-2),0:*))/(n-1))^2 $
    else begin
       dydxerr = (transpose(K)#(error[1:*]))
       smoothf = (transpose(K)#y[1:*])
       alpha = median(abs(f_div(dydxerr,smoothf)))
    endelse
    if NOT keyword_set(quiet) then print, 'Taking the regularization parameter to be ', alpha
  endif
  rms_resid2 = solve(data,K,dydx,error,alpha,MONTE)  ; Solve with regularization
  resid2 = residual2(K,dydx,data)                    ; Find the residual

  ; resid2 is the error due to the smoothing
  ; rms_resid2 is the inherent error

  if (NOT keyword_set(quiet)) then begin
    print, 'Residual of result is ', sqrt(resid2/n), $
           ' (must be less than ', mean_err, ')'
    print, 'Check that ', sqrt((rms_resid2+resid2)/n), ' is approximately', geom_err
  endif

end

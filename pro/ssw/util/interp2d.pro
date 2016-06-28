 function interp2d, A, x0, y0, x1, y1, nxny, missing=missing, 	$
	grid=grid, quintic=quintic, regular=regular, cubic=cubic,$
        extrapolate=extrapolate,bin=bin,trigrid=trigrid
;+
; NAME:
;   interp2d
; PURPOSE:
;   Perform bilinear 2d interpolation using the IDL intrinsic 
;   interpolate procedure
; CALLING SEQUENCE:
;   result = interp2d(A,x0,y0,x1,y1)
;   result = interp2d(A,x0,y0,x1,y1,/grid)
;   result = interp2d(A,x0,y0,x1,y1,/regular,/cubic)
;   result = interp2d(A,x0,y0,x1,y1,missing=missing)
; INPUTS:
;   A	= 2d array to interpolate
;   x0	= Values that correspond to A(0,0), A(1,0), ...
;   y0  = Values that correspond to A(0,0), A(0,1), ...
;   x1	= New X values at which A should be interpolated
;   y1  = New Y values at which A should be interpolated
; OPTIONAL INPUTS:
;   nxny = [nx,ny] Vector of length 2 which specifies the size of
;         the regular linearized grid produced with trigrid.  The
;         default is nxny = [51,51].  If the size of A is much larger
;	  than 51 by 51, greater accuracy may be obtained by having
;         nxny = [n_elements(A(*,0),n_elements(A(0,*))]
; OPTIONAL INPUT KEYWORDS:
;   grid= If set, return an n_elements(X1) by n_elements(y1) grid
;   missing = Value to points which have X1 gt max(X0) or X1 lt min(X0)
;		and the same for Y1.
;   quintic = If set, use smooth interpolation in call to trigrid
;   regular = If set, do not call trigrid -- x0 and y0 must be linear.
;   cubic   = If set, use cubic convolution
;   extrapolate = If set, then extrapolate beyond boundary points
;   bin = set to bin data prior to interpolation.
;         (e.g. bin=2 interpolate every second pixel)
; Returned:
;   result = a vector N_elements(X1) long 
;      or, if /grid is set
;   result = an array that is N_elements(X1) by N_elements(Y1)
;
; PROCEDURE:
;   First call the IDL intrinsic routines TRIANGULATE & TRIGRID to make
;	sure that X0 and Y0 are linear (if /regular is not set).
;   Then call the IDL intrinsic INTERPOLATE to do bilinear interpolation.
; RESTRICTIONS:
;   X0 and Y0 must be linear functions.
;   A must be a 2-d array
; HISTORY:
;    9-mar-94, J. R. Lemen LPARL, Written.
;   20-Jan-95, JRL, Added the REGULAR & CUBIC keywords
;   6-Sept-97, Zarro, GSFC, allowed for 2-d (X-Y) coordinate inputs
;  22-Apri-99, Zarro, SM&A/GSFC - added /trigrid and made /regular
;              the default (much faster).
;  14-apr-2001, jmm, jimm@ssl.berkeley.edu, fixed bug for triangulate
;               option, changed reform statements to rebin, /sample
;  20-May-2004, Zarro (L-3Com/GSFC) - made /regular the default (again)
;  10-Jan-2005, Zarro (L-3Com/GSFC) - changed () to []
;-

;-- Check for self-consistent input dimensions

sz = size(a)

if sz[0] ne 2 then begin
  message,'input data array must be 2-D',/cont
  return,-1
endif

sx=size(x0) & sy=size(y0)
chk=where_vector(sx,sy,count)
if count eq 0 then begin
 message,'input X-Y coordinate arrays do not match in size',/cont
 return,-1
endif

twod=0
case 1 of
 sx[0] eq 1: begin
  nx=sx[1] & ny=sy[1]
 end
 sx[0] eq 2: begin
  twod=1
  nx=sx[1] & ny=sx[2]
 end
 else: begin
  message,'input X-Y coordinate arrays must 1- or 2-D',/cont
  return,-1
 end
endcase
 
if (sz[1] ne nx) or (sz[2] ne ny) then begin
 message,'Dimensions of Data, X0, Y0 are not consistent',/cont
 return,-1
endif

;-- Call triangulate and trigrid to get a regularly spaced grid

if keyword_set(trigrid) then begin
  message,'using trigrid option...',/cont
  if n_elements(nxny) eq 0 then nxny = [nx,ny]

  dprint,'% nx,ny: ',nxny[0],nxny[1]

  gs = [(max(X0)-min(X0))/(nxny[0]-1), (max(Y0)-min(Y0))/(nxny[1]-1)]

  IF NOT twod THEN BEGIN
;   x0 = reform(temporary(x0),nx,ny)
;   y0 = transpose(reform(temporary(y0),nx,ny))
     x0 = rebin(temporary(x0), nx, ny, /sample)
     y0 = transpose(rebin(temporary(y0), nx, ny, /sample))
  ENDIF 

  triangulate, x0, y0, tr,bound

  if n_elements(quintic) eq 0 then quintic = 0	; Make sure quintic is defined

  if keyword_set(extrapolate) then begin
   zz = trigrid(x0,y0, A, tr, gs, quintic=quintic,$
                extrapolate=bound)
  endif else begin
   zz = trigrid(x0,y0, A, tr, gs, quintic=quintic)
  endelse

  if not twod then begin
   x0=reform(temporary(x0),nx*ny)
   y0=reform(transpose(temporary(y0)),nx*ny)
  endif

  zz = temporary(zz[0:nxny[0]-1,0:nxny[1]-1])	; Make sure the dimensions are matched
endif else zz = A 			; /regular was set -- x0 and y0 are linear

sz = size(zz)
xslope = (max(X0)-min(X0)) / (sz[1]-1)
yslope = (max(Y0)-min(Y0)) / (sz[2]-1)


; Map the coordinates

x2 = (x1 - min(x0)) / xslope
y2 = (y1 - min(y0)) / yslope

; Now interpolate

if n_elements(grid)    eq 0 then grid = 0
if n_elements(cubic)   eq 0 then cubic= 0
if n_elements(missing) eq 0 then $
		return,interpolate(zz,x2,y2,grid=grid,cubic=cubic) else $
		return,interpolate(zz,x2,y2,grid=grid,missing=missing,cubic=cubic)
end


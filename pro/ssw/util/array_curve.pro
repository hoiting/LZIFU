pro array_curve,z,x,y,nw,xw,yw,zw
;
;PURPOSE:
;	interpolates from 2D array z(nx,ny) perpendicular to curve [x(ns),y(ns)]
;	a curved sub-array zw(ns,nw) with grid xw(ns,nw),yw(ns,nw)
;INPUT:
;	z	=2D array
;	x	=x-axis coordinates of curved array
;	y	=y-axis coordinates of curved array
;	nw	=number of pixels in curved array perpendicular to curve length
;OUTPUT:

ns	=n_elements(x)
nsy	=n_elements(y)
if (ns ne nsy) then print,'ARRAY_CURVE: mismatch of arrays x,y :',ns,nsy
zw	=fltarr(ns,nw)	
x_	=[x,x(ns-1)*2-x(ns-2)]	;extrapolate 1 additional value 
y_	=[y,y(ns-1)*2-y(ns-2)]
dx	=x_(1:ns)-x_(0:ns-1)
dy	=y_(1:ns)-y_(0:ns-1)
ds	=sqrt(dx^2+dy^2)
xw	=fltarr(ns,nw)
yw	=fltarr(ns,nw)
zw	=fltarr(ns,nw)
for j=0,nw-1 do begin
 jw	=float(j)-(float(nw)-1.)/2.
 xw(*,j)=x+jw*dy/ds
 yw(*,j)=y-jw*dx/ds
endfor
zw	=bilinear(z,xw,yw) 
end


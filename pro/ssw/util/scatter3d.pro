;+
; NAME:
;   SCATTER3D
;
; PURPOSE:
;      Show a scatterplot of two arrays with color coding to 
;      indicate density of points.  
;
; AUTHOR:
;
;   Thomas Berger
;   Lockheed Martin Solar and Astrophysics Laboratory
;   berger@lmsal.com
;
; CATEGORY:
;       Data analysis, graphics.
;
; CALLING SEQUENCE:
;       SCATTER3D,array1,array2
;
; INPUTS:
;       ARRAY1:   data array of any dimension > 0
;       ARRAY2:   data array of the same dimension as ARRAY1
;
; OUTPUTS:
;       BINS:     The binsize actually used in HIST2D (determined from
;                 data ranges and NBIN parameter.
;
;       R:        The HIST2D "image" used to display the scatterplot
;
;       CENTER:   The center of the principle moment ellipse. Only if
;                 keyword ELLIPSE is set.
;
;      SEMI_AIXS: FLTARR[2] containing the semi-axes of the principle
;                 moment ellipse in data units. Only if keyword ELLIPSE
;                 is set.
;
;       ROTANG:   Rotation angle of the principle moment ellipse in 
;                 degrees counterclockwise from x-axis. Only if 
;                 keyword ELLIPSE is set.
;       
; KEYWORD PARAMETERS:
;
;       NBIN:     The number of bins for HIST2D - effectively the
;                 number of "pixels" in the scatterplot image.
;                 Default is 100.
;
;       ELLIPSE:  If set, routine calculates and plots the principle moment 
;                 ellipse fit to the scatterplot "image".           
;
;       XTITLE:   Passed directly to PLOT.PRO for axis labelling.
;       YTITLE    
;
;       PLOT45:   If set, plots the 45-degree, slope=1, line for comparison
;                 to the scatterplot data.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       720x540 pixel direct graphics window is opened in upper right of display.
;
; RESTRICTIONS:
;       Requires HIST2D.PRO (built-in IDL function) and 
;       COLORBAR.PRO (Fanning Software IDL procedure, also found in SolarSoft).       
;
; EXAMPLE:
;       To make a scatterplot of two images IMAGE1 and IMAGE2 with
;       the priniciple moment ellipse and a 45-degree line
;
;       SCATTER3D, image1, image2, bins, r, center, semi, rotang,$
;           /ELLIPSE,/PLOT45,XTITLE='Image 1', YTITLE='Image 2'
;
; MODIFICATION HISTORY:
;       Written by: Thomas Berger, LMSAL, 10/2001.
;       2-November-2001 - S.L.Freeland;
;                         change 'ellipse' to scatter3d_ellipse 
;                         'diagonal' to scatter3d_diagonal
;                         to avoid current (and future) naming conflicts
;-
;

PRO scatter3d, dat1, dat2, bins, r, center, semi_axis, rotang, $
               NBIN=nbin, ELLIPSE=ellipse, $
               XTITLE=xtitle, YTITLE=ytitle, $
               PLOT45=plot45

ON_ERROR,2

s1 = SIZE(dat1)
s2 = SIZE(dat1)
if s2(0) ne s1(0) OR s2(1) ne s1(1) OR s2(2) ne s1(2) then begin
    MESSAGE,'Dimensions of datasets unequal - returning.'
    RETURN
end

if KEYWORD_SET(xtitle) then xt = xtitle else xt = 'DATA1'
if KEYWORD_SET(ytitle) then yt = ytitle else yt = 'DATA2'

mx1 = FLOAT(MAX(dat1))
mn1 = FLOAT(MIN(dat1))
if KEYWORD_SET(nbin) then ng = nbin else ng=100.
rng1 = mx1-mn1
b1 = ROUND(ng*rng1)/FLOAT(ng)/ng

mx2 = FLOAT(MAX(dat2))
mn2 = FLOAT(MIN(dat2))
rng2 = mx2-mn2
b2 = ROUND(ng*rng2)/FLOAT(ng)/ng

mins = [mn1,mn2]

r = HIST_2D(dat1,dat2,BIN1=b1,BIN2=b2,MIN1=mn1,MAX1=mx1,MIN2=mn2,MAX2=mx2)
szr = SIZE(r)
;actual binsize of x and y pixels in r:
bins = [rng1/szr[1],rng2/szr[2]]

;Make the FIXED ASPECT RATIO plot
WINX,720,540
LOADCT,2
ar = FLOAT(680)/640
x0 = 0.15
y0 = 0.10
x1 = 0.76
y1 = y0 + (x1-x0)*ar
!p.position=[x0,y0,x1,y1]
y1 = ((x1-x0)*!d.x_vsize)/((y1-y0)*!d.y_vsize)*y1
!p.position=[x0,y0,x1,y1]
!x.margin=[0,4]
!y.margin=[4,4]

PLOT,[mn1,mx1],[mn2,mx2],/nodata,$
  xrange=xrang,yrange=yrang,/xsty,/ysty
px = !X.WINDOW*!D.X_VSIZE
py = !Y.WINDOW*!D.Y_VSIZE
sx = px[1]-px[0]+1
sy = py[1]-py[0]+1
TVSCL,CONGRID(ALOG(r+1),sx,sy),px[0],py[0]
PLOT,[mn1,mx1],[mn2,mx2],/noerase,$
  /nodata,$
  xrange=xrang,yrange=yrang,/xsty,/ysty,$
  title='Log(1+N) Histogram Scatterplot',xtitle=xt,ytitle=yt
PLOTS,[mn1,mx1],[0,0]
PLOTS,[0,0],[mn2,mx2]
;Plot 45-degree line for reference:
if KEYWORD_SET(plot45) then PLOTS,[mn1,mx1],[mn1,mx1]

;Add colorbar. 
colorbar,position=[.90,.1,.94,y1],$
  range=[Min(r),Max(r)],/vertical,$
  format='(I6)',title='N Values',charsize=0.7

;Ellipse fit
if KEYWORD_SET(ellipse) then begin 
    center = 0
    semi_axis = 0
    rotang = 0
    scatter3d_ellipse,r,center,semi_axis,rotang
    center = center*bins-ABS(mins)
    PLOTS,center[0],center[1],$
      psym=4,symsize=1,thick=3,color=0

    a = semi_axis[0]
    b = semi_axis[1]
    xp1 = FINDGEN(4*a)/2 - a
    xp1 = [xp1,-xp1[0]]
    yp = b*SQRT(1.0 - (xp1/a)^2.)
    yn = -yp

    cosp = COS(!DTOR*rotang)
    sinp = SIN(!DTOR*rotang)
    rotmat = [[sinp,cosp],[sinp,-cosp]]
    xypr = rotmat#TRANSPOSE([[xp1],[yp]])
    xynr = rotmat#TRANSPOSE([[xp1],[yn]])  
    
;Draw the ellipse in the plot box only. Should use vectors but got lazy...
    xpr = REFORM(xypr[0,*])*bins[0]+center[0]
    ypr = REFORM(xypr[1,*])*bins[1]+center[1]
    goodx = WHERE(xpr ge mn1 and xpr le mx1)
    xpr = xpr[goodx]
    ypr = ypr[goodx]
    goody = WHERE(ypr ge mn2 and ypr le mx2)
    xpr = xpr[goody]
    ypr = ypr[goody]
    PLOTS,xpr,ypr, col=0, thick=2, lines=0 

    goodx = WHERE(xynr[0,*] gt mn1 and xynr[0,*] lt mx1)
    xnr = REFORM(xynr[0,*])*bins[0]+center[0]
    ynr = REFORM(xynr[1,*])*bins[1]+center[1]
    goodx = WHERE(xnr ge mn1 and xnr le mx1)
    xnr = xnr[goodx]
    ynr = ynr[goodx]
    goody = WHERE(ynr ge mn2 and ynr le mx2)
    xnr = xnr[goody]
    ynr = ynr[goody]
    PLOTS,xnr,ynr, col=0, thick=2, lines=0 

    semi_axis = semi_axis*bins
end

RETURN
END

PRO scatter3d_ellipse,eabt,center,semi_axes,rotation
;
;	eabt	  - 2-dimensional object array
;	center	  - center of computed ellipse (pixels) (centroid of eabt)
;	semi_axes - semi-axes of computed ellipse (pixels)
;	rotation  - rotation of computed ellipse wrt input array (degrees)
;
;Written by Bill Rosenberg 3/95.

sz=size(eabt)
if sz(0) ne 2 then begin
	print,' Dimension of input array, ',sz(0),' not equal to 2'
	retall
	endif
xd=sz(1) & yd=sz(2)
xr=findgen(xd,yd) mod xd
yr=findgen(yd,xd) mod yd
yr = transpose(yr)
;print,xr,format='(<xd>i3)'
;print,yr,format='(<yd>i3)'
s=total(eabt)
xbar=total(xr*eabt)/s 
;print,xbar
ybar=total(yr*eabt)/s 
;print,ybar
sxx=total(eabt*(xr-xbar)^2)/s 
;print,sxx
syy=total(eabt*(yr-ybar)^2)/s 
;print,syy
sxy=total(eabt*(xr-xbar)*(yr-ybar))/s 
;print,sxy
;Covariance matrix:
kk=[[sxx,sxy],[sxy,syy]]
scatter3d_diagonal,kk,dd,t1
;print,2.*sqrt(dd > 0)
;print,t1
rotation=t1
semi_axes=2.*sqrt([dd(0,0),dd(1,1)] > 0)
center=[xbar,ybar]
;print,' Ellipse center:    ',center
;print,' Ellipse semi-axes: ',semi_axes
;print,' Ellipse rotation:  ',rotation,' degrees'

RETURN
END

PRO scatter3d_diagonal,kk,dd,t1

;Matrix diagonalization routine. Used by ELLIPSE.PRO
; Rosenberg 3/95.
;print,kk
;      50.0000      22.0000
;      22.0000      10.0000
a=kk(0,0) & b=kk(0,1) & d=kk(1,1)
;print,a*d-b^2
;      16.0000
l1=((a+d)+sqrt((a-d)^2+4.*b^2))/2.
;print,l1
;      59.7321
l2=((a+d)-sqrt((a-d)^2+4.*b^2))/2.
;print,l2
;     0.267862
t1=rtand(-b/(a-l1))
;print,t1
;      66.1368
t2=rtand(-b/(a-l2))
;print,t2
;     -23.8632
x1=[sind(t1),cosd(t1)]
x2=[sind(t2),cosd(t2)]
pp=[[x1],[x2]]
;print,pp
;     0.914514     0.404554
;    -0.404554     0.914514
ppi=transpose(pp)
dd=ppi#kk#pp
;print,dd
;      59.7321 2.942979e-06
; 3.814697e-06     0.267863

RETURN
END

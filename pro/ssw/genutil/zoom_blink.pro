; procedure to display and blink two arrays
pro grid_over,im
s=size(im) & xint=s(1)/10 & yint=xint & x2=xint/2 & y2=yint/2
nx=(s(1)-xint)/xint & ny=(s(2)-yint)/yint 
xarr=intarr(1,s(2)) & for i=0,s(2)-1,2 do xarr(0,i)=255
yarr=intarr(s(1),1) & for i=0,s(1)-1,2 do yarr(i,0)=255
for i=0,nx do im(i*xint+x2,0)=xarr
for i=0,ny do im(0,i*yint+y2)=yarr
return
end
;---------------------------------------------------------------
pro box_restore,x,y,im
; restore the original image
tv,im(x(0):x(1),y(0)),x(0),y(0) & tv,im(x(0):x(1),y(1)),x(0),y(1) 
tv,im(x(0),y(0):y(1)),x(0),y(0) & tv,im(x(1),y(0):y(1)),x(1),y(0)
return
end
;---------------------------------------------------------------
pro zoom_blink,im1o,im2o,delay
;+
;NAME:
;	zoom_blink
;PURPOSE:
;	To super-impose two images and blink between them.
;SAMPLE CALLING SEQUENCE:
;	zoom_blink img1, img2
;	zoom_blink img1, img2, delay
;HISTORY:
;	Received from Alan Title (Karl Schriver) 7-May-96
;	and put online by M.Morrison
;	 7-May-96 (MDM) - Replaced all "nint" references with "round"
;-
;
if n_elements(delay) eq 0 then delay=.5
magn=2 & magmax=4 & delay_init=delay & corner=20 & gray=127
; if arrays are empty, then generate test images
if n_elements(im1o) lt 2 then return
;if n_elements(im1o) lt 2 then begin
;  x=findgen(512)/15.
;  im1o=(sin(x)#sin(x))^2
;  im2o=1-im1o
;endif 
im1=im1o & im2=im2o
s1=size(im1) & s2=size(im2)
; scale:
im1=round((float(im1)-min(im1))/(max(im1)-min(im1))*255)
im2=round((float(im2)-min(im2))/(max(im2)-min(im2))*255)
; initial check
if not (s1(1) eq s2(1) and s1(2) eq s2(2)) then begin
  print,'Arrays must be of equal size'
  return
endif
; initial display
window,10,xsize=s2(1),ysize=s2(2),retain=2,title='Secondary' & wset,10
tv,im2
window,8,xsize=s2(1),ysize=s2(2),retain=2,title='Primary' & wset,8
tv,im1 
; set up:
print,'Click left button on two corners (Primary window) ...'
cursor,x1,y1,/down,/device
x2=x1 & y2=y1 
x1=x1-1 & y1=y1-1
move:
x=[min([x1,x2]),max([x1,x2])] & y=[min([y1,y2]),max([y1,y2])]  
xs=x(1)-x(0)+1 & ys=y(1)-y(0)+1 
xar=intarr(xs,1) & yar=intarr(1,ys)
tv,xar,x(0),y(0) & tv,xar,x(0),y(1) & tv,yar,x(0),y(0) & tv,yar,x(1),y(0)
cursor,x2,y2,/device,/change
if !err eq 1 then goto,jump
box_restore,x,y,im1
goto,move
jump:
tv,intarr(corner,corner)+127 ; add time control corner
; get ready to move the image 
window,11,xsize=xs*magn,ysize=ys*magn,retain=2,$
 title='Mag = '+string(magn,format='(f4.2)') 
window,15,xsize=xs*magn,ysize=ys*magn,retain=2,$
 title='Mag = '+string(magn,format='(f4.2)') 
print,'And move cursor to move window ................'
print,'PRESS on left button to zoom in ...............'
print,'PRESS on center button to zoom out ............'
print,'PRESS right button to exit ....................'
print,'PRESS left button in box to slow blinking down '
print,'PRESS middle button in box to speed blinking up '
alast=-10 & blast=-10
again:
wset,8 & cursor,a,b,/nowait,/device
if ((a ge corner) or (b ge corner)) and (!err ne 0) then begin
  if !err eq 4 then return
  if !err eq 1 then begin
    magn=min([magmax,magn+0.25])
    goto,magnify
  endif
  if !err eq 2 then begin
    magn=max([1,magn-0.25])
    goto,magnify
  endif
endif
if ((a eq x(1)) and (b eq (y(1)))) then begin
  wshow,11 & wait,delay & wshow,15 & wait,delay 
endif else begin
magnify:
  if (a eq -1) or (b eq -1) then goto,again
  if (a lt corner) and (b lt corner) then begin
    if !err eq 1 and delay lt 4*delay_init then delay=delay*sqrt(2.)
    if !err eq 2 and delay gt delay_init/4 then delay=delay/sqrt(2.)
    wait,0.3
    if !err ne 0 then begin
    if !err eq 1 then gray=max([0,gray-32]) else gray=min([255,gray+32]) 
    tv,intarr(corner,corner)+127
    tv,intarr(corner-5,corner-5)+gray
    endif
    goto,again
  endif 
  wset,8 & box_restore,x,y,im1
  alast=a & blast=b & wait,0.05
  cursor,a,b,/nowait,/device
  if (a ne alast or b ne blast) then goto,magnify
  x=x+(a-x(1)) & y=y+(b-y(1))  
  x=[max([x(0),0]),min([x(1),s1(1)-1])]
  if x(0) eq 0 then x(1)=xs & if x(1) eq s1(1)-1 then x(1)=s1(1)-1
  y=[max([y(0),0]),min([y(1),s1(2)-1])]
  if y(0) eq 0 then y(1)=ys & if y(1) eq s1(2)-1 then y(1)=s1(2)-1
  tv,xar,x(0),y(0) & tv,xar,x(0),y(1) & tv,yar,x(0),y(0) & tv,yar,x(1),y(0)
  wset,15 & device,get_window_position=p15,window_state=ws & wset,8
  if ws(15) eq 0 then p15=[0,0]
  window,11,xsize=magn*xs,ysize=magn*ys,retain=2,$
    title='Mag = '+string(magn,format='(f4.2)'),xpos=p15(0),ypos=p15(1)
  if magn eq 1 then tv,im2(x(0):x(1),y(0):y(1)) else begin
    expand,float(im2(x(0):x(1),y(0):y(1))),magn*xs,magn*ys,out 
    if abs(magn-magmax) lt 0.01 then grid_over,out
    tv,round(out)
  endelse    
  xyouts,1,1,string(x(0)+xs/2,format='(i3)')+','+$
    string(y(0)+ys/2,format='(i3)'),/device,charsize=magn/2
  wset,15 & device,get_window_position=p15,window_state=ws & wset,8
  window,15,xsize=magn*xs,ysize=magn*ys,retain=2,$ 
    title='Mag = '+string(magn,format='(f4.2)'),xpos=p15(0),ypos=p15(1)
  if magn eq 1 then tv,im1(x(0):x(1),y(0):y(1)) else begin
    expand,float(im1(x(0):x(1),y(0):y(1))),magn*xs,magn*ys,out 
    if abs(magn-magmax) lt 0.01 then grid_over,out
    tv,round(out)
  xyouts,1,1,string(x(0)+xs/2,format='(i3)')+','+$
    string(y(0)+ys/2,format='(i3)'),/device,charsize=magn/2
  endelse  
endelse
goto,again
return
end


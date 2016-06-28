pro plottime, xf, yf, str, siz, dir, align=align, color=color
;+
;NAME:
;	plottime
;PURPOSE:
;	Originally it simply put a message "Plot Made dd-MMM-yy hh:mm:ss"
;	message on the plots.  It was generalized to effectively do
;	what "xyouts, /normalize" does (before that capability was
;	around
;SAMPLE CALLING SEQUENCE:
;	plottime
;	plottime, 0.1, 0.9, 'Infil: ' + infil
;	plottime, xf, yf, str, siz, dir, align=align
;INPUT:
;	xf	- fractional position in the x
;	yf	- fractional position in the y
;	str	- the string to write out
;	dir	- the direction (rotation)
;OPTIONAL KEYWORD INPUT:
;	align	- IDL align option
;	color	- permit to specify color
;HISTORY:
;	Written 1991 by M.Morrison
;	 6-Mar-95 (MDM) - Added ALIGN keyword
;	 5-Nov-96 (MDM) - Added documentation header
;	 3-Dec-01 (LWA) - Added color keyword
;	 7-Dec-01 (MDM) - Fixed 3-Dec mod to continue to work if color
;			  is not specified
;-
;
savlin = !linetype
!linetype = 0	
;
xsiz = !d.x_size
ysiz = !d.y_size
if (n_elements(color) eq 0) then color = !p.color
;
if (n_params(0) eq 0) then xyouts, 0.55*xsiz, 0, 'Plot Made '+!stime, /DEVICE,$
     color=color
if (n_params(0) ge 3) then begin
    if (n_elements(siz) eq 0) then siz0=0.9 else siz0=siz
    if (n_elements(dir) eq 0) then dir0=0 else dir0=dir
    if (n_elements(align) eq 0) then align0=0 else align0=align
    if not keyword_set(color) then color=1 else color=color
    if (!fancy eq 0) then siz0 = siz0<0.9
    xyouts, xf*xsiz, yf*ysiz, str, siz=siz0, orientation=dir0, /DEVICE, align=align0, color=color
end
;
!linetype = savlin
;
return
end

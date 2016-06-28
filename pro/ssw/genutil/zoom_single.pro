pro zoom_single,x,y, $
 window=window, scale=scale, $
 xsize=xs, ysize=ys, fact = fact, interp = interp, continuous = cont
;+
; NAME:	
;	ZOOM_SINGLE
; PURPOSE: 
;	Display part of an image (or graphics) from the current window
;	expanded in another window and exit - version for event driven
; CATEGORY:
;	Display.
; CALLING SEQUENCE:
;	Zoom, .... Keyword parameters.
; INPUTS:
;	All input parameters are keywords.
;	Fact = zoom expansion factor, default = 4.
;	Interp = 1 or set to interpolate, otherwise pixel replication is used.
;	xsize = X size of new window, if omitted, 512.
;	ysize = Y size of new window, default = 512.
;	scale - if set, tvscl 
;	Continuous = keyword param which obviates the need to press the
;		left mouse button.  The zoom window tracks the mouse.
;		Only works well on fast computers.
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	A window is created / destroyed.
; RESTRICTIONS:
;	Only works with color systems.
; PROCEDURE:
;	Straightforward.
; MODIFICATION HISTORY:
;	SLF, revision of ZOOM which exits immediately - used for widget 
;		event drivers (loop removed)
;-
on_error,2              ;Return to caller if an error occurs
if n_elements(xs) le 0 then xs = 512
if n_elements(ys) le 0 then ys = 512
if n_elements(fact) le 0 then fact=4
if keyword_set(cont) then waitflg = 2 else waitflg = 3
ifact = fact
old_w = !d.window
zoom_w=window
ierase = 0		;erase zoom window flag
	x0 = 0 > (x-xs/(ifact*2)) 	;left edge from center
	y0 = 0 > (y-ys/(ifact*2)) 	;bottom
	nx = xs/ifact			;Size of new image
	ny = ys/ifact
	nx = nx < (!d.x_vsize-x0)
	ny = ny < (!d.y_size-y0)
	x0 = x0 < (!d.x_vsize - nx)
	y0 = y0 < (!d.y_vsize - ny)
	a = tvrd(x0,y0,nx,ny)		;Read image
	if zoom_w lt 0 then begin	;Make new window?
		window,xsize=xs,ysize=ys,title='Zoomed Image'
		zoom_w = !d.window
	endif else begin
		wset,zoom_w
		if ierase then erase		;Erase it?
		ierase = 0
	endelse
	xss = nx * ifact	;Make integer rebin factors
	yss = ny * ifact
	image=rebin(a,xss,yss,sample=1-keyword_set(interp))
        scale_proc=['tv','tvscl']
        call_procedure,scale_proc(scale), image
	wset,old_w
end

function lcur_region, win, method, nx, ny, nout, qdone=qdone, bin=bin, select=select
;
;NAME:
;	lcur_region
;PURPOSE:
;	To select the region which is to have the light curve generated for
;	(Called by LCUR_IMAGE)
;INPUT:
;	win	- The window number where the image is displayed
;	method	- The method to be used to mark the region.  Options are:
;		RECT	Marking a rectangle (by marking the two corners)
;		RECT2	Marking a rectangle (BOX_CURSOR moves and reshapes the box)
;		POLY	Marking several points around the region
;		CONTOUR	Using contour lines to mark it (NOT AVAILABLE RIGHT NOW)
;	nx	- The rebinned x size
;	ny	- The rebinned y size
;	nout	- The region number (starting with 0).  Used for labeling
;OUTPUT:
;	The function returns the subscripts within the image which were
;	marked.  If /SELECT is used, then output is one of the following
;	strings ('RECT', 'RECT2', 'POLY', 'CONTOUR')
;OPTIONAL KEYWORD INPUT:
;	bin	- The rebin factor
;	select	- If set, then have the routine display a menu and ask the
;		  user to select one of the available methods for selecting
;		  regions.
;OPTIONAL KEYWORD OUTPUT:
;	qdone	- For the RECT option, if the user presses the middle key,
;		  it indicates that he is done marking regions.
;HISTORY:
;	Written 18-Oct-93 by M.Morrison
;	19-Oct-93 (MDM) - Added header
;			- Made the output always be the subscripts selected
;			  (previously it was the four coordinates when
;			  using the RECT or RECT2 option)
;	16-Nov-93 (MDM) - MOdified to allow to plot a single pixel
;	29-Nov-93 (MDM) - Modified to label the POLYGON in the proper location
;	 1-Dec-93 (MDM) - Modified because of peculiarity with POLYFILLV
;			  It does not include the last column and last line
;			  in a box marked [x0,x1,y0,y1].  I added 0.5 to have
;			  it round up when applicable
;-
;
nopt = 4
options = strarr(nopt)
explain = strarr(nopt)
;
if (n_elements(method) eq 0) then method = 'RECT'
;
options(0) = 'RECT'	& explain(0) = 'Marking a rectangle (by marking the two corners)
options(1) = 'RECT2'	& explain(1) = 'Marking a rectangle (BOX_CURSOR moves and reshapes the box)
options(2) = 'POLY'	& explain(2) = 'Marking several points around the region
options(3) = 'CONTOUR'	& explain(3) = 'Using contour lines to mark it (NOT AVAILABLE RIGHT NOW)
;
if (n_elements(bin) eq 0) then bin = 1
fbin = float(bin)
;
if (keyword_set(select)) then begin
    menu = ['The possible options for techniques to mark regions are:', $
	string(options+':               ', format='(a12)') + explain]
    imenu = wmenu(menu)
    if (imenu eq 0) then begin
	tbeep, 5
	print, 'Invalid selection.  Using RECT by default'
	out = 'RECT'
    end else begin
	out = options(imenu-1)
    end
    return, out
end
;
wset, win
wshow, win
;
str = string(byte(65+nout))
out = -1
case strupcase(method) of
    'RECT': begin
		print, 'LCUR_REGION: Selecting region by marking the two corners (middle button exits)'
		get_boxcorn, x0, y0, x1, y1, qdone, /dev
		if (not qdone) then begin
		    ;out = [x0,y0,x1,y1]/bin
		    xvert = [x0,x0,x1,x1,x0]
		    yvert = [y0,y1,y1,y0,y0]
		    if ( (min(xvert/bin) eq max(xvert/bin)) and (min(yvert/bin) eq max(yvert/bin)) ) then begin
			out = yvert(0)/bin*(nx/bin) + xvert(0)/bin
		    end else begin
			out = polyfillv(xvert/fbin+.5, yvert/fbin+.5, nx/bin, ny/bin)	;subscripts within the image array
		    end
		    draw_boxcorn, x0, y0, x1, y1, /dev
		    xyouts, x0+10, y0+10, str, size=2, charthick=2, /dev
		end
	    end
     'RECT2': begin
		print, 'LCUR_REGION: Selecting region by drag/resize box (?? button exits)'
		box_cursor, x0, y0, nx0, ny0, /message
		x1 = x0+nx0
		y1 = y0+ny0
		xvert = [x0,x0,x1,x1,x0]
		yvert = [y0,y1,y1,y0,y0]
		    if ( (min(xvert/bin) eq max(xvert/bin)) and (min(yvert/bin) eq max(yvert/bin)) ) then begin
			out = yvert(0)/bin*nx + xvert(0)/bin
		    end else begin
			out = polyfillv(xvert/fbin+.5, yvert/fbin+.5, nx/bin, ny/bin)	;subscripts within the image array
		    end
		;out = [xx0, yy0, xx1, yy1]/bin
		draw_boxcorn, x0, y0, x1, y1, /dev
		qdone = 1	;how to continually loop?
		xyouts, x0+10, y0+10, str, size=2, charthick=2, /dev
	      end
     'POLY': begin
		out = defroi(nx, ny, xvert, yvert)		;all subscripts
		out = polyfillv(xvert/fbin+.5, yvert/fbin+.5, nx/bin, ny/bin)	;subscripts within the image array
		x0 = (min(out) mod (nx/bin))
		y0 = (min(out) / (ny/bin))
		xyouts, x0*bin-20, y0*bin-20, str, size=2, charthick=2, /dev
		qdone = 1	;how to continually loop?
	     end
     else: begin
		tbeep, 5
		print, 'LCUR_REGION: Do not recognize method: ', method
		out = -1
		qdone = 1
	    end
endcase
;
return, out
end

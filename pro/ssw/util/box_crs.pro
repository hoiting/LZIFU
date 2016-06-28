pro box_crs, x0, y0, nx, ny, INIT = init, FIXED_SIZE = fixed_size, $
	MESSAGE = message
;+
; Project     : SOHO - CDS
;
; Name        : 
;	BOX_CRS
; Purpose     : 
;	Two-button equivalent of BOX_CURSOR for Microsoft Windows.
; Explanation : 
;	Emulates the operation of a variable-sized box cursor (also known as
;	a "marquee" selector).  Differs from BOX_CURSOR in that only two mouse
;	buttons are used.  This makes it useful for Microsoft Windows, where
;	all three buttons are not always available.
;
;	The graphics function is set to 6 for eXclusive OR.  This allows the
;	box to be drawn and erased without disturbing the contents of the
;	window.
;
;	Operation is as follows:
;
;	To move box:	Hold down either the left or middle mouse button while
;			the cursor is inside the box, and drag the box to the
;			desired position.
;
;	To resize box:	Hold down either the left or middle button mouse while
;			the cursor is outside the box, and drag the box to the
;			desired size.  The corner nearest the initial mouse
;			position is moved.
;
;	To exit:	Press the right mouse button to exit this procedure,
;			returning the current box parameters.
;
; Use         : 
;	BOX_CRS, x0, y0, nx, ny [, INIT = init] [, FIXED_SIZE = fixed_size]
; Inputs      : 
;	No required input parameters.
; Opt. Inputs : 
;	X0, Y0, NX, and NY give the initial location (X0, Y0) and size (NX, NY)
;	of the box if the keyword INIT is set.  Otherwise, the box is initially
;	drawn in the center of the screen.
; Outputs     : 
;	X0:  X value of lower left corner of box.
;	Y0:  Y value of lower left corner of box.
;	NX:  width of box in pixels.
;	NY:  height of box in pixels. 
;
;	The box is also constrained to lie entirely within the window.
;
; Opt. Outputs: 
;	None.
; Keywords    : 
;	INIT:  If this keyword is set, x0, y0, nx, and ny contain the initial
;	parameters for the box.
;
;	FIXED_SIZE:  If this keyword is set, nx and ny contain the initial
;	size of the box.  This size may not be changed by the user.
;
;	MESSAGE:  If this keyword is set, print a short message describing
;	operation of the cursor.
;
; Calls       : 
;	None.
; Common      : 
;	None.
; Restrictions: 
;	Works only with window system drivers.
; Side effects: 
;	A box is drawn in the currently active window.  It is erased on exit.
; Category    : 
;	Utilities, User_interface.
; Prev. Hist. : 
;	DMS, April, 1990.
;	DMS, April, 1992.  Made dragging more intutitive.
;	William Thompson, GSFC, 11 June 1993.
;		Changed to use two button operation, selecting moving or
;		resizing based on whether or not the cursor is inside or
;		outside the box.  Renamed to BOX_CRS.
; Written     : 
;	David M. Stern, RSI, April 1990.
; Modified    : 
;	Version 1, William Thompson, GSFC, 25 June 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
; Version     : 
;	Version 2, 8 April 1998
;-
;

device, get_graphics = old, set_graphics = 6  ;Set xor
col = !d.table_size -1

if keyword_set(message) then begin
	print, "Drag Left or Middle button inside box to move."
	if not keyword_set(fixed_size) then	$
	print, "Or outside box near a corner to resize box."
	print, "Right button when done."
	endif

if keyword_set(init) eq 0 then begin  ;Supply default values for box:
	if keyword_set(fixed_size) eq 0 then begin
		nx = !d.x_size/8   ;no fixed size.
		ny = !d.x_size/8
		endif
	x0 = !d.x_size/2 - nx/2
	y0 = !d.y_size/2 - ny/2
	endif

button = 0
action = ''
goto, middle

while 1 do begin
	old_button = button
	cursor, x, y, 2, /dev	;Wait for a button
	button = !err
	if (old_button eq 0) and (button ne 0) then begin
		mx0 = x		;For dragging, mouse locn...
		my0 = y		
		x00 = x0	;Orig start of ll corner
		y00 = y0
		endif
;
;  If the button changed, then decide what the action should be.
;
	if button ne old_button then begin
;
;  If the right button was pressed, then the action is to quit.
;
		if button eq 4 then begin
			action = 'QUIT'
;
;  Otherwise, if neither the right nor middle button was pressed, then the
;  action is to do nothing.
;
		end else if (button ne 1) and (button ne 2) then begin
			action = ''
;
;  Otherwise, if within the box, then the action is to drag the entire box, or
;  if outside then the action is to resize the box, unless the FIXED_SIZE
;  keyword is set.
;
		end else begin
			xmin = x0 < (x0 + nx)  &  xmax = x0 > (x0 + nx)
			ymin = y0 < (y0 + ny)  &  ymax = y0 > (y0 + ny)
			within = (x ge xmin) and (x le xmax) and (y ge ymin) $
				and (y le ymax)
			if within then begin
				action = 'DRAG'
			end else if not keyword_set(fixed_size) then begin
				action = 'RESIZE'
			end else action = ''
		endelse
	endif
;
;  Act according to the selected action.
;
	if action eq 'DRAG' then begin ;Drag entire box?
		x0 = x00 + x - mx0
		y0 = y00 + y - my0
		endif
	if action eq 'RESIZE' then begin ;New size?
		if old_button eq 0 then begin	;Find closest corner
			mind = 1e6
			for i=0,3 do begin
				d = float(px(i)-x)^2 + float(py(i)-y)^2
				if d lt mind then begin
					mind = d
					corner = i
					endif
			   endfor
			nx0 = nx	;Save sizes.
		   	ny0 = ny
			endif
		dx = x - mx0 & dy = y - my0	;Distance dragged...
		case corner of
		0: begin x0 = x00 + dx & y0 = y00 + dy
			nx = nx0 -dx & ny = ny0 - dy & endcase
		1: begin y0 = y00 + dy
			nx = nx0 + dx & ny = ny0 - dy & endcase
		2: begin nx = nx0 + dx & ny = ny0 + dy & endcase
		3: begin x0 = x00 + dx
			nx = nx0 -  dx & ny = ny0 + dy & endcase
		endcase
		endif
	plots, px, py, col=col, /dev, thick=1, lines=0	;Erase previous box
	empty				;Decwindow bug

	if action eq 'QUIT' then begin  ;Quitting?
		device,set_graphics = old
		return
		endif
middle:
	if nx lt 0 then begin
		x0 = x0 + nx
		nx = -nx
	endif
	if ny lt 0 then begin
		y0 = y0 + ny
		ny = -ny
	endif
	x0 = x0 > 0
	y0 = y0 > 0
	x0 = x0 < (!d.x_size-1 - nx)	;Never outside window
	y0 = y0 < (!d.y_size-1 - ny)

	px = [x0, x0 + nx, x0 + nx, x0, x0] ;X points
	py = [y0, y0, y0 + ny, y0 + ny, y0] ;Y values

	plots,px, py, col=col, /dev, thick=1, lines=0  ;Draw the box
	wait, .1		;Dont hog it all
	endwhile
end

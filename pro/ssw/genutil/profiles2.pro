; $Id: profiles.pro,v 1.2 1994/06/08 22:37:00 dan Exp $

; restores window id and !x and !y variables for profiles2
pro profiles_focus_win, w,x,y
wset, w
!x = x
!y = y
end

;-----

function profiles2_event, event

return, event

end

;-----

pro profiles2, image, window_id=window_id, xaxis=xaxis, yaxis=yaxis, utbase=utbase, $
	wsize = wsize, exactlabel=exactlabel, $
	angled=angled, averaged=averaged

;+
; NAME:
;	PROFILES2
;
; PURPOSE:
;	Interactively draw row or column profiles of an image in a separate
;	window.  Based on RSI's profiles.pro which works only in simple cases.
;
;	This version works for:
;	1.  Draw widget as well as simple graphics window
;	2.  Scaled pixel size ((i.e. one unit on x or y axis does not correspond to one data pixel)
;	3.  Zoomed in images with partial pixels on the edges
;	4.  Drawing profiles of any angle through image
;	5.  Showing profiles of the average over row or columns
;	6.  Spectrogram profiles where x axis is ut, and y axis may be log
;
; CATEGORY:
;	Image analysis.
;
; CALLING SEQUENCE:
;	PROFILES, Image [, window_id=window_id, $
;	xaxis=xaxis, yaxis=yaxis, utbase=utbase, angled=angled, averaged=averaged ]
;
; INPUTS:
;	Image:	2D array that contains the image displayed in current
;		window.  This data need not be scaled into bytes.
;		The profile graphs are made from this array.  Even if displayed image
;		is zoomed in, this variable shoudl contain full array.
;
; KEYWORD PARAMETERS:
;	window_id:  Window id or draw widget id of window containing image to profile.
;		 if not passed, defaults to !d.window.  If passed, and is a draw widget id, then
;		instead of using cursor, an event handler is used (on unix systems using cursor
;		in a draw window causes some weird behavior)
;	xaxis - edges of x axis bins of full image (non-zoomed) in data coordinates
;	yaxis - edges of y axis bins of full image (non-zoomed) in data coordinates
;	utbase - if x axis is time (for spectrograms), base time that xaxis values are relative to
;	angled - if set, profiles are taken at angles through image
;	averaged - if set, average of rows or columns (zoomed in parts) are profiled. Note - can't
;		use averaged with angled.
;	wsize - The size of the PROFILES window as a fraction or multiple
;		of 640 by 512 (default is .75)
;	exactlabel - if set, then x, y values in label in profile are exact, not center of bin
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	A new window is created and used for the profiles.  When done,
;	the new window is deleted.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	A new window is created and the mouse location in the original
;	window is used to plot profiles in the new window.  Pressing the
;	left mouse button toggles between row and column profiles.
;	The right mouse button exits.  If doing angled profiles, then
;	pressing the left mouse button defines a new starting point for
;	the line.
;
; EXAMPLE:
;
;	If image or spectrogram is shown in a plotman window:
;		plotman_obj -> profiles
;
;	Simple example with simple window:
;	Create and display the image by entering:
;
;		A = BYTSCL(DIST(256))
;		plot_image, A
;
;	Run the PROFILES routine by entering:
;
;		PROFILES2, A
;
;	The PROFILES window should appear.  Move the cursor over the original
;	image to see the profile at the cursor position.  Press the left mouse
;	button to toggle between row and column profiles.  Press the right
;	mouse button (with the cursor over the original image) to exit the
;	routine.
;
;   Can also use with a draw widget.
;
; MODIFICATION HISTORY:
;	DMS, Nov, 1988.
;   Profiles2 is based on RSI's Profile.  Extensively rewritten in July 2000 by
;	Kim Tolbert to handle additional cases mentioned above.  However the calling
;	arguments were needlessly complicated.  Major rewrite again in March 2005 to
;	simplify arguments and enable averaging and spectrogram profiles.
;
;	30-Oct-96 (MDM) - Added printing the data value at the cross hair
;			- Added x0, y0, xfactor, yfactor options
;	19-Jul-2000 - Kim Tolbert, extensively rewritten to be more general.  Added lots
;		of keywords to handle cases where zoomed in image doesn't show whole data
;		pixels, data pixels are scaled, and input window is a draw widget.
;	17-Aug-2000 - Kim, added check for if user closes profiles window directly instead of
;		clicking right mouse button.
;   13-Jan-2001 - Kim, added exactlabel keyword (and changed to default to printing
;			x,y position at center of pixel instead of exactly where cursor is.
;		Made crosshairs a little smaller
;		Added 1/2 pixel to xdata_fix,ydata_fix and vecx,vecy so that we'll plot and label points
;			at the centers of pixels instead of leading edge.
;		Set position of profile window at 10,10 (which will be different for Win and X, but OK).
;	18-Mar-2002 - Kim, added angled option
;	21-Mar-2005 - Kim, added averaged option, added ability to profile from spectrograms.  This
;		required handling non-equal bins, so this was a major rewrite, and in the process,
;		I realized that everything was much simpler if I just pass in the x and y axis values,
;		which simplified the calling arguments significantly (previously was passing details
;		about where origin was, where plotted origin was, etc.).  If anyone was using the old
;		version, I apologize, but this is much simpler and more versatile.
;	22-Apr-2005 - Kim.  changed average keyword to averaged so won't conflict with function
;	25-Apr-2005 - Kim.  Wasn't taking care of reversed y axis.  Fixed.
;	22-Jun-2005 - Kim.  Use double when converting xy position to data coords in case x is time.
;		Also, if x is time, print time in label.
;		Also, move label down to y=0. (from .02) so it's not in the way of 'distance...' label
;	25-May-2006 - Kim.  Added another check for wopen(new_w) in case user closed window directly.
;-

image_size = size(image)
if image_size(0) ne 2 then begin
	message,'Error - Input to profile routine must be a 2-dimensional image.', /cont
	return
endif

checkvar, angled, 0
checkvar, averaged, 0
if angled then averaged = 0  ; can't do average if angled is selected
checkvar, wsize, .75

x_is_ut = keyword_set(utbase)
if x_is_ut then utb = anytim(utbase)

device,get_visual_name=visual_name
truecolor = visual_name eq 'TrueColor'

orig_w = !d.window

isdraw = 0
; if user passed in window_id, check if it is a valid draw widget.  If not, must be an open
;	window.
if exist (window_id) then begin
	if xalive(window_id) then begin
		if widget_info(window_id, /name) eq 'DRAW' then begin
			widget_control, window_id, get_value=orig_w
		 	isdraw = 1
		 endif
	endif else begin
		orig_w = !d.window
		device, window_state=w
		if window_id lt n_elements(w) then if w(window_id) then orig_w = window_id
	endelse
endif

if orig_w eq -1 then begin
	message, 'Error - invalid original window.', /cont
	return
endif

orig_x = !x
orig_y = !y
y_is_log = !y.type

; for draw widgets, save settings so we can restore them on exit, then set to use
;	profiles2_event event handler for motion and button events
if isdraw then begin
	sav_draw_motion_events = widget_info(window_id, /draw_motion_events)
	sav_draw_button_events = widget_info(window_id, /draw_button_events)
	sav_event_pro = widget_info(window_id,/event_pro)
	sav_event_func = widget_info(window_id,/event_func)

	widget_control, window_id, /draw_motion_events, /draw_button_events
	widget_control, window_id, event_pro=''
	widget_control, window_id, event_func='profiles2_event'
endif

catch, error
if error ne 0 then begin
	msg = 'Error in Profiles2: ' + !err_string
	print, msg
	a = dialog_message(msg)
	goto, quit
endif

nx_full = image_size[1]
ny_full = image_size[2]
checkvar, xaxis, indgen(nx_full+1)
checkvar, yaxis, indgen(ny_full+1)

; xminmax, yminmax are min and max of plotted part of image
xminmax = crange('X') > min(xaxis) < max(xaxis)
yminmax = crange('Y') > min(yaxis) < max(yaxis)

; nx_min... are x and y, min and max image element number of plotted part of image
nx_min = value_locate(xaxis, xminmax[0]) < (nx_full-1)
nx_max = value_locate(xaxis, xminmax[1]) < (nx_full-1)
ny_min = value_locate(yaxis, yminmax[0]) < (ny_full-1)
ny_max = value_locate(yaxis, yminmax[1]) < (ny_full-1)
; take care of y axis in reverse direction
if ny_min gt ny_max then begin
	tmp = ny_min
	ny_min = ny_max
	ny_max = tmp
endif

; nx, ny are number of elements in x and y direction of plotted part of image
nx = nx_max - nx_min + 1
ny = ny_max - ny_min + 1

xaxis_mid = get_edge_products(xaxis, /mean)  ;midpoints of full x axis
yaxis_mid = get_edge_products(yaxis, /mean)  ;midpoints of full y axis

image_range = minmax(image(nx_min:nx_max, ny_min:ny_max))	;data range of displayed portion

; if we're averaging, we need column and row averages for part of image that shows
col_av = average(image[*,ny_min:ny_max], 2)
row_av = average(image[nx_min:nx_max,*], 1)
col_av_range = minmax(col_av[nx_min:nx_max])
row_av_range = minmax(row_av[ny_min:ny_max])

;IF (!Version.Os NE 'MacOS') THEN tvcrs,sx+nx/2,sy+ny/2,/dev ELSE tvcrs,1
tickl = 0.07				;Cross length

if angled then begin
	full_image = tvrd(true=truecolor)
	print,'Left mouse button to change starting point.'
	print,'Right mouse button to Exit.'
endif else begin
	print,'Left mouse button to toggle between rows and columns.'
	print,'Right mouse button to Exit.'
endelse

window, /free, xs=wsize*640, ys=wsize*512, title='Profiles', xpos=20, ypos=20 ;Make new window
new_w = !d.window
new_x = !x
new_y = !y

old_mode = -1				;Mode = 0 for rows, 1 for cols
old_font = !p.font			;Use hdw font
!p.font = 0
mode = 0


if angled then begin
	xstart = xminmax[0]
	ystart = yminmax[0]
	; x axis is distance along line, so max distance is from corner to corner
	vecx = [0., sqrt( (xminmax[1]-xminmax[0])^2 + (yminmax[1]-yminmax[0])^2 )]
	plot, vecx, image_range, /nodata, /ynozero, title='Profile at angle', $
		xrange=minmax(vecx), yrange=image_range, xstyle=1, $
		xtitle='                            Distance along line'
	crossx = [-tickl, tickl] * (!x.crange[1]-!x.crange[0])
	crossy = [-tickl, tickl] * (!y.crange[1]-!y.crange[0])
	new_x = !x
	new_y = !y
	profiles_focus_win, orig_w, orig_x, orig_y
endif

first = 1

; Main loop to get location of cursor, and plot profiles

while 1 do begin

	profiles_focus_win, orig_w, orig_x, orig_y		; set focus on image window
	switch_mode = 0
	quit = 0
	if isdraw then begin
		ev = widget_event (window_id)
		x = ev.x  &  y = ev.y
		if ev.press then switch_mode = 1
		if ev.release eq 4 then quit = 1
	endif else begin
		cursor,x,y,2,/dev	;Read position
		if !mouse.button then switch_mode = 1
		if !mouse.button eq 4 then quit = 1
	endelse

	if quit  then goto, quit

	; xdata, ydata is position of cursor in data coordinates
	xydata = convert_coord(double([x, y]), /dev, /to_data)	; need double in case x is time
	xdata = xydata[0]
	ydata = xydata[1]
	; is cursor position within plot window?
	in_image = (xdata ge xminmax[0] and xdata lt xminmax[1]) and $
				(ydata ge min(yminmax) and ydata lt max(yminmax))
	xelem = in_image ? value_locate( xaxis, xdata) : -1
	yelem = in_image ? value_locate( yaxis, ydata) : -1
	;xdata_fix, ydata_fix is center of pixel nearest position of cursor
;	if in_image then stop
	xdata_fix = in_image ? xaxis_mid[xelem] : 0
	ydata_fix = in_image ? yaxis_mid[yelem] : 0

	if switch_mode then begin
		mode = 1 - mode		;Toggle mode (row/column display)
		if not isdraw then repeat cursor,x,y,0,/dev until !err eq 0
		xstart = xdata  & ystart = ydata
	endif

	; check if user closed profile window, instead of clicking right mouse button
	device, window_state=wopen
	if not wopen(new_w) then goto, quit
	profiles_focus_win, new_w, new_x, new_y		;Graph window

	if not angled then begin
		if mode ne old_mode then begin		; Switch mode (row or column display)
			old_mode = mode
			first = 1

			if mode then begin		; switch to column display

				xrange = averaged ? row_av_range : image_range
				vecy = yaxis_mid[ny_min:ny_max]
				xmm = minmax(xaxis_mid[nx_min:nx_max])
				ymm = [vecy[0], last_item(vecy)]
				if x_is_ut then begin
					tmm = anytim(xmm+utb, /vms, /time, /trunc)
					xav_lab = ', Average of ' +  tmm[0]  + ' to ' + tmm[1]
				endif else begin
					xav_lab = ', Average of X = ' + string(xmm, format='(f7.1," to ",f7.1)')
				endelse
				title = 'Column Profile' + (averaged ? xav_lab : '')
				plot, xrange, vecy, /nodata, /ynozero, title=title, $
					xrange=xrange, yrange=ymm, ystyle=1, xstyle=0, ylog=y_is_log

			endif else begin		; switch to row display

				vecx = xaxis_mid[nx_min:nx_max]
				yrange = averaged ? col_av_range : image_range
				ymm = [yaxis_mid[ny_min], yaxis_mid[ny_max]]
				yav_lab = ', Average of Y = ' + string(ymm, format='(f7.1," to ",f7.1)')
				title = 'Row Profile' + (averaged ? yav_lab : '')
				if x_is_ut then begin
					utplot, vecx, yrange, utb, /nodata, /ynozero, title=title, $
						xrange=minmax(vecx), yrange=yrange, xstyle=1, /nolabel
				endif else begin
					plot, vecx, yrange, /nodata, /ynozero,title=title, $
						xrange=minmax(vecx), yrange=yrange, xstyle=1, ystyle=0
				endelse

			endelse
			crossx = [-tickl, tickl] * (!x.crange[1]-!x.crange[0])
			crossy = [-tickl, tickl] * (!y.crange[1]-!y.crange[0])
			new_x = !x
			new_y = !y
		endif
	endif

	; if cursor is within range of displayed image, then draw profile
	if in_image then begin

		if first eq 0 then begin	;Erase?
			plots, vecx, vecy, psym=-2, symsize=.3, col=0	;Erase graph
			plots, old_x, old_y, col=0	;Erase cross
			plots, old_x1, old_y1, col=0
			xyouts,.01,0.,/norm,text_info,col=0	;Erase text
			empty
		  endif else first = 0

		ixy = image(xelem,yelem)
		image_val = ixy		;Data value
		if averaged then ixy = mode ? row_av[yelem] : col_av[xelem]

		if keyword_set(exactlabel) then begin
			xuse = xdata
			yuse = ydata
		endif else begin
			xuse = xdata_fix
			yuse = ydata_fix
		endelse

		; add 0L because if image is byte array, strtrim(ixy) will interpret ixy as character, not number
		if averaged then $
			av_val = '     ' + (mode ? 'Row' : 'Column') + ' Average = ' + trim(ixy+0L) else av_val = ''
		xytext = x_is_ut ? anytim(xuse+utb, /vms, /time, /trunc) + string(yuse, format='(" ",f7.1)') : $
			string(xuse, yuse, format='(f7.1," ",f7.1)')
		text_info = ' X, Y = ' + xytext + $
					'   Image value = ' +  trim(image_val+0L) + av_val


		if angled then begin
				profiles_focus_win, orig_w, orig_x, orig_y
				;don't erase in between - makes it jumpy
				if truecolor then begin
					device,decompose=1 & tv,full_image,/true & device,decompose=0
				endif else tv,full_image
				; use exact xdata (not xuse) for finding edge points of line
				find_edge_intercept, [xstart, xdata], [ystart, ydata], xedge, yedge
				xy = find_pixel_intersects(xedge, yedge, xaxis, yaxis, ylog=y_is_log, $
					[nx, ny], dist=dist, xvals=xvals, yvals=yvals)
				plots, xedge, yedge
				;xvals, yvals are center of pixels we actually used
				plots, xvals, yvals, psym=5, symsize=.5
				vecx = dist
				vecy = image[xy[*,0], xy[*,1]]
				; use x,y at center of pixel for drawing cross
				dist_x = sqrt( (xuse - xedge[0])^2 + (yuse - yedge[0])^2 )
				old_x = [ dist_x, dist_x]
				old_y = crossy + ixy
				old_x1 = crossx + dist_x
				old_y1 = [ixy,ixy]
				if not wopen(new_w) then goto, quit
				profiles_focus_win, new_w, new_x, new_y

		endif else begin
			if mode then begin		;Columns?
				vecx = averaged ? row_av[ny_min:ny_max] : image[xelem,ny_min:ny_max]	;get column
				old_x = crossx + ixy
				old_y = [ ydata_fix, ydata_fix]
				old_x1 = [ixy, ixy]
				old_y1 = !y.type ? 10 ^ (crossy + alog10(ydata_fix)) : crossy + ydata_fix
			endif else begin
				vecy = averaged ? col_av[nx_min:nx_max] : image[nx_min:nx_max,yelem] ;get row
				old_x = [ xdata_fix, xdata_fix]
				old_y = crossy + ixy
				old_x1 = crossx + xdata_fix
				old_y1 = [ixy,ixy]
			endelse
		endelse

		xyouts,.01,0.,/norm,text_info	;Text of location
		plots,vecx,vecy, psym=-2, symsize=.3		;Graph
		plots,old_x, old_y	;Cross
		plots,old_x1, old_y1
	endif

endwhile

quit:
profiles_focus_win, orig_w, orig_x, orig_y
;IF (!Version.Os NE 'MacOS') THEN tvcrs,nx/2,ny/2,/dev	;curs to old window
;tvcrs,0				;Invisible
device, window_state=wopen
if exist(new_w) then if wopen(new_w) then wdelete, new_w
if exist(old_font) then !p.font = old_font
if isdraw then begin
	if sav_event_pro ne '' then widget_control, window_id, event_pro=sav_event_pro
	if sav_event_func ne '' then widget_control, window_id, event_func=sav_event_func
 	widget_control, window_id, draw_button_events=sav_draw_button_events, $
                        draw_motion_events=sav_draw_motion_events
endif

if angled then begin
	if truecolor then begin
		device,decompose=1 & tv,full_image,/true & device,decompose=0
	endif else tv, full_image
endif

return

end

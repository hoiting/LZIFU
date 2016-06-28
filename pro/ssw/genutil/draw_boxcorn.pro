pro draw_boxcorn, x0,y0,x1,y1, $
		nxparts, nyparts, nytot, nyskip, $
		label, lab_siz, lab_dir, lab_col, data=data, device=device, color=color
;+
;NAME:
;	draw_boxcorn
;PURPOSE:
;	To draw a box on the screen in either data or device coordinates
;SAMPLE CALLING SEQUENCE:
;	draw_boxcorn, x0, y0, x1, y1
;INPUT:
;	x0	- The lower left x coordinate
;	y0	- The lower left y coordinate
;	x1	- The upper right x coordinate
;	y1	- The upeer right y coordinate
;OPTIONAL INPUT:
;	nxparts - Draw this many x grid marks
;	nyparts	- Draw this many y grid marks
;	nytot 	- screen size excluding lines at the bottom to skip
;	nyskip  - number of lines to skip a the bottom (for color bar)
;	label	- optional label to be put in lower left corner
;	lab_siz	- size of the label
;	lab_dir	- orientation of the label
;	lab_col	- color of the label
;OPTIONAL KEYWORD INPUT:
;	device	- If set, use device coordinates (DEFAULT)
;	data	- If set, use data coordinates
;	color	- If set, use that color
;HISTORY:
;	Written Oct-91 by M.Morrison
;	18-Jun-93 (MDM) - Added COLOR option and documentation header
;-
;
;
if (n_elements(nxparts) eq 0) then nxparts=1
if (n_elements(nyparts) eq 0) then nyparts=1
if (n_elements(fact) eq 0) then fact = 1
if (n_elements(nyskip) eq 0) then nyskip = 0
if (n_elements(color) eq 0) then color = !p.color
;
device = 1
if (keyword_set(data)) then device = 0
plots, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0], device=device, color=color
;
if (nxparts gt 1) then for i=1,nxparts-1 do begin
    temp=float(x1-x0)/nxparts*i + x0
    plots, [temp, temp], [y0, y1], device=device, color=color
end
if (nyparts gt 1) then for i=1,nyparts-1 do begin
    temp=float(y1-y0)/nyparts*i + y0
    plots, [x0, x1], [temp, temp], device=device, color=color
end
;
if (n_elements(label) ne 0) then begin
    if (n_elements(lab_siz) eq 0) then siz = 0    else siz = lab_siz
    if (n_elements(lab_dir) eq 0) then dir = 0    else dir = lab_dir
    if (n_elements(lab_col) eq 0) then col = 255  else col = lab_col
    xyouts, x, y, label, size=siz, orientation=dir, color=col, device=device
end
;
return
end 

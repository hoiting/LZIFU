function font_size,charsize,ypix,wxs=wxs,wys=wys
;+
;  Name:
;    font_size
;  Purpose:
;    Determine character width and height in pixels for a given
;    value of CHARSIZE
;  Calling sequence:
;    xpix = font_size(charsize, ypix)
;    xpix = font_size(charsize, ypix ,wxs=wxs, wys=wys)
;  Inputs:
;    charsize	= Value of plotting keyword CHARSIZE to be tested
;  Outputs:
;    xpix	= Size of character in pixels in x direction)
;    ypix	= Size of character in pixels in y direction)
;  Optional Input Keywords:
;    wxs	= Size of the pixmap window (default is 64)
;    wys	= Size of the pixmap window (default is 64)
;  Method:
;    Open a window and then read back the results
;  Side effects:
;    A PIXMAP window will be created temporarily and then destroyed
;  Modification History:
;    9-apr-93 - GLS based on TEXT_SIZE.PRO by JRL
;   11-Jul-96 (MDM) - Corrected to preserve the device setting when
;		      it was called.
;-

device_save = !d.name			; Save current device setting
set_plot, 'x'		; Make sure we working with the X-device

if n_elements(wxs) eq 0 then wxs = 64
if n_elements(wys) eq 0 then wys = 64

window_save = !d.window			; Save the current window index
wdef,wnum,/pixmap,wxs,wys

xpos = wxs * .10
ypos = wys * .10			; Placement in the temporary window

xyouts,.1,.1,'O',charsize=charsize,/dev	; Write the text
dump = tvrd(0,0,wxs,wys)		; Read it back

xxx = sumcol( dump )			; Collapse to a row vector
yyy = sumrow( dump )			; Collapse to a column vector

ix = where(xxx gt 0)
iy = where(yyy gt 0)

xmin = min(ix) & xmax = max(ix) 
ymin = min(iy) & ymax = max(iy) 

xpix = xmax-xmin+1
ypix = ymax-ymin+1

!c = 0

wdelete,wnum					; Delete the window
if window_save gt 0 then wset,window_save	; Restore the window index

set_plot, device_save
return, xpix

end




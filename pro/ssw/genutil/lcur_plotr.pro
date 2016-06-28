pro lcur_plotr, image, marks, index, qas_image=qas_image, xsiz=xsiz, ysiz=ysiz
;
;+
;NAME:
;	lcur_plotr
;PURPOSE:
;       To generate a line plot showing the location of the regions selected.
;	Overlay the regions selected on top of a contour of an image.  Called
;	by LCUR_IMAGE
;SAMPLE CALLING SEQUENCE:
;	lcur_plotr, image, marks, index
;INPUT:
;	image	- A single image array
;       marks   - The subscripts within the image that were selected.  The
;                 output array is NxM where N is the largest number of subscripts
;                 that were selected in a region, and M is the number of
;                 different regions selected.  When padding is necessary, the
;                 value is set to -1, so that value needs to be avoided.
;	index	- The index for the image so that the time/date can be
;		  provided in the contour image.
;OPTIONAL KEYWORD INPUT:
;	qas_image- If set, display the data as an image, not a contour plot
;HISTORY:
;       Written 18-Oct-93 by M.Morrison
;	29-Nov-93 (MDM) - Modified the header information
;	16-Feb-95 (MDM) - Added /QAS_IMAGE option
;	28-Feb-95 (MDM) - Modified how /QAS_IMAGE worked - use TV2 so
;			  that hardcopy is possible
;	08-Apr-98, William Thompson, GSFC
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;-
;
nx = n_elements(image(*,0))
ny = n_elements(image(0,*))
if (n_elements(xsiz) eq 0) then xsiz=nx
if (n_elements(ysiz) eq 0) then ysiz=ny
;
nmarks = n_elements(marks(0,*))
;
bin = 1
qimage = keyword_set(qas_image)
if (qimage) then begin
    ;tvscl, congrid(image, xsiz, ysiz)
    if (!d.name eq 'PS') then tv2, xsiz, ysiz, /init
    erase
    tv2, bytscl(congrid(image, xsiz, ysiz), top=!d.table_size), 0, 0
    bin = xsiz / n_elements(image(*,0))
end else begin
    contour, image, xstyle=1, ystyle=1, tit='Image Taken: ' + fmt_tim(index)
end

for i=0,nmarks-1 do begin
    barr = bytarr(nx, ny)
    ss = where(marks(*,i) ne -1)
    marks0 = marks(ss,i)
    barr(marks0) = 1b
    ;;if (qimage) then barr = congrid(barr, xsiz, ysiz)
    ;;if (qimage) then position=[0,0,xsiz,ysiz] else position=0
    ;;contour, barr, /noerase, xstyle=1+4, ystyle=1+4, thick=2, levels=[0,1], device=qimage, position=position
    if (qimage) then begin
	ocontour, barr, bin=bin, /tv2, color=!d.table_size
    end else begin
	contour, barr, /noerase, xstyle=1+4, ystyle=1+4, thick=2, levels=[0,1]
    end
    ;
    x0 = (min(marks0) mod nx) + nx*0.02
    y0 = (min(marks0) / nx)   + ny*0.02
    str = string(byte(65+i))
    if (qimage) then begin
	xyouts2, x0*bin, y0*bin, str, siz=2, /device
    end else begin
	xyouts, x0*bin, y0*bin, str, siz=2, charthick=2
    end
end
;
end

pro markplot, dpix, npix, uselast=uselast, box=box, circle=circle, plus=plus, $
	_extra=_extra
;+
;   Name: markplot
;
;   Purpose: highlight features on plot (default is open crosshair)
;
;   Input Parameters:
;      dpix - distance from marked poition to start highlinght (def=10 pix)
;	      (for /box, dpix=box half-width, for /circle, dpix= circle radius)
;
;      npix - length of highlight from dpix (only used for open crosshair)
;
;   Keyword Parameters:
;      box    - if set, draw a box of diameter=2*dpix
;      circle - if set, draw a circle of radius=dpix
;      plus   - if set, draw a plussign of length=2*dpix
;
;   Calling Sequence:
;      markplot [,dpix [,npix , /uselast , color=color, thick=thick, $
;				/box , /circle  ]]
;
;   Calling Examples:
;      markplot                      ; open crosshair at cursor
;      markplot,15,/box,thick=2      ; 15x15 box at cursor.
;      markplot,5, /plus             ; 10 pix long plussign at cursor
;      for i=5,55,10 do markplot,i,/uselast,/circle  ; uselast & circle
;      for i=5,55,10 do markplot,i,/uselast,/box     ; demo uselast & box
;
;   History:
;      10-Nov-1993 (SLF)
;       2-nov-1994 (SLF) add keyword inheritance - add PLUS keyword, document
;
;   Restrictions:
;      Uses keyword inheritance which was not introduced until IDL V3.2.
;-
common markplot_blk, lx, ly, dpixc, npixc, modec

if n_elements(lx) eq 0 then begin
   npixc=10
   dpixc=5
endif


if keyword_set(uselast) and n_elements(lx) ne 0 then begin
   x=lx
   y=ly
endif else begin
   device,/cursor_original
   message,/info,'Mark with cursor...'
   cursor,x,y,3,/device
   lx=x
   ly=y
endelse

if n_elements(dpix) eq 0 then dpix = dpixc else dpix=dpix
if n_elements(npix) eq 0 then npix = npixc else npix=npix

if keyword_set(plus) then begin		; special case of crosshair
   npix=dpix
   dpix=0
endif

mag=1					; not used yet
case 1 of 
;  -------------- box ------------------
   keyword_set(box): begin
      plots, [x-dpix, x+dpix, x+dpix, x-dpix, x-dpix], _extra=_extra, $
	     [y-dpix, y-dpix, y+dpix, y+dpix, y-dpix],/device
   endcase

;  ------------ circle ------------------
   keyword_set(circle): begin
      npts=32
      t = findgen(npts) * (2 * !pi / (npts-1))
      plots,dpix * cos(t) + x, dpix* sin(t) + y,/device , _extra=_extra
   endcase

;  ---------------- crosshair ------------
   else: begin
      plots,mag*[x+dpix, x+(dpix+npix)],mag*[y,y],/device,  _extra=_extra
      plots,mag*[x-dpix, x-(dpix+npix)],mag*[y,y],/device,  _extra=_extra
      plots,mag*[x,x],mag*[y+dpix, y+(dpix+npix)],/device,  _extra=_extra
      plots,mag*[x,x],mag*[y-dpix, y-(dpix+npix)],/device,  _extra=_extra
   endcase
endcase

return
end





pro arrow2,x0,y0,angle,length,head=head,angle=qangle,		$
	thick=thick,hthick=hthick,color=color,hsize=hsize,	$
	solid=solid,data=data,normalized=norm,device=device,	$
	tv2=tv2,qstop=qstop
;+
; NAME:
;   arrow2
; PURPOSE:
;   Wrapper routine for IDL user library ARROW routine.
;
;   arrow2 works with tv2 to provide easier PostScript placement.
;
; CALLING SEQUENCE:
;   arrow2, x0, y0, x1, y1                         ; Provide head & tail coordinates
;   arrow2, x0, y0, angle, length, /angle          ; x0,y0 = arrow's tail
;   arrow2, x0, y0, angle, length, /angle, /head   ; x0,y0 = arrow's head
;   arrow2, x0, y0, angle, length, /angle, /tv2    ; Assume tv2,/init has been
;                                                    previously called (see below).
; INPUTS:
;   x0, y0	- Defines the tail of the arrow, or if /head is set, the
;		  head of the arrow.
;   x1, y1	- Defines the head of the arrow, or if /head is set, the
;		  the tail.
;
;   angle	- if /angle is set, is the angle in degrees, counter
;                 clockwise.  0.0 points to the right.
;   length	- If /angle is set, is the length of the arrow in device,
;                 data or normalized coordinates.
;
; OPTIONAL INPUT PARAMETERS:
;   /angle	- If set, 3rd and 4th parameters are the angle and length
;		  of the arrow, respectively.
;   /head	- To change x0, y0 to define the head of the arrow.
;
;   HSIZE, COLOR, HTHICK, THICK, SOLID are the same as in ARROW
;
;    DATA 	- if set, implies that coordinates are in data coords.
;    NORMALIZED - if set, coordinates are specified in normalized coords.
;    DEVICE	- if set, coordinates are specified in device coords.
;
;    /tv2	- if set, assumes tv2,/init, xsiz_pix, ysiz_pix has
;		  be previously called.  In this case, /data, /norm and
;		  and /dev will have no effect, since /dev will be assumed for
;		  X-output and the pseudo window pixel coordinates will be
;                 assumed for PostScript output.
;
; COMMON BLOCKS:
;  tv2_blk (which is created by tv2,/init).
;
; METHOD:
;  arrow2 requires the PostScript plotting size to be set by a previous call
;  to tv2/init,xsiz_pix,ysiz_pix (see the document header of tv2 for more
;  information), which stores various parameters in common.
;
; See also the following routines:
;		tv2, ocontour, draw_grid (sxt_grid), plots2
;
; MODIFICATION HISTORY:
;  23-Jan-1996, J. R. Lemen (LPARL), Written.
;  24-Jan-2002, Kim Tolbert.  Ensure that !p.psym is 0 before drawing arrow.
;  26-Dec-2002, Zarro (EER/GSFC) - removed unsupported /device in arrow call
;-

common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch

psym_save = !p.psym
!p.psym = 0

if not keyword_set(qangle) then begin 		; Provided x1 and y1 coordinates
  x1 = angle & y1 = length
endif else begin				; Provided with angle and length
  qlength = length * ([1,-1])(keyword_set(head))
  x1 = x0 + qlength * cos(angle*!pi/180)
  y1 = y0 + qlength * sin(angle*!pi/180)
endelse

if not keyword_set(head) then begin		; x0 and y0 is the tail
  xx1 = x1 & yy1 = y1 & xx0 = x0 & yy0 = y0
endif else begin				; Swap ends if /head is set.
  xx1 = x0 & yy1 = y0 & xx0 = x1 & yy0 = y1
endelse

if keyword_set(tv2) then begin			; /tv2 - always use device coordinates
  norm0=0 & data0=0 & device0=1

  if !d.name eq 'PS' then begin			; Convert to pseudo pixel
    xx0 = xx0 / float(xsiz_pix) * !d.x_size	;- coordinates for PostScript
    xx1 = xx1 / float(xsiz_pix) * !d.x_size	;- output.
    yy0 = yy0 / float(ysiz_pix) * !d.y_size
    yy1 = yy1 / float(ysiz_pix) * !d.y_size
  endif

endif else begin				; Not /tv2, simply pass to arrow
  norm0   = keyword_set(norm)
  data0   = keyword_set(data)
  device0 = keyword_set(device)
endelse

;-- if /device then unset /norm & /data

if keyword_set(device0) then begin
 norm0=0b & data0=0b
endif

arrow,xx0,yy0,xx1,yy1,thick=thick,hthick=hthick,solid=solid,	$
      color=color,hsize=hsize,norm=norm0,data=data0

!p.psym = psym_save

if keyword_set(qstop) then stop
end

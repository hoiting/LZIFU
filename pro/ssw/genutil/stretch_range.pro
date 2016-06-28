Pro Stretch_range, Low, High, Gamma, CHOP = Chop, range=range
;+
; NAME:
;	STRETCH_RANGE
;
; PURPOSE:
;       stretch color table (stretch within user supplied range only)
;
; CATEGORY:
;	Image processing, point operations.
;
; CALLING SEQUENCE:
;	STRETCH_RANGE, Low, High [, /CHOP], range=[min,max]
;
; INPUTS:
;	Low:	The lowest pixel value to use.  If this parameter is omitted,
;		0 is assumed.  Appropriate values range from 0 to the number 
;		of available colors-1.
;
;	High:	The highest pixel value to use.  If this parameter is omitted,
;		the number of colors-1 is assumed.  Appropriate values range 
;		from 0 to the number of available colors-1.
;
; OPTIONAL INPUTS:
;	Gamma:	Gamma correction factor.  If this value is omitted, 1.0 is 
;		assumed.  Gamma correction works by raising the color indices
;		to the Gamma power, assuming they are scaled into the range 
;		0 to 1.
;
; KEYWORD PARAMETERS:
;	CHOP:	If this keyword is set, color values above the upper threshold
;		are set to color index 0.  Normally, values above the upper 
;		threshold are set to the maximum color index.
;
;       RANGE:  If set, only effect indices within this range 
;               (if not set, behaves like RSI parent program: stretch.pro)
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	COLORS:	The common block that contains R, G, and B color
;		tables loaded by LOADCT, HSV, HLS and others.
;
; SIDE EFFECTS:
;	Image display color tables are loaded.
;
; RESTRICTIONS:
;	Common block COLORS must be loaded before calling STRETCH.
;
; PROCEDURE:
;	New R, G, and B vectors are created by linearly interpolating
;	the vectors in the common block from Low to High.  Vectors in the 
;	common block are not changed.
;
;	If NO parameters are supplied, the original color tables are
;	restored.
;
; EXAMPLE:
;	Load the STD GAMMA-II color table by entering:
;
;		LOADCT, 5
;
;	Create and display and image by entering:
;
;		TVSCL, DIST(300)
;
;	Now adjust the color table with STRETCH.  Make the entire color table
;	fit in the range 0 to 70 by entering:
;
;		STRETCH, 0, 70
;
;	Notice that pixel values above 70 are now colored white.  Restore the
;	original color table by entering:
;
;		STRETCH
;
; MODIFICATION HISTORY:
;	DMS, RSI, Dec, 1983.
;	DMS, April, 1987.	Changed common.
;	DMS, October, 1987.	For unix.
;	DMS, RSI, Nov., 1990.	Added GAMMA parameter.
;       16-July-1996 - S.L.Freeland - add RANGE and changed name
;-
;
	common colors,r,g,b,cur_red,cur_green,cur_blue
;	on_error,2		;Return to caller if error
	nc = !d.table_size	;# of colors entries in device
	if nc eq 0 then message, $
		"Device has static color tables.  Can't modify.'

	if n_elements(r) le 0 then begin	;color tables defined?
		r=indgen(nc) & g=r & b=r & endif
	if n_params(0) lt 1 then low = 0
	if n_params(0) lt 2 then high = nc-1
	if n_params(0) lt 3 then gamma = 1.0	;Default gamma
	if high eq low then return		;Nonsensical

	if gamma eq 1.0 then begin		;Simple case
		slope = float(nc-1)/(high-low)  ;Scale to range of 0 : nc-1
		intercept = -slope*low
		p = long(findgen(nc)*slope+intercept) ;subscripts to select
	endif else begin			;Gamma ne 0
		slope = 1. / (high-low)		;Range of 0 to 1.
		intercept = -slope * low
		p = findgen(nc) * slope + intercept > 0.0
		p = long(nc * (p ^ gamma))
	endelse
	if keyword_set(Chop) then begin
		too_high = where(p ge nc, n)
		if n gt 0 then p(too_high)  = 0L
		endif

        case 1 of
	   n_elements(range) ge 2: ss=range(0:1)
	   n_elements(range) eq 1: ss=[range,n_elements(cur_red)-1>range]
	   n_elements(range) eq 0: ss=[0,n_elements(cur_red)-1]
        endcase
	
       cur_red(ss(0):ss(1))  = r(p(ss(0):ss(1)) ) 
        cur_green(ss(0):ss(1))= g(p(ss(0):ss(1)) ) 
        cur_blue(ss(0):ss(1)) = b(p(ss(0):ss(1)) ) 
        cur_red(ss(1)-1:*)=!p.color
        cur_green(ss(1)-1:*)=!p.color
        cur_blue(ss(1)-1:*)=!p.color
        tvlct,cur_red, cur_green, cur_blue
	return
end

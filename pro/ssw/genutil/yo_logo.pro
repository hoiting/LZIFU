;NAME:
;	YO_LOGO
;PURPOSE:  
;	superimposes a small image of sxt satellite on the display window
;CALLING SEQUENCE: 
;	logo [,x-coordinate, y-coordinate,[scale]]
;OPTIONAL INPUTS:
;	x: x-coordinate, assuming 512x512 image, from zero to one
;		(zero=left,..., one=right) entire logo always within 512x512
;		image                        default=0.9764706
;	y: y-coordinate
;		(zero=bottom,...one=top)     default=0.0217865
;	s: scale  default=1
;OUTPUTS:
;	2-D picture of sxt satellite in display window
;PROGRAMS/FUNCTIONS CALLED:
;	none
;RESTRICTIONS
;	assumes original image is 512x512
;HISTORY:
; 	MGC, Nov, 1992.	

pro yo_logo, x, y, s

;constants:
max_width	= 35.
max_length	= 21.
imgsize		= 512.
default_x	= 0.9764706
default_y	= 0.0217865
scale_factor	= 2.5

if (n_elements(s)) eq 0 then s=1. 
s=s*scale_factor
if (n_elements(x)) eq 0 then x=default_x
if (n_elements(y)) eq 0 then y=default_y
x=x*(imgsize-(max_width*s))
y=y*(imgsize-(max_length*s))   
print, x, y, s
;first set of solar cells
polyfill, x+s*[0,4,12,8],          	y+s*[11,13,9,7], 		$
							col=150, /device
polyfill, x+s*[4.5,8.5,16.5,12.5], 	y+s*[11+2.25,15.25,11.25,9.25],$
							col=150, /device
polyfill, x+s*[9,13,21,17],            	y+s*[15.5,17.5,13.5,11.5],     $
							col=150, /device

;sides and top of satellite
; bottom of satellite[17,23,17,11], [4,7,10,7]
polyfill, x+s*[17,23,17,11],       	y+s*[15,18,21,18],		$
							col=240, /device
polyfill, x+s*[17,17,11,11],  		y+s*[4,15,18,7],  		$
					  		col=220, /device
polyfill, x+s*[17,17,23,23],          	y+s*[4,15,18,7],  		$
							col=200, /device

;second set of solar cells
polyfill, x+s*[14,18,26,22],          	y+s*[4,6,2,0],             	$
							col=150, /device
polyfill, x+s*[18.5,22.5,30.5,26.5],	y+s*[6.25,8.25,4.25,2.25], 	$
							col=150, /device
polyfill, x+s*[23,27,35,31],          	y+s*[8.5,10.5,6.5,4.5],    	$
							col=150, /device

; telescope
a=findgen(16) * (!pi * 2/ 16.)
polyfill, x+s*[cos(a)+16], 		y+s*[0.5*sin(a) + 18], 	$
							col=20,  /device
polyfill, x+s*[cos(a)+16], 		y+s*[0.5*sin(a) + 17.8], 	$
					  		col=190, /device
polyfill, x+s*[.3*cos(a)+16], 		y+s*[0.15*sin(a) + 17.8], 	$
							col=40,  /device

;various panels
polyfill, x+s*[12,13,17.5,16.5],   	y+s*[18.5,18,20.25,20.75],	$
	    				 		col=225, /device
polyfill, x+s*[12.25,13,13.75,13],	y+s*[18.5,18.15,18.5,18.85],	$
							col=190, /device
polyfill, x+s*[15.25,16,16.75,16],	y+s*[20,19.65,20,20.35],	$
							col=190, /device
polyfill, x+s*[19,18,18,19],  	        y+s*[9.75,9.25,13.5,14],	$
							col=220, /device
polyfill, x+s*[21.5,20.5,20.5,21.5],	y+s*[10.75,10.25,14.5,15],	$
							col=220, /device
polyfill, x+s*[0.4*cos(a)+16], 		y+s*[0.7*sin(a) + 14.3], 	$
							col=90,  /device
return
end



;+
; Project     : SOHO - CDS     
;                   
; Name        : BOX_AV()
;               
; Purpose     : Produce a box average of an array.
;               
; Explanation : Takes the input array and averages the data points in boxes
;               of a given size.  The dimensions of the output array are the
;               same as the input with the elements in the output array
;               all given the average value within the box defined. In 1-d
;               arrays this is useful as the output array can then be plotted 
;               in histogram mode (psym=10).
;               
; Use         : IDL>  out_array = box_av(in_array,x_box [,y_box])
;
;                 eg  x = sin(indgen(1000)/100.)
;                     plot,x,psym=4 & oplot,box_av(x,60),psym=10
;    
; Inputs      : in_array    -  the input array, either 1 or 2-d
;               x_box       -  the x-size of the averaging box
;               
; Opt. Inputs : y_box       -  the y-size of the averaging box.  If input is
;                              2-d and y_box not specified then it defaults
;                              to the same value as x_box.
;               
; Outputs     : function value on return is the averaged array
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;               
; Restrictions: Only 1 or 2-d arrays.
;               
; Side effects: None
;               
; Category    : Utilities, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL,  21-Jul-1993
;               
; Modified    : 
;
; Version     : Version 1
;-            

function box_av, x, xpix, ypix

;
;  check enough parameters
;
if n_params() lt 2 then begin
   print,'Use:  IDL>  y = box_av(x,xbox [,ybox])'
   return,0
endif

;
;  create output array
;
y = x
s = size(x)
nx = s(1)

;
;  trap sillies
;
if s(0) gt 2 then begin
   bell
   print,'** Maximum of 2-d array allowed. **'
   return,0
endif

;
;  treat second dimension if necessary
;
if s(0) eq 2 then two_d = 1 else two_d = 0
if two_d then ny = s(2) else ny = 0
if two_d and n_params() lt 3 then ypix = xpix 

;
;  find number of averaging boxes
;
nboxx = float(nx)/float(xpix) & nboxx = fix(nboxx) > 1
if nboxx*xpix lt nx then nboxx = nboxx+1

if two_d then begin
   nboxy = float(ny)/float(ypix) & nboxy = fix(nboxy) > 1
   if nboxy*ypix lt ny then nboxy = nboxy+1
endif

;
;  do the work
;
if two_d then begin
   for j=0,nboxy-1 do begin
      ny1 = j*ypix
      ny2 = (j*ypix)+ypix-1 < (ny-1)
      for i=0,nboxx-1 do begin
         nx1 = i*xpix
         nx2 = (i*xpix)+xpix-1 < (nx-1)
         y(nx1:nx2,ny1:ny2) = total(x(nx1:nx2,ny1:ny2))/((nx2-nx1+1)*(ny2-ny1+1))
      endfor
   endfor
endif else begin
   for i=0,nboxx-1 do begin
      nx1 = i*xpix
      nx2 = (i*xpix)+xpix-1 < (nx-1)
      y(nx1:nx2) = total(x(nx1:nx2))/(nx2-nx1+1)
   endfor
endelse

;
;  return the output array
;
return,y

end

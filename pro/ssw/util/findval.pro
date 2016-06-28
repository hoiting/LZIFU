;+
; Project     : SOHO - CDS     
;                   
; Name        : FINDVAL
;               
; Purpose     : Linearly interpolates X,Y arrays for (xval,yval)
;               
; Category    : Interpolation
;               
; Explanation :
;               Uses linear interpolation to obtain xval or yval with respect to
;               input X,Y arrays. This function differs from INTERPOL
;               in that if finds multi-valued cases.
;               
; Syntax      : IDL> yval=findval(x,y,xval) or xval=findval(y,x,yval)
;    
; Examples    : 
;
; Inputs      : X and Y, floating arrays, e.g. wavelength & flux
;               
; Opt. Inputs : None
;               
; Outputs     : XVAL or YVAL are floating point arrays.
;               The size of these arrays (usually 1) = no of interpolated points
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; History     : Version 1,  17-May-1986,  D M Zarro.  Written 
;               (my very first real IDL program)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

        function findval,x,y,xval
        on_error,1

        r=-1
        n=n_elements(x) 
        if n le 1 then begin
         message,'insufficient points to interpolate'
         return,0
        endif

        yval=replicate(-1.,n) 
        if (min(y) eq 0.) and (max(y) eq 0.) then return,r
        xmin=min(x) & xmax=max(x)
        ymin=y(where (x eq xmin)) & ymax=y(where (x eq xmax))
        if (xval lt xmin) or (xval gt xmax) then return,r
  
        k=-1 & ic=-1 & r(0)=0.                 ;interpolate
	for i=1,n-1 do begin
         xmin= x(i-1) < x(i)
         xmax= x(i-1) > x(i)
         if (xval ge xmin) and (xval le xmax) then begin
          k=k+1

          if k gt n-1 then begin
           k=-1 & goto,loop
          endif

          den=x(i-1)-x(i)

          if den eq 0. then begin                 ;skip zero cases
           k=k-1 & goto, loop1
          endif else begin
           slope=(y(i-1)-y(i))/den
           yval(k)=y(i-1)+slope*(xval-x(i-1))      ;actual interpolation
          endelse

         endif
loop1:   ic=ic+1                                   ;do nothing
        endfor
loop:   if k lt 0 then return,r
        yval=yval(0:k)
        return,yval
	end


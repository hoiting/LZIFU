
; Copyright (c) 1999 Thomas R. Metcalf , Lockheed Martin Advanced Technology
; Center, Dept. L9-41, Bldg. 252, 3251 Hanover St., Palo Alto, CA  94304


FUNCTION SQUEEZE,XIN,YIN,YOUT=YOUT,index=index,nosort=nosort

;+
;NAME:
;     SQUEEZE
;PURPOSE:
;     Squeeze a vector down to unique elements (gets rid of values which are
;     in the vector more than once, leaving only one of each).  The order of
;     the input is preserved: the first instance of a value is kept and the 
;     following instances are dropped.
;CATEGORY:
;CALLING SEQUENCE:
;     xs = squeeze(x)
;     xs = squeeze(x,y)
;INPUTS:
;     x = a vector
;OPTIONAL INPUT PARAMETERS:
;     y = additional constraint such that x-elements and y-elements must 
;         both match for an element to be deleted.  x and y must have the 
;         same dimension.
;KEYWORD PARAMETERS
;     yout = y values after squeezing.  If /index is set, yout is the same
;            indices returned in xs.
;     /index = return indices to x, instead of the squeezed x.  The indices
;              are the x elements to keep, not the x elements to delete.
;     /nosort = do not sort the input array.  This has the effect of only
;               dropping non-unique elements which are adjacent.
;OUTPUTS:
;     xs = squeezed vector
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     Not guranteed to work with floating point.  
;     Works with int, long and char arrays.
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf  March 23, 1993 
;-

        ny = n_elements(yin)
        if ny GT 0 then begin
           if ny NE n_elements(xin) then $
              message,'x and y must have the same dimension'
        endif

        if NOT keyword_set(nosort) then begin
           if ny NE 0 then begin    ; Sort the input array with xin and yin
              xs = sort(strcompress(string(xin)+string(yin),/remove_all))
              y = yin(xs)
           endif $
           else xs = sort(xin)  ; Sort with xin only
           x = xin(xs)
        endif $
        else begin
           xs=lindgen(n_elements(xin))
           x = xin
           if ny NE 0 then y = yin
        endelse
        
	A = X NE SHIFT(X,1)	; Same as next value?
	A(0) = 1		; Always want first value.
        if ny NE 0 then begin
           B = Y NE SHIFT(Y,1)
           B(0) = 1
        endif 
	if ny NE 0 then begin
           W = WHERE(A OR B)    ; Look for value changes
        endif $
        else W = WHERE(A)	; Look for value changes.
        nw1 = n_elements(w)-1L
        good=min(xs(w(nw1):*))     ; Find the first instance of each value
        for i=nw1-1L,0L,-1L do good=[min(xs(w(i):(w(i+1)-1))),good]

        gsg = good(sort([good]))

        if keyword_set(index) then begin
           if ny NE 0 then yout=gsg
           return, gsg
        endif $
	else begin
           if ny NE 0 then yout = yin(gsg)
           return, xin(gsg) ; Put back in the original order
        endelse

END

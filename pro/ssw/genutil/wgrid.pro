pro wgrid,sx, sy, nx, ny, $
   color=color, linestyle=linestyle, thick=thick, $
   nocolumns=nocolumns, norows=norows, debug=debug
;+
;   Name: wgrid
;
;   Purpose: draw grid on current graphics display
;
;   Input Parameters:
;      sx - size of x grid ("columns")
;      sy - size of y grid ("rows")    (default = sx)
;      nx - number of "columns"	       (default is fill up window)
;      ny - number of "rows"	       (default is fill up window)
;
;   Calling Sequence:
;      wgrid, sx [,sy, nx, ny, color=color, linestyle=linestyle, thick=thick]
;
;   History:
;      1-feb-1996 (S.L.Freeland) - vectorized grid.pro
;-

if n_params() eq 0 then begin
   message,/info,"Need at least one parameter...
   message,/info,"IDL> wgrid, sx [,sy , nx, ny]
   return
endif

; window size
xs=!d.x_size
ys=!d.y_size

; set defaults for null paramters
if n_elements(sy) eq 0 then sy=sx		; same as x
if n_elements(nx) eq 0 then nx=xs/sx		; fill window
if n_elements(ny) eq 0 then ny=ys/sy		; fill window

nx=nx < xs/sx					; constrain to window
ny=ny < ys/sy					; constrain to window

; set keyword defaults
if n_elements(color) eq 0 then color=!p.color
if n_elements(thick) eq 0 then thick =1
if n_elements(linestyle) eq 0 then linestyle=0

; columns
debug=keyword_set(debug)

; columns
if not keyword_set(nocolumns) then begin
   nc=nx*2
   xcoord=reform(reform(rotate(rebin(indgen(nc)*sx, nc/2,2,/sample),9),nc,1))
   ycoord=lonarr(nc) & ycoord(lindgen(xs/sx)*2)=ys
   if debug then stop
   for i=0,nc-1,2 do plots,xcoord(i:i+1),ycoord(i:i+1), $
      color=color, thick=thick , linestyle=linestyle,/device
endif

; rows
if not keyword_set(norows) then begin
   nr=ny*2
   xcoord=lonarr(nr) & xcoord(lindgen(ys/sy)*2)=xs
   ycoord=reform(reform(rotate(rebin(indgen(nc)*sy, nr/2,2,/sample),9),nr,1))
   for i=0,nr-1,2 do plots,xcoord(i:i+1),ycoord(i:i+1), $
      color=color, thick=thick , linestyle=linestyle,/device
endif

return

end

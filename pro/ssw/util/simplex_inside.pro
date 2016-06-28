
;+

function simplex_inside,simplex,data,origin=origin

;NAME:
;     SIMPLEX_INSIDE
;PURPOSE:
;     Determine whether a coordinate or vector of coordinates is
;     inside a simplex
;CATEGORY:
;CALLING SEQUENCE:
;     inside = simplex_inside(simplex,coordiantes)
;INPUTS:
;     simplex = fltarr(ndim,ndim+1) is the simplex
;     coordinates = coordinates to check fltarr(ndin,npoints)
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;OUTPUTS:
;     inside = boolean array (npoints), 1=inside, 0 = outside the simplex
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf 2001-July-17
;-

ndimensions = n_elements(simplex[*,0])
if n_elements(data[*,0]) NE ndimensions then message,'Bad data size.'
ndata = n_elements(data[0,*])
if n_elements(origin) LE 0 then origin = fltarr(ndimensions) ; zeroes
if n_elements(origin) NE ndimensions then message,'Bad origin size'

inside = lonarr(ndata)
inside[*] = 0L

center = total(simplex,2)/(ndimensions+1L)

for i=0L,ndata-1L do begin
   for face = 0L,ndimensions do begin
      ssface = kill_index(lindgen(ndimensions+1),face)
      ; the location of the center of this face
      fcenter = total(simplex[*,ssface],2)/n_elements(ssface)
      ; vector from data to center of face
      dvector = data[*,i] - fcenter 
      dvector = dvector / sqrt(total(dvector^2))
      ; vector from center of simplex to center of face
      cvector = center - fcenter 
      cvector = cvector / sqrt(total(cvector^2))
      ; vector perpendicular to the face
      pvector = simplex_pvector(simplex,ssface)

      ; The vector from any vertex of the face to the center of the face
      ; should be perpendicular to pvector.

      ;print,'Check that',total((fcenter-simplex[*,ssface[0]])*pvector), $
      ;      ' is zero'

      ; If the data point is inside on the inside side of this face, then
      ; the dvector and the cvector will point on the same side of the face
      ; as dtermined by the dot products with the vector perpendicular to 
      ; the face.

      dotf = total(dvector*pvector)
      dotc = total(cvector*pvector)
      if sign(1,dotf) EQ sign(1,dotc) then inside[i] = inside[i] + 1L
   endfor
endfor

; if the data point is inside the simplex, then it will be on the correct
; side of each and every face.

ssinside = where(inside EQ ndimensions+1L,ninside)
inside = lonarr(ndata)
inside[*] = 0L
if ninside GT 0 then inside[ssinside] = 1

return,inside

end

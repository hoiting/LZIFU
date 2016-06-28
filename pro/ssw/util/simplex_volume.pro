
;+

function simplex_volume,simplex,scale

;NAME:
;     SIMPLEX_VOLUME
;PURPOSE:
;     Calculates the volume enclosed by a simplex
;CATEGORY:
;CALLING SEQUENCE:
;     volume = simplex_volume(simplex)
;INPUTS:
;     simplex = fltarr(ndim,ndim+1) fives the ndim+1 simplex vertices
;OPTIONAL INPUT PARAMETERS:
;     scale = scale parameter for each dimension fltarr(ndim)
;KEYWORD PARAMETERS
;OUTPUTS:
;     volume = the volume enclosed by the simplex
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf 2001-July-17
;-

ndimensions = n_elements(simplex[*,0])
if n_elements(scale) LE 0 then scale = replicate(1.0,ndimensions)
if n_elements(scale) NE ndimensions then message,'Bad scale size.'

; Apply the scale factors

ssimplex = double(simplex)
for i=0L,ndimensions do begin
   ssimplex[*,i] = double(simplex[*,i]-simplex[*,0])/double(scale)
endfor

; Now compute the volume (requires the first point to be the origin)

volume = abs(determ(ssimplex[*,1:*]))/factorial(ndimensions)

return,volume

end

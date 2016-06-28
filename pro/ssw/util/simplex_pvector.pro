
function simplex_get_perpendicular,pmatrix,avector,ndimensions

if n_elements(pmatrix) EQ 1 then begin
   if pmatrix[0] eq 0. then begin
      pvector = [1.,0.]
   endif else begin
      pvector = avector/pmatrix
      pvector = [pvector,1.0]
   endelse
endif else begin
   catch,error_status
   if error_status NE 0 then begin
      ; singular matrix
      ; First check if the face lies in a hyperplane which embeds the
      ; last axis.  If so, reduce the dimensionality by one.
      rpmatrix = pmatrix[0:ndimensions-3,0:ndimensions-3]
      ravector = avector[0:ndimensions-3]
      ; Recursively reduce the dimensionality by one
      pvector = simplex_get_perpendicular(rpmatrix,ravector,ndimensions-1)
      pvector = [pvector,0.0]
      ; The vector from any vertex of the face to the center of the face
      ; should be perpendicular to pvector.  If not give up and set the 
      ; vector to all zeroes to indicate an error.  This should not happen.
      fcenter = total(simplex[*,ssface],2)/n_elements(ssface)
      if abs(total((fcenter-simplex[*,ssface[0]])*pvector)) GT 1.e-3 then $
         pvector = replicate(0.0,ndimensions)
   endif else begin
      ; compute the perpendicular vector using LUD for the matrix
      ; inversion
      ludc,pmatrix,index,/double
      pvector = lusol(pmatrix,index,avector,/double)
      pvector = [pvector,1.0]
   endelse
   catch,/cancel
endelse

pvector = pvector / max(abs(pvector))  ; To avoid overflows in the norm
pnorm  =  sqrt(total(pvector^2))
if pnorm NE 0.0 AND finite(pnorm) then begin
   pvector = pvector / pnorm
endif

return,pvector

end


;+

function simplex_pvector,simplex,ssface

;NAME:
;     SIMPLEX_PVECTOR
;PURPOSE:
;     Compute a unit vector normal to a face of a simplex
;CATEGORY:
;CALLING SEQUENCE:
;     pvector = simplex_pvector(simplex,ssface)
;INPUTS:
;     simplex = the simplex fltarr(ndimensions,ndimensions+1)
;     ssface = the indices into the second dimension of simplex giving
;              the vertices of the face.  lonarr(ndimension).
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;OUTPUTS:
;     pvector = unit vector normal to the face.
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf 2001-July-18
;-

ndimensions = n_elements(simplex[*,0])

pmatrix = simplex[0L:ndimensions-2L,ssface[0]]-simplex[0L:ndimensions-2L,ssface[ndimensions-1]]
avector = -simplex[ndimensions-1L,ssface[0]]+simplex[ndimensions-1L,ssface[ndimensions-1]]
for j=1L,n_elements(ssface)-2L do begin
   pmatrix = [[[pmatrix]], $
               [simplex[0L:ndimensions-2L,ssface[j]] - $
                simplex[0L:ndimensions-2L,ssface[ndimensions-1]]]]
   avector = [avector,-simplex[ndimensions-1L,ssface[j]] + $
                       simplex[ndimensions-1L,ssface[ndimensions-1]]]
endfor
pvector = simplex_get_perpendicular(pmatrix,avector,ndimensions)

;fcenter = total(simplex[*,ssface],2)/n_elements(ssface)
;print,'Check that',total((fcenter-simplex[*,ssface[0]])*pvector), $
;      ' is zero'

return,pvector

end

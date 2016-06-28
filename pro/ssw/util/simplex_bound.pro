
function simplex_bound_amoeba,simplex
   common simplex_bound_private1,ndimensions,best_simplex,best_volume, $
                                 scale,data
   s = reform(simplex,ndimensions,ndimensions+1L)
   if min(simplex_inside(s,data)) LE 0 then f = 1.0e6 else f = 0.0
   v = simplex_volume(s,scale)
   if v+f LT best_volume then begin
      best_volume = v+f
      best_simplex = s
      ;message,/info,strcompress('Best volume: '+string(best_volume)+ $
      ;                           ' '+string(f))
   endif
   return, v+f
end

;+

function simplex_bound,datain,volume,verbose=verbose

;NAME:
;     SIMPLEX_BOUND
;PURPOSE:
;     Find a simplex that bounds a set of coordinates
;CATEGORY:
;CALLING SEQUENCE:
;     simplex = simplex_bound(coordinates[,volume])
;INPUTS:
;     data = fltarr(ndim,ndata) where ndim is the dimension of the data and
;             ndata is the number of coordinate points.  
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;OUTPUTS:
;     simplex = fltarr(ndim,ndim+1) give the ndim+1 simplex vertices
;     volume = the volume of the final simplex, scaled so that it should
;              be around 1.0 or so if all went well. (typically 0.2 -- 5.0)
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     There is some randomness here.  If getting the smallest simplex is
;     really important, run this program a few times and take the simplex
;     with the smallest volume.
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf 2001-Jul-17
;     T. Metcalf 2001-Dec-19 Added amoeba minimization
;-

common simplex_bound_private1,ndimensions,best_simplex,best_volume,scale,data

data = datain

ndimensions = n_elements(data[*,0])
ndata = n_elements(data[0,*])

if ndata LT ndimensions then message,'ndata must be GE ndimensions'

center = total(data,2)/ndata  ; The center of mass of the data

simplex = fltarr(ndimensions,ndimensions+1L)
scale = fltarr(ndimensions)

; Initial guess for simplex

for i=0L,ndimensions-1L do begin
   simplex[i,i] = max(data[i,*])
   simplex[i,ndimensions] = min(data[i,*])
   scale[i] = max(data[i,*])-min(data[i,*])
endfor
sstart = simplex

; Expand the simplex to include all the data

iter = 0L
i=0L
WHILE total(1-simplex_inside(simplex,data)) do begin
   scenter = total(simplex,2)/(ndimensions+1L)
   if iter GT 250 then begin 
      ; if 250 iterations is not enough, give it a kick start with some
      ; randomness.  The vertices then do a random walk
      fudge = randomn(seed,ndimensions)
   endif else begin
      fudge = 1.0
   endelse
   ;old = simplex[*,i]
   ;oldvolume = simplex_volume(simplex)
   simplex[*,i] = simplex[*,i] + $
      fudge*scale*(sign(replicate(1,ndimensions),simplex[*,i] - scenter))
   ;if simplex_volume(simplex) LT oldvolume then begin
   ;   simplex[*,i]=old
   ;   print,'Rejected: ',iter,oldvolume,simplex_volume(simplex)
   ;endif
   i = (i + 1L) MOD (ndimensions+1L)
   iter = iter + 1
   if keyword_set(verbose) then print,iter,simplex_volume(simplex,scale)
   if keyword_set(verbose) then print,simplex_inside(simplex,data)
   if iter GT 500 then $
      message,'Could not get a good initial guess, try running again.'
endwhile

; Now contract the simplex slowly to minimize the volume while keeping all
; the data inside the simplex

fcontract = 0.1  ; contraction factor
if keyword_set(verbose) then $
   print,strcompress('Initial volume is '+ $
                      string(simplex_volume(simplex,scale)))
iinside = total(1.0-simplex_inside(simplex,data))
value = simplex_volume(simplex,scale)  ; of order 1.0 with scale included
REPEAT begin
   ; Contract the simplex to get the minimum volume while still encompassing
   ; all the data points
   ncontractions = 0L
      for i=0,ndimensions do begin
      simplexsav = simplex[*,i]
      fudge = 1.0+randomn(seed,ndimensions)
      ; This contraction could be made more sophisticated by allowing the
      ; vertices to move in more general ways, but this works pretty well.
      simplex[*,i] = center + fudge*fcontract*(simplex[*,i] - center)
      tvalue = simplex_volume(simplex,scale)
      ; check that all data are still inside 
      inside = total(1.0-simplex_inside(simplex,data)) 
      if tvalue GE value or inside GT iinside then begin
         simplex[*,i] = simplexsav  ; no improvement
      endif else begin
         value = tvalue  ; keep this one
         ncontractions = ncontractions + 1L
      endelse
   endfor
   if keyword_set(verbose) then begin
      print,strcompress('Accepted '+string(ncontractions)+ $
                        ' contractions at '+string(fcontract)+ $
                        '.  Volume is '+ $
                        string(simplex_volume(simplex,scale)))
   endif
   fcontract = fcontract^0.98
endrep UNTIL (1.-fcontract) LT 0.0001

; Refine the contracted simplex with powell or amoeba.  The amoeba
; seems to work better in this case.
 
if 1 then begin

   best_simplex = reform(simplex,n_elements(simplex))
   best_volume = simplex_volume(simplex,scale)

   if 0 then begin
      ; Powell minimization
      s = reform(simplex,n_elements(simplex))
      xi = fltarr(n_elements(simplex),n_elements(simplex))
      for i=0L,n_elements(simplex)-1L do xi[i,i]=1.0
      powell,s,xi,1.e-5,fmin,'simplex_bound_amoeba'
      simplex = reform(s,ndimensions,ndimensions+1L)
   endif else begin
      ; Amoeba minimization
      r = amoeba(1.e-5,scale=1.,p0=reform(simplex,n_elements(simplex)), $
                 function_name='simplex_bound_amoeba',nmax=10000L)
      if n_elements(r) EQ 1 then begin
         message,/info,'Amoeba failed to converge' 
         simplex = reform(best_simplex,ndimensions,ndimensions+1L)
      endif else simplex = reform(r,ndimensions,ndimensions+1L)
   endelse

endif

volume = simplex_volume(simplex,scale)
return,simplex

end

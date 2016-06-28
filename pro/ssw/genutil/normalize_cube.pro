function normalize_cube, incube, x, y, nx, ny, center=center, corner=corner, $
	normfact=normfact, tcube=tcube, overwrite=overwrite, factors=factors
;+
;   Name: normalize_cube
;
;   Purpose: empirically normalize cube of data from relative signal levels
;
;   Input Parameters:
;      incube - 3D data (cube)
;      x,y,nx,ny - (optional) - sub-cube to use for normalization (def=center)
;
;   Output
;      function returns pseudo-normalized cube OR  factors if /factors is set
;
;   Keyword Parameters:
;      center - switch, if set, take cube core from image center 
;      corner - switch, if set, take cube core from corner
;      factors - switch, if set, return normalization vector instead of norm data
;      overwrite - switch, if set, conserve memory by OVERWRITING INPUT
;      normfact (output) - normalization vector
;      tcube (output)   - sub cube used in normaaliztion (nx,ny,nimages)
;  
;
;   Calling Sequnce:
;      nc=normalize_cube(incube [x,y,nx,ny, /center, /corner, normfact=normfact])
;
;   History:
;      18-mar-1996 (S.L.Freeland) originally for EIT (unknown exposure times)
;       7-jun-1997 (S.L.Freeland) fix bug with /OVERWRITE  option
;
;   Restrictions:
;      Presumes that that sub-cube is not where the action is
;-

if data_chk(incube,/ndim) ne 3 then begin
   message,/info,"Sorry, only works on a cube..."
   return,incube
endif

sdata=size(incube)
nimg=sdata(3)

if not keyword_set(nx) then nx=fix(.1*(sdata(1))) > 3 < sdata(1)
if not keyword_set(ny) then ny=fix(.1*(sdata(2))) > 3 < sdata(2)

case 1 of
   keyword_set(corner): begin
      x=0
      y=0
   endcase
   keyword_set(center): begin
      x=sdata(1)/2
      y=sdata(2)/2
   endcase
   else: begin
      x=sdata(1)/2
      y=sdata(2)/2
   endcase
endcase

tcube=incube(x:x+nx<(sdata(1)-1),y:y+ny<(sdata(2)-1),*) ; extract sub-cube
tcubes=total(total(tcube,1),1)         			; total per subimage
ttcubes=total(tcubes)                   		; total sub-cubes
normfact=(ttcubes/nimg)/tcubes				; normalization factor

if keyword_set(factors) then odata=normfact else begin
   if keyword_set(overwrite) then odata=temporary(incube) else odata=incube
   odata=float(temporary(odata))
   for i=0,nimg-1 do odata(0,0,i)=odata(*,*,i)*normfact(i)
endelse

return,odata
end


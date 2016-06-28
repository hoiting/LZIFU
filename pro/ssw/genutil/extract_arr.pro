function extract_arr, data,xc, nx, yc, ny, $
    xcen=xcen,ycen=ycen,xsiz=xsiz,ysiz=ysiz, temporary=temporary

; +
; PURPOSE:
;       Extracts sub-array from array usings center, array bounds protect
;
; CALLING SEQUENCE:
;       subdata = extract_arr(data,xc, yx, nx, ny [,/temporary] )
;  -or- subdata = extract_arr(xcen=xcen,ycen=ycen,xsiz=xsiz,ysiz=ysiz [,/temp])
;
; INPUTS:
;	data - array from which sub-array is to be extracted
;       xc   - x coord center pixel
;       yc   - y coord center pixel
;       nx   - size in x direction
;       ny   - size in y direction
;
; Keyword Parameters:
;
;	xcen - synonym for xc
;	ycen - synonym for yc
;	xsiz - synonym for nx
;	ysiz - synonym for ny
;
; HISTORY:
;	5-sep-96 Written by G.L. Slater
;      24-Oct-98 S.L.Freeland - Allow posititional parameters, add /overwrite,$
;                               assume ycen=xcen, yxiz=xsiz if not specified
; -
if not data_chk(data,/nimages) ge 1 then begin
  box_message,['Need an input image...', $
               'IDL> subarr=extract_arr(image , xc, nx [,yc, ny] [,/temporar]'] 
  return,-1
endif

if n_elements(xcen) gt 0 then xc=xcen
if n_elements(xsiz) gt 0 then nx=xsiz
if n_elements(ycen) gt 0 then yc=ycen
if n_elements(ysiz) gt 0 then ny=ysiz

; -------- allow Y=>X
if n_elements(xc) gt 0 and n_elements(yc) eq 0 then yc=xc
if n_elements(nx) gt 0 and n_elements(ny) eq 0 then ny=nx


if n_elements(xc) eq 0 or n_elements(nx) eq 0 then begin 
   box_message,['Need at least xcenter and NX', $
                'IDL> subarr=extract_arr(image , xc, nx [,yc, ny] [,/temporar]'] 
   return ,-1
endif

xsh = fix(nx)/2 & ysh = fix(ny)/2
dnx=data_chk(data,/nx)
dny=data_chk(data,/ny)

subdata = make_array(nx,ny,type=data_chk(data,/type))
subdata((-(xc-xsh+1))>0,(-(yc-ysh+1))>0) = $
  data(((xc-xsh+1)>0):((xc+xsh)<(dnx-1)), $
       ((yc-ysh+1)>0):((yc+ysh)<(dny-1)))

if keyword_set(temporary) then delvarx,data            ; eliminate big array
if keyword_set(qstop) then stop

return, subdata

end


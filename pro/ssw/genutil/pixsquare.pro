function pixsquare,nx, ny, $
                   position=inposition,xyscale=xyscale,xstep=xstep,edge=edge

;+
;NAME:
;     PIXSQUARE
;PURPOSE:
;     Computes a !P.POSITION type vector which makes pixels square when 
;     plotting an image.
;CATEGORY:
;CALLING SEQUENCE:
;     !P.POSITION = pixsquare(nx,ny)
;INPUTS:
;     nx = x dimension of the image
;     ny = y dimension of the image
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;     position = a 4 element position vector specifying the plot area.
;                (def = [0,0,1,1,0,1], i.e. the entire window).  Must be
;                in normal coordinates.
;     xyscale = a magnification factor for the image
;     xstep = the size of an x pixel (def = 1.0) relative to a y pixel
;     edge = a structure with tags top, bottom, left, right which give
;            the minimum size of the borders in centimeters.  If the plot
;            is too large (large xyscale), the edge may be reduced in order
;            to ensure square pixels.
;OUTPUTS:
;     The position vector which will make square pixels in the plot (normal
;     coordinates).
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     Assumes that !D.X_PX_CM and !D.Y_PX_CM are correct.  If their ratio is 
;     correct but the values are wrong, the pixels will still be square, but 
;     the edge keyword will be affected.  If even the ratio is wrong, the 
;     pixels will not be square.
;
;     The pixels are not quite square with landscape postscript.  I don't
;     know why.
;PROCEDURE:
;     Only the aspect ratio nx/ny is actually used, so a "zoom" factor is not
;     relevant here.  The xyscale keyword is applied to the size of the 
;     plotting region specified by position, i.e. to the size of the plotting
;     region in normal coordinates.  
;MODIFICATION HISTORY:
;     Written by T. Metcalf 05-Oct-93
;
;        TRM 13-Oct-93 Added checks to ensure that the output position is
;                      not out-of-range.  With a large xyscale, it still 
;                      can be out-of-range, but a warning is printed.
;-


   ; Check/Set the input parameters

   nposition = n_elements(inposition)
   if (nposition LE 0) then $
      position = [0.,0.,1.,1.] $
   else if nposition GE 4 then $
      position = float(inposition(0:3)) $
   else message,'Bad dimension in position'

   if n_elements(xyscale) LE 0 then xyscale=1.0 else xyscale=float(xyscale)

   if n_elements(xstep) LE 0 then xstep=1.0 else xstep=float(xstep)

   edge_is_set = 0
   sedge = size(edge) & nsedge = n_elements(sedge)
   if sedge(nsedge-2) EQ 0 then $
      edge={left:0.0,right:0.0,top:0.0,bottom:0.0} $
   else begin
      if sedge(nsedge-2) NE 8 then message,'Edge must be a structure'
      if tag_index(edge,'TOP') LT 0 then edge=add2str(edge,'TOP',0.0)
      if tag_index(edge,'BOTTOM') LT 0 then edge=add2str(edge,'BOTTOM',0.0)
      if tag_index(edge,'LEFT') LT 0 then edge=add2str(edge,'LEFT',0.0)
      if tag_index(edge,'RIGHT') LT 0 then edge=add2str(edge,'RIGHT',0.0)
      edge_is_set = -1
   endelse

   ; Start computing the position vector

   deltax = (POSITION(2)-POSITION(0))*xyscale  ; size of plot region
   deltay = (POSITION(3)-POSITION(1))*xyscale  ; in normal coords

   ; Conversion to real units (cm)

   x_normal_to_cm = float(!D.X_SIZE)/!D.X_PX_CM
   y_normal_to_cm = xstep*float(!D.Y_SIZE)/!D.Y_PX_CM

   x_display_size = (deltax * x_normal_to_cm - edge.left - edge.right) > 0.0
   y_display_size = (deltay * y_normal_to_cm - edge.top - edge.bottom) > 0.0

   ; Does the x or y dimension control the size of the plot?  Set pix_size
   ; to the size of each pixel in cm.

   x_pix_size = x_display_size/float(nx)  ; Maximum size of x pixels in cm
   y_pix_size = y_display_size/float(ny)  ; Maximum size of y pixels in cm

   if x_pix_size LT y_pix_size then pix_size = x_pix_size $
   else pix_size = y_pix_size

   x_plot_size = nx*pix_size  ; plot size in cm
   y_plot_size = ny*pix_size

   ; center the plot with offsets (in cm):

   xoffset = edge.left + (x_display_size/xyscale-x_plot_size)/2.0
   yoffset = edge.bottom + (y_display_size/xyscale-y_plot_size)/2.0

   ; Don't allow the centering shift to overlap the edge, if requested

   if edge_is_set then begin
      xoffset = xoffset > edge.left
      yoffset = yoffset > edge.bottom
   endif

   ; Put back into normal coordinates
 
   oposition = [position(0)+(xoffset)/x_normal_to_cm, $
                position(1)+(yoffset)/y_normal_to_cm, $
                position(0)+(x_plot_size+xoffset)/x_normal_to_cm, $
                position(1)+(y_plot_size+yoffset)/y_normal_to_cm]

   ; Check that position does not go out of range.  If it is too large,
   ; shift over a bit to adjust.  Print warning, if the plot can't be 
   ; squeezed into the available space.

   if oposition(2) GT 1.0 then $
      oposition([0,2]) = oposition([0,2]) - ((oposition(2)-1.0)<oposition(0))
   if oposition(3) GT 1.0 then $
      oposition([1,3]) = oposition([1,3]) - ((oposition(3)-1.0)<oposition(1))

   if oposition(0) LT 0.0 then $
      oposition([0,2]) = oposition([0,2]) - ((oposition(0))<(oposition(2)-1.))
   if oposition(1) LT 0.0 then $
      oposition([1,3]) = oposition([1,3]) - ((oposition(1))<(oposition(3)-1.))

   if (max(oposition) GT 1.0000001) OR (min(oposition) LT 0.0) $
      OR (oposition(2) LE oposition(0)) $
      OR (oposition(3) LE oposition(1)) then $
      message,/info,strcompress('WARNING: Position = ' + $
                    string(oposition(0))+string(oposition(1)) + $
                    string(oposition(2))+string(oposition(3)))
   
   return,oposition

end
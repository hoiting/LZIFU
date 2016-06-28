function box_data, data
;
;+
;   Name: box_data
;
;   Purpose: return data within user defined box 
;
;-
box_cursor, x,y,nx,ny 
if n_elements(data) eq 0 then retval=tvrd(x,y,nx,ny) else $
   retval=data(x:x+nx-1,y:y+ny-1)
return,retval
end

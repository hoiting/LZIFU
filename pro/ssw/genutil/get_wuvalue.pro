function get_wuvalue, ids
;   
;+
;   Name: get_wuvalue 
;
;   Purpose: return widget uvalue 
;
;   Input Parameter:
;      ids - scaler or vector of widget ids
;            (if vector, all uvalues must be ident str)
;
widget_control, ids(0), get_uvalue=retval
sizeval=size(retval)

for i=1,n_elements(ids)-1 do begin
   widget_control, ids(i), get_uvalue=newval
   sizenewval = size(newval)
   if n_elements(sizeval) ne n_elements(sizenewval) then $
      message,'Widget uvalues have incompatible attributes'
   retval=[retval, newval]
endfor
return,retval
end 


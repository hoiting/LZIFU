function makvec,x

xsize = size(x)
if xsize(0) eq 0 then begin
  x=[[x],[x]] & x=x(*,0) & x=reform(x,1)
endif else begin
  x=reform(x,n_elements(x))
endelse

return,x
end

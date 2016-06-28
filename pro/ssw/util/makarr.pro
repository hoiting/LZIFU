function makarr,x

xsize = size(x)
if xsize(0) eq 1 then x=reform(x,xsize(1),1)

return,x
end

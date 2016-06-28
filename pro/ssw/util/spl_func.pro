function spl_func,d,h
;+
;
;   Computes value of the spline function at offset 'd' and centre 'h'
;   Used by BELLS.pro 
;
;   Use:
;         IDL>  y = spl_func(d,h)
;
;
;   CDP Jan '92
;-

p = h - d
q = 2.0*h - d

if p ge 0.0 then begin
   return, q*q*q - 4.0*p*p*p
endif else begin
   if q gt 0 then begin
      return,q*q*q
   endif else begin
      return,0.0
   endelse
endelse

end


function alphagen, nletters ,  duplicate=duplicate, lower=lower
;
;+
;   Name: alphagen
;
;   Purpose: return array ['A', 'B', 'C'...] (sindgen with alpha)
;
;   Calling Sequence: 
;      alpha=alphagen(10 [,/lower])
;
;-
new=bytarr(1,nletters)
modv=26 + keyword_set(lower)*26		
new(0,0)=rotate( (bindgen(nletters) mod modv) + 65b,1)
return,reform(string(new))
end

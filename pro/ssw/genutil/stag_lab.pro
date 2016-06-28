function stag_lab, labels, min=min, max=max, sep=sep
;+
;   Name: stag_lab
;
;   Purpose: get staggered label coordinates for auto-label positioning
;
;   Calling Sequence:
;      norm_pos=stag_lab(labels [,min=min, max=max, sep=sep])
;
;   History:
;      10-apr-1995 (SLF) - for evt_grid use
;- 
;
if not keyword_set(min) then min=.25
if not keyword_set(max) then max=.90
if not keyword_set(sep) then sep=.1

min = min > .1
max = max < .9999

numsteps=round((max-min)/sep)
cycle=[(lindgen(numsteps)*sep) + min, (lindgen(numsteps)*sep) + min + sep/2.]

narr=n_elements(labels)
ncycle=n_elements(cycle)
multicycle=rebin(cycle,ncycle,narr/ncycle+1)

outpos=reform(multicycle,n_elements(multicycle))

outpos=outpos(0:narr-1)

return,outpos
end

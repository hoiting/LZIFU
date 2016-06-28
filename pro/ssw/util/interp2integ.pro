;+
; PROJECT:
;       SDAC
;
; NAME: 
;	INTERP2INTEG
;
; PURPOSE:
;	This function integrates over the limits on an interpolated array.
;
; CATEGORY:
;	GEN, MATH, UTILITY, NUMERICAL
;
; CALLING SEQUENCE:
;	Integral = INTERP2INTEG( Xlims, Xdata, Ydata)
;
; CALLS:
;	INTERPOL, INT_TABULATED, EDGE_PRODUCTS, FIND_IX
;
; INPUTS:help,uselog
;       Xlims - The limits to integrate over. May be an array of 2 x n sets of limits where
;	the intervals are contiguous and ordered, i.e. xlims(1,i) equals xlims(0,i+1)
;	Xlims may also be an ordered set of values in a 1-d vector defining contiguous intervals.
;	Xdata, Ydata - Define the tabulated function to integrate over. Xdata may be a 2xN array
;	and will take the arithmetic average to obtain a 1-d array.
;
; OPTIONAL INPUTS:
;	
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORD INPUTS:
;
;	LOG    - If set, use log/log interpolation.
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	Complex data types not permitted and not checked.
;	Xlims in 2xN form are assumed contiguous and not checked.
;
; PROCEDURE:
;	The data are interpolated into the interval defined by Xlims and then integrated.
;
; MODIFICATION HISTORY:
;	RAS, 2-apr-1996
;	Version 2, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;	Version 3, richard.schwartz@gsfc.nasa.gov, 16-apr-1998, converted to multiple intervals.
;-
function INTERP2INTEG, Xlims, Xdata, Ydata, log=log

on_error,2			;Return to caller
xlims_use = xlims
edge_products,xlims_use, edges_1=xlims_use
uselog = keyword_set(log)

xs  = xdata 
;
; xdata may be 2-d, if so average to 1-d
if total( abs((size(xs))(0:1)-[2,2])) eq 0 then xs = avg(xs,0)
ord = sort(xs)
xs  = xs(ord)
ys  = ydata(ord)
wzero = where( xs le 0.0, xzero)
wzero = where( ys le 0.0, yzero)
wzero = where( xlims_use le 0.0, lzero)
if (xzero + yzero + lzero) ge 1 then uselog = 0 
case 1 of
	uselog : ylims = exp( interpol(alog(ys), alog(xs), alog(xlims_use(*))))
	else: ylims = interpol( ys, xs, xlims_use(*) ) 
	endcase


xns = [xs, xlims_use(*)]
yns = [ys, ylims(*)]
ord = uniq(xns,sort(xns))
xns = xns(ord)
yns = yns(ord)



edge_products, find_ix(xns, xlims_use), edges_2=ilims

nbins = n_elements(ilims)/2

out   = fltarr(nbins)

for i=0,nbins-1 do out(i) = int_tabulated( xns(ilims(0,i):ilims(1,i)), yns(ilims(0,i):ilims(1,i)))

return, out


end


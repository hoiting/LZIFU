function avoid_spikes, yarr, nss, thresh=thresh
;+
;NAME:
;	avoid_spikes
;PURPOSE:
;	Return the subscript list of data values which don't have spikes
;SAMPLE CALLING SEQUENCE:
;	ss = avoid_spikes(yarr, nss)
;INPUT:
;	yarr	- the input array
;OUTPUT:
;	ss	- the list of subscripts which are ok
;	nss	- the number of points which are ok
;HISTORY:
;	Written 29-May-96 by M.Morrison
;	10-Jun-96 (MDM) - Put in protection for problem data (median=0)
;	10-Jun-96 (MDM) - Added thresh keyword
;	28-Jun-96 (MDM) - Modified logic since it did not protect against
;			  positive spikes (it only protected against
;			  negative spikes).  It removes twice as many
;			  points now.
;-
;
dt = deriv_arr(yarr)		;get first differences
dt = abs(dt)
m = median(dt)			;kinda 1 sigma?
if (m eq 0) then m = total(dt)/n_elements(dt)
if (n_elements(thresh) eq 0) then thresh = 5
;
;;ss = where(dt lt thresh*m, nss)
qok = bytarr(n_elements(yarr)) + 1
ss1 = where(dt gt thresh*m, nss1)
if (nss1 gt 0) then begin
    qok(ss1) = 0
    qok(ss1+1) = 0
end
ss = where(qok, nss)
;
return,ss
end

function anytim2doy, tim_in, year=year, qstop=qstop, string=string
;
;+
;NAME:
;	anytim2doy
;PURPOSE:
;	Given a time in the form of a (1) structure, (2) 7-element time
;	representation, or (3) a string representation, 
;	return the day of the year for that day
;CALLING SEQUENCE:
;	xx = anytim2doy(roadmap)
;	xx = anytim2doy('12:33 5-Nov-91')
;INPUT:
;	tim_in	- The input time
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;OPTIONAL KEYWORD INPUT:
;	string	- If set, return the output in the form YYDDD (ie: 98020)
;OPTIONAL KEYWORD OUTPUT:
;	year	- The year for the time(s) passed in
;HISTORY:
;	Written 7-Jun-92 by M.Morrison
;	11-Jan-94 (MDM) - Updated the header information
;	18-Feb-98 (MDM) - Added /STRING option
;	 5-Mar-98 (MDM) - Changed from STRING to FSTRING
;			- Changed logic to do '1-Jan-YY' conversion
;			  once per year rather than the full array
;			  (speeds it up considerably for 
;-
;
daytim = anytim2ints(tim_in)
timarr = anytim2ex(tim_in)
year = timarr(6,*)
;

;;daytim_jan1 = anytim2ints('1-jan-' + strtrim( year, 2) )
;;doy = daytim.day - daytim_jan1.day + 1
;
n = n_elements(year)
doy = intarr(n)
if (n eq 1) then uyear = year $
                else uyear = year(uniq(year, sort(year)))
for iyear=0,n_elements(uyear)-1 do begin
    ss = where(year eq uyear(iyear), nss)
    if (nss eq 1) then ss = ss(0)       ;to avoid IDL bug giving the message
                                        ;"Expression must be a scalar in this context: <INT       Array[1]>."
    day1 = anytim('1-Jan-'+strtrim(uyear(iyear),2),/int)
    doy(ss) = daytim(ss).day - day1.day + 1
end


if (keyword_set(string)) then doy = fstring(year, format='(i2.2)') + fstring(doy, format='(i3.3)')
return, doy
end

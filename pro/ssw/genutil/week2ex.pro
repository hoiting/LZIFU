function week2ex, year, week
;
;+
;NAME:
;	week2ex
;PURPOSE:
;	Given a year and a week #, return the date of the first
;	day in that week.
;CALLING SEQUENCE:
;	result = week2ex(year,week)
;INPUT:
;	year	scalar or vector
;	week	scalar or vector
;OUTPUT:
;	tarr	- time in notation [hh,mm,ss,msec,dd,mm,yy]
;HISTORY:
;	Written 1-Mar-92 by M.Morrison
;	Modified 14-may-92, J. Lemen, Extended to allow vector input
;	 7-Jun-92 (MDM) - Removed call to make_str - added call to anytim2ints
;-

num = n_elements(year)
tarr_return = intarr(7,num)
;
for i=0,num-1 do begin
  daytim = anytim2ints('1-Jan-' + strtrim(fix(year(i)),2))	;start at beginning of year - look for date where "week" starts
  daytim.day = daytim.day-1 	;back up one			;because repeat loop starts by adding 1
  daytim.day = daytim.day + ((week(i)-2)*7)>0		;get it close at least
							;(week(i)-2) because of short first week
;
  repeat begin
      daytim.day = daytim.day + 1
      week0 = ex2week(anytim2ex(daytim))
  end until (week0 eq week(i))
;
  tarr_return(0,i) = anytim2ex(daytim)
endfor
;
return, tarr_return
end

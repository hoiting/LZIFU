function doytim2ints, buf, year
;+
;NAME:
;	doytim2ints
;PURPOSE:
;	Convert day-of-year and time to the internal time format
;SAMPLE CALLING SEQUENCE:
;	daytim = doytim2ints(buf, year)
;	daytim = doytim2ints('207, 21:45')
;RESTRICTION:
;	If an array of DOY/Times are passed in, the formats must all
;	be identical.  It uses the first item in the array to determine
;	the method of decoding
;INPUTS:
;       buf     = A string array with doy of year and time.
;                 Example, "316, 21:45"
;                          "316  21:45"
;                          "316"
;                          "342  2145"
;                 Note: The day of year is required.  It must be first and
;                       can be deliminated by space, comma or tab.
;OPTIONAL INPUT:
;	year	= Year in 199x or 9x format.  If this is not specified,
;                 the current year will be used.
;OUTPUT:
;	daytim	= A structure with .TIME and .DAY tags
;HISTORY:
;	Written 26-Feb-98 by M.Morrison 
;		(taking J.Lemen's doytim2ex as the starting point and 
;		 allowing a vector of inputs to be passed in and to use 
;		 ANYTIM to speed things up considerably).  It's about
;		 10 times faster than doy2utc and can handle input times
;-

buff = strtrim( buf, 2 )                        ; Trim lead/trailing blanks
if strlen(buff(0)) eq 0 then return,anytim2ints('')      ; Return zeros if blank

; Search for the deliminter - space, tab, or ','
if strpos(buff(0),',') ne -1 then strput,buff,' ',strpos(buff,',')
if strpos(buff(0),9b)  ne -1 then strput,buff,' ',strpos(buff,9b)

j = strpos(buff(0),' ') 

if j eq -1 then begin                           ; Only doy supplied
   doy = fix(buff)
   buff = ' '
endif else begin                                ; doy and time supplied
   doy = fix(strmid(buff,0,j))
   buff = strmid(buff,j,999)
   j = strpos(buff(0),':')                 ; Check if 12:00 entered as 1200
   if j eq -1 then begin
     kk = fix(buff) & HH = fix(kk/100) & MM = kk - HH*100
     buff = string(HH,':',MM,format='(i2.2,a,i2.2)')
   endif
endelse

if n_elements(year) eq 0 then yyear = strmid(!stime,9,2) else yyear = year
if yyear(0) gt 1000 then yyear = yyear - 1900

n = n_elements(doy)
if n_elements(yyear) ne n_elements(doy) then begin
    if n_elements(year) gt 1 then begin
      message, 'Array sizes for doy and year parameters do not match.', /info
      message, 'Using the first year in the array only', /info
      yyear = yyear(0)
    end
    yyear = intarr(n) + yyear
endif

if (n eq 1) then uyear = yyear $
		else uyear = yyear(uniq(yyear, sort(yyear)))

out = anytim2ints(buff)
if (n_elements(out) ne n) then out = replicate(out, n)	;no time inputs
;
for iyear=0,n_elements(uyear)-1 do begin
    ss = where(yyear eq uyear(iyear), nss)
    if (nss eq 1) then ss = ss(0)	;to avoid IDL bug giving the message
					;"Expression must be a scalar in this context: <INT       Array[1]>."
    day1 = anytim('1-Jan-'+strtrim(uyear(iyear),2),/int)
    out(ss).day = day1.day + doy(ss)-1
end

return, out
end

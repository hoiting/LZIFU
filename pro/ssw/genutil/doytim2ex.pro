function doytim2ex, buf, doy=doy, year=year
;+								(12-nov-91)
;  Name:
;    doytim2ex
;
;  Purpose:
;    Convert a string with day-of-year and time into external format.
;    For example,  the string "316 21:45" will be converted to
;    [21,45,0,0,12,11,year]
;
;  Calling Sequence:
;    timarr = doytim2ex(buf, [doy=doy, year=year] )
;
;  Inputs:
;    buf	= A string array with doy of year and time.
;		  Example, "316, 21:45"
;			   "316  21:45"
;			   "316"
;			   "342  2145"
;                 Note: The day of year is required.  It must be first and
;		        can be deliminated by space, comma or tab.
;  Outputs:
;    Returns 7-element array in external format.
;
;  Optional input keywords:
;    year	= Year in 199x or 9x format.  If this is not specified,
; 		  the current year will be used.
;
;  Optional return keywords:
;    doy	= The day of year number.
;
;  Method:
;    Calls doy2date and timstr2ex
;
;  History:
;    Written, 12-Nov-91, J. Lemen
;    Updated, 11-Dec-91, J. Lemen; Allow time to be entered as 1200 for 12:00"
;-

buff = strtrim( buf, 2 )			; Trim lead/trailing blanks
if strlen(buff) eq 0 then return,intarr(7)	; Return zeros if blank

; Search for the deliminter - space, tab, or ','
if strpos(buff,',') ne -1 then strput,buff,' ',strpos(buff,',')
if strpos(buff,9b)  ne -1 then strput,buff,' ',strpos(buff,9b)

j = strpos(buff,' ') 

if j eq -1 then begin				; Only doy supplied
   doy = fix(buff)
   buff = ' '
endif else begin				; doy and time supplied
   doy = fix(strmid(buff,0,j))
   buff = strmid(buff,j,strlen(buff))
   j = strpos(buff,':')			; Check if 12:00 entered as 1200
   if j eq -1 then begin
     kk = fix(buff) & HH = fix(kk/100) & MM = kk - HH*100
     buff = string(HH,':',MM,format='(i2.2,a,i2.2)')
   endif
endelse

if n_elements(year) eq 0 then yyear = strmid(!stime,9,2) else yyear = year
if yyear gt 1000 then yyear = yyear - 1900

doy2date, doy, yyear, month, day, yymmdd
timarr = timstr2ex(buff)
timarr([4,5,6]) = [day, month, yyear]

return, timarr
end

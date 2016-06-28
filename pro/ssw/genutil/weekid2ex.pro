function weekid2ex, week_id, t1, t2, ndays, year=year, week_id_fmt=week_id_fmt
;+
; NAME:
;   weekid2ex
; PURPOSE:
;   Convert Week number to external time
; CALLING SEQUENCE:
;   Time_ex = weekid2ex('94_04a')	; Time range of week 4 of 1994
;   Time_ex = weekid2ex(4)		; Week 4 of current year
;   Time_ex = weekid2ex(4,year=93)	; Week 4 of 1993
;   Time_ex = weekid2ex('94_04a', t1, t2 ) ; t1/t2 = first/last day of week
;   Time_ex = weekid2ex('94_04a', t1, t2, ndays )
; INPUT:
;   week_id	= Yohkoh Week ID (string) - may be a vector
;		= or week number (integer)
; OPTIONAL OUTPUTS:
;   t1, t2	= First/Last day of specified week(s) (string-type)
;   ndays	= Number of days in the week
; OPTIONAL KEYWORD INPUTS:
;   year	= Year number in case week_id is an integer
; OPTIONAL KEYWORD OUTPUTS:
;   week_id_fmt	= String version of week ID
; PROCEDURE:
;   Calls anytime2ex, ex2week, week2ex
;   Short weeks (first and last week of the year) are flagged with a "*".
; MODIFICATION HISTORY:
;   22-jan-94, J. R. Lemen, Written
;-

; -------------------------------------------------------------------
;  If week_id no requested week ID, use week ID of current time (!stime)
; -------------------------------------------------------------------
if n_elements(week_id) eq 0 then begin
   time = anytim2ex(!stime)
   week_id_fmt = anytim2weekid(time, t1, t2, ndays, /str)
   return, time
endif 

; -------------------------------------------------------------------
;  If week passed in as a number, convert to string format
; -------------------------------------------------------------------

www = week_id
sz = size(www) & typ = sz(sz(0)+1)
if typ le 4 then begin			; Passed in Week as a number
; If year is undefined, use the current year   
    if n_elements(year) eq 0 						then $
		yr = replicate((anytim2ex(!stime))(6),n_elements(www))	else $	
		if n_elements(year) ne n_elements(www)	 		then $
		yr = replicate(year(0),n_elements(www)) 		else $
		yr = year
   for i=0,n_elements(www)-1 do 			$
      if (www(i) lt 1) or (www(i) gt 53) then begin
	  message,'Bad week number = '+strtrim(www(i),2),/cont
          www(i) = 1 & yr(i) = 0
      endif
   time = anytim2ints(week2ex(yr,www))	; Get start of week days
   week_id_fmt = anytim2weekid(time, t1, t2, ndays, /str)
   return, anytim2ex(time)
endif else if typ ne 7 then begin
   message,'Input weekID must be string-type',/cont
   return,'?????'
endif

npts = n_elements(week_id)
years = intarr(npts)
weeks = intarr(npts)
weekid_fmt = strarr(npts)

; -------------------------------------------------------------------
;  Go through each string input and extract year and week number.
; -------------------------------------------------------------------
for i=0,npts-1 do begin
   ij = strpos(www(i),'_')	; Expect format to be like 94_04 or 94_04a
   if ij eq -1 then begin 
       message,'Bad weekID ??? = '+www(i),/info		; Didn't find an underscore: "_"
       weeks(i) = 1 & years(i) = 0 & weekID_fmt(i) = '??????'
   endif else begin
       years(i) = fix(strmid(www(i),0,ij))		; Extract the year
       weekid_fmt(i) = string(years(i),'_',format='(i2.2,a)')
       txt  = strmid(www(i),ij+1,strlen(www(i)))	; Is there a trailing letter (e.g., a)?
       Last_char = strmid(txt,strlen(txt)-1,1)
       ij = strpos('0123456789',Last_char)		; See if the last character is a number
       if ij eq -1 then begin				; Last char was a letter
	   weeks(i) = fix(strmid(txt,0,strlen(txt)-1)) 
	   weekid_fmt(i) = weekid_fmt(i) + string(weeks(i),format='(i2.2)') + strlowcase(Last_char)
       endif else begin 				; Last char was a number
	   weeks(i) = fix(txt)
           weekid_fmt(i) = weekid_fmt(i) + string(weeks(i),'a',format='(i2.2,a)')
       endelse
       if (weeks(i) gt 53) or (weeks(i) lt 1) then begin; Check for invalid week number
          message,'Bad weekID ??? = '+www(i),/info	; Week must be in the range 1 to 53
	  weeks(i) = 1 & years(i) = 0
	  weekid_fmt(i) = '??????'
       endif
   endelse
endfor
   
; -------------------------------------------------------------------
;   Work out the first and last day of the week
; -------------------------------------------------------------------

flag = replicate('*',8) & flag(7) = ' '
time = anytim2ints(week2ex(years,weeks))	; Get start of week days
week_ID_fmt = anytim2weekid( time, t1, t2, ndays, /str)	; Get first/last day and week ID

return, anytim2ex(time)
end

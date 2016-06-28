function anytim2weekinfo, times, years, weeks, $
		 first=first, wid=wid, fid=fid, year2digit=year2digit

;+   Name: anytim2weekinfo
;  
;    Purpose: return week-requested information for input time vector
;
;    Input Parameters:
;        times - time vector in any SSW format
;
;    Output Parameters:
;       years - integer year for input times
;       weeks - integer week for input times
;  
;    Output:
;       Function output if /FIRST set, output is YYYYMMDD or YYMMDD (first DOW)
;       Function output if /WID   set, output is YYYY_WW or YY_WW   (weekid) 
;                                                                    DEFAULT
;    Keyword Parameters:
;      wid   - (switch) if set, return 'YYYY_WW' (weekid)  DEFAULT
;      first - (switch) if set, return 'YYYYMMDD' correponding to 1st DOW
;      year2digit (switch) if set, return year as 2 digit (YYMMDD or YY_WW)
;
;    History:
;      29-Jan-1998 - S.L.Freeland - package some common TRACE/YOHKOH/SSW
;                                   time->week conversions
;
;    Routines Called:
;       anytim, anytim2ints, ex2week  
;-
;   ---------- generate some useful conversions -----------
etimes=anytim(times,/ex)                                ; -> external
weeks=ex2week(etimes)                                   ; -> weeks (out)
eweek=week2ex(etimes(6,*),weeks)

; TODO speed up (doy - dow < 0) to handle rollover?
;dow=ex2dow(etimes) 
;firstdow=anytim2ints(etimes,offset= (-dow*86400.)*(dow gt doy)) ; -> fist DOW
; ----------------------------------------------------------------

; --------- function output determined by user keyword -----------
case 1 of
   keyword_set(first): retval=time2file(eweek,/date_only)
   else: retval=strmid(anytim(etimes,/ecs),0,4)+'_'+fstring(weeks,format='(i2.2)')
endcase
; ----------------------------------------------------------------

mlen=max(strlen(retval))
years=fix(strmid(retval,0,4))                                 ; years (out)
if keyword_set(year2digit) then begin                        ; trim->2digit
    retval=strmid(temporary(retval),2,mlen-2 )               ; on request
    years=years mod 100
endif

return, retval
end


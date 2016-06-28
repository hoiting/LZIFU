function reltime, reftime, _extra=_extra, range=range, day_only=day_only, $
	debug=debug, hours=hours, days=days, minutes=minutes, $
        out_style=out_style
;+
;   Name: reltime
;
;   Purpose: return relative UT time or time range (default is offset from NOW)
;
;   Input Parameters:
;      reftime - reference time - default REFTIME is NOW (current UT)
;
;   Calling Sequence:
;      relt=reltime( [reftime,] [hour=hour, day=day, /yesterday,/tomorrow] )  
;
;   Keyword Parameters:
;      hours - offset in hours (neg OK)
;      days  - offset in days  (neg OK)
;      minutes - offest in minutes (neg OK)
;      yesterday, tommorrow, daybefore, dayafter - obvious
;      day_only - dont return the time (just relative day)
;      out_style - output time style per anytim.pro OUT_STYLE keyword 
;                   { 'ccsds', 'yohkoh', 'ecs', 'utc_int', 'vms', 'int'...etc }
;
;   Calling Examples:
;     IDL> print,reltime('1-feb-94 12:30', hour = -12, out='ecs')
;        1994/02/01 00:30:00.000
;
;      now=reltime(/now)                ; current UT
;      sixhoursago=reltime(hour=-6)     ; 6 hours ago
;      tomorrow=reltime(day=1)          ; 24 hours from now
;      relref=reltime(REFTIME, days=-2, out='ccsds') ; REFTIME-24hr in CCSDS
;      yest=reltime(/yesterday)		; 24 hours ago ut 
;      tom=reltime(/tomorrow)		; 24 hours from now
;
;   Method: keyword inheritance, calls timegrid.pro
;
;   History:
;      Circa 1-Jun-1997 S.L.Freeland
;           19-May-1998 S.L.Freeland - pass HOUR or DAY-> timegrid
;                                      add /NOW keyword allow proper spelling
;                                      for /tomorrow 
;            7-Apr-1999 S.L.Freeland - fix problem when REFTIME passed
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;       8-Apr-2005, S.L.Freeland -added MINUTES keyword+function
;           
;-

if not keyword_set(out_style) then out_style='yohkoh'  ; dd-MON-yy hh:mm:ss

now=anytim(ut_time(),/yohko)		; current UT time

if n_elements(reftime) eq 0 then ref_time=now else ref_time=anytim(reftime,/yohkoh)

; NOTE - if DAYS or HOURS keywords, just use timegrid.pro and early return...
if keyword_set(days) or keyword_set(hours) or keyword_set(minutes) then $
   return,anytim((timegrid(ref_time,day=days,minutes=minutes , hour=hours,/string))(0),out_style=out_style, date=day_only)
;

if not data_chk(_extra,/struct) then begin
   message,/info,"No keywords supplied, returning current UT
   return,now
endif

predef=['dayb','yest','now','tomm','tomo','daya']	; uniq to this many char
doff  =[-2,-1,0,1,1,2]				; offsets

etag=(tag_names(_extra))(0)	; only allow one tag (take the first)

chkpre=(wc_where(predef,strmid(etag,0,4)+'*',/case_ignore,cnt))(0)

if cnt gt 0 then begin
   type="day
   delta=strtrim(doff(chkpre),2)
endif else begin
   case 1 of 
      strpos(etag,'LAST'): quant=ssw_strsplit(etag,'LAST',/tail) 
      strpos(etag,'NEXT'): quant=ssw_strsplit(etag,'NEXT',/tail) 
      else: begin
            box_message,["Unrecognized keyword: " + etag, "returning current time"]
            return, now
      endcase
   endcase
   delta=strtrim(str2number(quant),2)
   type=strmid(quant,strlen(delta),strlen(quant))
endelse

if keyword_set(debug) then stop

; add offset via call timegrid
exestr="end_time=timegrid('" + ref_time + "'," + type + "=(" + $
   strtrim(delta,2) + "),/string)"
exestat=execute(exestr)

retval=end_time

if keyword_set(range) then $
   retval=([[ref_time,end_time],[end_time,ref_time]])(*,delta lt 0)

retval=anytim(retval,out_style=out_style,date=day_only)

return,retval
end

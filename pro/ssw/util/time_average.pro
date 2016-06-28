;+
; Project     : SOHO - CDS     
;                   
; Name        : TIME_AVERAGE()
;               
; Purpose     : To form a time average of a set of time series data.
;               
; Explanation : Given a time series of data (ie a set of data values and 
;               associated time values) the function returns an array of data
;               values which are the averages within a user-defined time range.
;               The time range to use is specified via a key word.  A time
;               array is also returned and this gives the mean of the first
;               and last time of data used within the associated time bin.
;               
; Use         : out = time_average(time, data [,one-of-the-keywords, $
;                                                 top=top,bottom=bottom]
;    
; Inputs      : time  -  an structure array of time values in standard CDS 
;                        UTC format.
;               data  -  the associated data values
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns a structure array containing a day/time
;               structure and an averaged data value.  The make up of the 
;               output is 
;               out = {{mjd:0L,time:0L}, data:0.0d0}
;
;               On return it is therefore easy to plot the time averaged
;               values thus:
;
;               IDL> utplot,out.date,out.data
;
; Opt. Outputs: None
;               
; Keywords    : DAY    -  if specified, the time averaging period is taken as 
;                         00:00 on the day of the first datum to day*24 hours 
;                         later.
;
;               HOUR   -  if specified, the time averaging period is taken as 
;                         nn hours starting at the beginning of the hour of the
;                         first datum.
;
;               MINUTE - if specified, the time averaging period is taken as 
;                        nn minutes starting at the beginning of the minute of
;                        the first datum.
;
;               SECOND - if specified, the time averaging period is taken as 
;                        nn seconds.
;
;               TOP    - if present will be returned with an array giving the
;                        maximum datum found in each averaged time interval
;
;               BOTTOM - if present will be returned with an array giving the
;                        minimum datum found in each averaged time interval
;
;   
; Calls       : None
;
; Common      : None
;               
; Restrictions: Only one of the DAY/HOUR/MINUTE/SECOND keywords must be set.
;               
; Side effects: None
;               
; Category    : Util, numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 23-Jan-95
;               
; Modified    : 
;
; Version     : Version 1, 23-Jan-95
;-            

function time_average, time, data, day=day, hour=hour, minute=minute, $
                                   second=second, top=top, bottom=bottom

;
;  check presence of parameters
;
if n_params() eq 0 then begin
   print,'Use:  tav = time_average(time, data, day=day, hour=hour,'
   print,'                                     minute=minute,'
   print,'                                     second=second,'
   print,'                                     top=top, bottom=bottom)'
   return,0
endif

;
;  check time input is correct type
;
if datatype(time,1) ne 'Structure' then begin
   print,'Time parameter must be in CDS UTC structure form.'
   return,0
endif

;
;  and keywords
;
key_stat = keyword_set(day) + keyword_set(hour) + keyword_set(minute) +$
           keyword_set(second)
if key_stat eq 0 or key_stat gt 1 then begin
   print,'Only one of the integration setting keywords may be used.'
   return,0
endif

;
;  set up arrays for output (optional + required)
;
nel = n_elements(time)
bottom = fltarr(nel)
top = fltarr(nel)
out = replicate({date:{time_av,mjd:0L, time:0L}, data:0.0d0},nel)

;
;  figure out time interval requestedin msecs
;
if keyword_set(day) then begin
   interval = 24L * 3600L * day
   startt = {mjd:time(0).mjd, time:0L}
endif

if keyword_set(hour) then begin
   interval = 3600L *  hour
   startt = (time(0).time/3600L/1000L)*3600L*1000L
   startt = {mjd:time(0).mjd, time:startt}
endif

if keyword_set(minute) then begin
   interval = 60L * minute
   startt = anytim2utc(time(0),/ext)
   startt = {mjd:time(0).mjd, time:startt.minute*60L*1000L+$
                                   startt.hour*3600L*1000L}
endif

if keyword_set(second) then begin
   interval = second
   startt = {mjd:time(0).mjd, time:(time(0).time/1000L)*1000L}
endif

;
;  for convenience change to TAI
;
startt = utc2tai(startt)

;
;  have start time and interval so get running end time
;
endt = startt + interval

;
;  convert all times
;
ttimes = utc2tai(time)

;
;  loop around accumulating data
;
it = -1
while startt lt utc2tai(time(nel-1)) do begin
   nt = where(ttimes ge startt and ttimes lt endt)
   if nt(0) ge 0 then begin
      it = it+1
      ntmin = min(nt)
      ntmax = max(nt)
      mean_time = (ttimes(ntmin)+ttimes(ntmax))/2
      utc = tai2utc(mean_time)
      out(it).date.mjd = utc.mjd
      out(it).date.time = utc.time
      out(it).data = average(data(ntmin:ntmax))
      bottom(it) = min(data(ntmin:ntmax))
      top(it) = max(data(ntmin:ntmax))
   endif else begin
      mean_time = startt + interval/2
      utc = tai2utc(mean_time)
      out(it).date.mjd = utc.mjd
      out(it).date.time = utc.time
      out(it).data = 0
      bottom(it) = 0
      top(it) = 0
   endelse            
   startt = startt + interval
   endt   = endt   + interval
endwhile

;
;  trim output
;
out = out(0:it)
top = top(0:it)
bottom = bottom(0:it)

return,out
end




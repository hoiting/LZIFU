pro adjust_times, t0, t1, text, status=status, deltat=deltat, $
   maxdays=maxdays, timerange=timerange, earliest=earliest, lastest=latest
;+
;   Name: adjust_times
;
;   Purpose: check input times and adjust if required 
;
;   Input Parameters:
;      t0 - start time 	- any Yohkoh format
;      t1 - stop time
;
;   Output Parameters:
;      t0 - start time (adjusted)	; output is always Yohkoh string format
;      t1 - stop time (adjusted)
;
;   Keyword Parameters
;      maxdays   - if set, maximum number of days allowed (t1-t0)
;      timerange - 2 element vector; force times to fall in this range
;      earliest  - same as timerange(0)
;      latest    - same as timerange(1)
;      status (output) - true (1) if no problems, false (0) if problems/adjust.
;      deltat (output) - delta Time (seconds between final output times)
;
;   History:
;      28-sep-1995 (S.L.Freeland) to simplify checking WWW form times
;
;   Warning - input times may be clobbered (I mean adjusted)
;-

text=""						; problem/action reporting

case 1 of 
   n_elements(t0) eq 0: begin
         text=[text,"No Times entered, Using Start=UT (now), Stop=Start+ 24 hour"]
         t0=ut_time()
         t1=timegrid(t0,/day,/string)         
   endcase
   n_elements(t1) eq 0: t1=t0
   else:
endcase
   
secs=int2secarr(anytim2ints([t0,t1]))		; 

if n_elements(timerange) eq 2 then begin
   if not keyword_set(earliest) then earliest=timerange(0)
   if not keyword_set(latest) then latest=timerange(1)
endif 

if secs(1) lt 0 then begin
   text=[text,"Stop time precedes start time, swapping times"]
   secs=abs(secs)
   temp=t0
   t0=t1 
   t1=temp
endif

if keyword_set(maxdays) then begin
   if secs(1) gt maxdays*86400. then begin
      t1=timegrid(t0,days=maxdays,/string)
      text=[text,"","Delta-Time (Stop Time - Start Time) exceeded maximum allowed (" + $
             strtrim(maxdays,2) + " days)", "Reset Stop time to " + t1 ]
   endif
endif

if not keyword_set(earliest) then earliest=t0
if not keyword_set(latest) then latest=t1

; set everything to strings
earliest=fmt_tim(earliest)
lastest=fmt_tim(latest)
t0=fmt_tim(t0)
t1=fmt_tim(t1) 

if (int2secarr(t0,earliest))(0) lt 0 then begin
   text=[text,"","Start time precedes start of time range, set to " + earliest]
   t0=earliest
endif

if (int2secarr(t1,latest))(0) gt 0 then begin
   text=[text,"","Stop time after end of allowed range; set to " + latest]
   t1=latest
endif

; recheck
if (int2secarr([t0,t1]))(1) lt 0 then begin
   text=["","Problem adjusting times (outside of range); ", $
         "Setting Start Time -> Timerange start and Stop Time -> Start + 24 hours"]
   t0=earliest
   t1=timegrid(t0,/day,/string)
endif

deltat=abs(total(int2secarr([t0,t1])))

status=n_elements(text) eq 1
if not status then text=text(1:*)		; get rid of initial null

return
end

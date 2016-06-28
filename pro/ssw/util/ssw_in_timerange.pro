function ssw_in_timerange, times, timelo, timehi, outside=outside
;
;+
;   Name: ssw_in_timerange
;
;   Purpose: return boolean "are input times within input time range?"
;
;   Input Parameters:
;      times - input time vector to test ; any SSW time 
;      timelo - range start for compare  ; any SSW time
;      timehi - range stop for compare   ; any SSW time
;
;   Output:
;      function returns boolean, n_elements(times)
;
;   Keyword Parameters:
;      outside - if set, invert sense of test (ie, are tims outside of range)
;
;   Calling Sequence:
;      truth=ssw_in_timerange(times, rangelo, rangehi [,/outside] )
;
;   Method:
;      call ssw_deltat twice to compare input w/start and w/stop
;
;
;   History:
;      S.L.Freeland - 6-June-2004
;-
if n_params() lt 3 then begin 
   box_message,['Must supply time vector, start time and end time...' ,$
                'IDL> truth=ssw_in_timerange(times, rangelo, rangehi [,/outside] )']
   return,0
endif
outside=keyword_set(outside)
lotest=ssw_deltat(times,ref=timelo) ge 0
hitest=ssw_deltat(times,ref=timehi) le 0
retval=abs( (temporary(lotest) and temporary(hitest)) - outside)
if n_elements(retval) eq 1 then retval=retval(0)
return, retval
end

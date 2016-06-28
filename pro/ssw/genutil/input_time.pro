pro input_time, time1, time2, one=one, check=check, print=print, sample=sample, struct=struct
;
;+
;NAME:
;	input_time   
;PURPOSE:
;	To allow a user to interactively enter a start and end time.
;OUTPUT:
;	time1	- The first time/date in the 7-element time convension
;		  (hh,mm,ss,msec,dd,mm,yy)
;				OR
;		  in the structure format with .TIME and .DAY
;		  (this second format is used with the /struct option)
;	time2	- The end time/date in the 7-element time convension
;                               OR
;                 in the structure format with .TIME and .DAY
;                 (this second format is used with the /struct option)
;OPTIONAL INPUT:
;	one	- If present, only request one time
;	print	- If present, print the times selected (for
;		  verification)
;	check	- If present, request that the user "ok" the input
;	sample	- If present, print the sample time strings
;	struct	- If present, have the output be a structure type
;		  variable.
;HISTORY:
;	Written 11-Dec-91 by M.Morrison
;-
;
cur_tim = make_str('{dummy, time: long(0), day: fix(0)}')
st_tim = cur_tim
en_tim = cur_tim        ;define the structure types
;
if (keyword_set(sample)) then begin
    print, 'Sample strings: '
    print, '     11-Nov-91 10:40
    print, '     12-Nov-91
    print, '     11:55 16-oct-91
    print, 'If the ending time only has the time, the day from the start time is used
end
;
qdone = 0
while (not qdone) do begin
    st_timstr = ' '
    en_timstr = ' '
    read, 'Enter starting time ', st_timstr
    st_tarr = timstr2ex(st_timstr)
    ex2int, st_tarr, tt, dd & st_tim.time=tt & st_tim.day = dd
    ;
    if (not keyword_set(one)) then begin
	read, 'Enter ending time   ', en_timstr
	en_tarr = timstr2ex(en_timstr)
	;
	for i=4,6 do if (en_tarr(i) eq 0) then en_tarr(i) = st_tarr(i)	;copy dd,mm,yy if it is blank
	;
	ex2int, en_tarr, tt, dd & en_tim.time=tt & en_tim.day = dd
	;
	del_hrs = int2secarr(en_tim, st_tim)/60/60
    end
    ;
    if (keyword_set(check) or keyword_set(print)) then begin
	print, 'Start time for requested transfer: ', fmt_tim(st_tim)
	if (not keyword_set(one)) then begin
	    print, 'End time for requested transfer:   ', fmt_tim(en_tim)
	    print, 'Duration covered: ', del_hrs, ' hours'
	end
    end
    ;
    if (keyword_set(check)) then begin
	yesnox, 'Is this ok? ', qdone, 'Y'
    end else begin
	qdone = 1
    end
end
;
if (keyword_set(struct)) then begin
    time1 = st_tim
    time2 = en_tim
end else begin
    time1 = fmt_tim(st_tim)
    time2 = fmt_tim(en_tim)
end
;
end

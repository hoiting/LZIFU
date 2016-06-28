function tim2match, sttim_ref, sttim_input, entim_ref=entim_ref, entim_input=entim_input, $
		entim_dur=entim_dur, peak=peak, $
		status=status, qdebug=qdebug
;
;+
;NAME:
;	tim2match
;PURPOSE:
;	Give an array of reference times, determine if the input times fall
;	within any of the time ranges
;SAMPLE CALLING SEQUENCE:
;	out = tim2match(evn, gev)			;uses GOES start
;	out = tim2match(evn, gev, /entim_dur)		;uses GOES time span
;	out = tim2match(evn, gev, /peak)		;uses GOES peak time
;	ii = where(tim2match(sttim, gev, entim_ref=entim) gt 0)	;subscript of GEV where match
;INPUT:
;	sttim_ref	- 
;
;
;
;sttim_ref/entim_ref:    ...........xxxxxxxxxxxxx...........
;sttim_input:            ......x............................  0000 = 0
;			 ..................x................  0001 = 1
;sttim_input/entim_input:...xxx.............................  0000 = 0
;			 ................xxxx...............  0011 = 3
;			 ...............xxxxxxxxxxxxxxx.....  0001 = 1
;			 ......xxxxxxxxxxxxx................  0010 = 2
;			 ......xxxxxxxxxxxxxxxxxxxxxxxx.....  0100 = 4
;
;Special cases:
;--------------
;sttim_ref/entim_ref:    ...........xxxxxxx....xxxxxx.......
;sttim_input/entim_input:
;			 ...............xxxxxxxxxxxxxxx.....  ???
;			 ......xxxxxxxxxxxxxxxxxx...........  ???
;			 ......xxxxxxxxxxxxxxxxxxxxxxxx.....  ???
;			 ..............xxxxxxxxxxx..........  ???
;
;
;Example: Given the EVN data, find where GOES data matches up
;         Given the GOES data, find where EVN data matches up
;
;
;Status Returned:	0 = no matches/overlap
;			b0 = start time is within _ref time span
;			b1 = end time is within _ref time span
;			b2 = start/end time encompass the _ref time span
;			b7 = flag to say that multiple REF times were spanned
;-
;
qsingle_time = 1
st_input = anytim2ints(sttim_input)
if (keyword_set(peak)) then st_input = anytim2ints(sttim_input, off=sttim_input.peak)
;
if (keyword_set(entim_input)) then begin
    en_input = anytim2ints(entim_input)
    qsingle_time = 0
end
if (keyword_set(entim_dur)) then begin
    qsingle_time = 0
    en_input = anytim2ints(sttim_input, off=sttim_input.duration)
end
;
st_ref = anytim2ints(sttim_ref)
if (keyword_set(entim_ref)) then begin
    en_ref = anytim2ints(entim_ref)
end else begin
    en_ref = anytim2ints(sttim_ref, off=sttim_ref.duration)
end
;
n = n_elements(sttim_input)
out = lonarr(n)-1
status = bytarr(n)
;
ref_time = st_ref(0)
x_st_ref = int2secarr(st_ref, ref_time)
x_en_ref = int2secarr(en_ref, ref_time)
for i=0,n-1 do begin
    xx1 = int2secarr(st_input(i), ref_time)
    ss1 = where( (x_st_ref le xx1) and (x_en_ref ge xx1) )
    if (ss1(0) ne -1) then begin
	out(i) = ss1(0)
	status(i) = status(i) + 1b
    end
    ;
    if (qsingle_time eq 0) then begin
	xx2 = int2secarr(en_input(i), ref_time)
	ss2 = where( (x_st_ref le xx2) and (x_en_ref ge xx2) )
	if (ss2(0) ne -1) then begin
	    status(i) = status(i) + 2b
	    if (ss1(0) eq -1) then out(i) = ss2(0)
	    if ((ss2(0) ne ss1(0)) and (ss1(0) ne -1)) then status(i) = status(i) + 127b
	end

	ss3 = where( (x_st_ref gt xx1) and (x_en_ref lt xx2) )
	if (ss3(0) ne -1) then begin
	    status(i) = status(i) + 4b
	    if (out(i) eq -1) then out(i) = ss3(0)
	end
    end

    if (keyword_set(qdebug)) then begin
	str1 = 'Reference Times: ' + fmt_tim(st_ref) + ' to ' + fmt_tim(en_ref)
	str2 = 'Input Time:      ' + fmt_tim(st_input(i))
	if (qsingle_time eq 0) then str2 = str2 + ' to ' + fmt_tim(en_input(i))
	if (i eq 0) then print, str1
	print, str2
	print, 'Result:          ', out(i), status(i)
    end
end
;
return, out
end

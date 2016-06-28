;+
; Project     : HESSI
;
; Name        : UNFORMAT_INTERVALS
;
; Purpose     : Function to unformat intervals that were formatted into ASCII strings by
;               the format_intervals routine
;
; Category    : Utility
;
; Explanation : format_intervals produces an array of strings that look like:
;                 '2.2 to 3.7', '4.1 to 5.6'
;               unformat_intervals will return the array of numbers
;               2.2,3.7
;               4.1, 5.6
;               as a [2,n] array
;               If intervals are times, unformat_intervals returns double precision sec.
;
; Syntax      : IDL> result = unformat_intervals (list, ut=ut, err_msg=err_msg)
;
; Inputs      : list - array of strings that were formatted by format_intervals
;
; Opt. Input Keywords :
;               ut - if set, treat interval values as time
;
; Outputs     : Returns [2,n] array of values for intervals
;
; Opt. Output Keywords:
;				err_msg - Normally '', but contains error text if any.
;
; Common      : None
;
; Restrictions: Input range must be [2xn]
;
; Side effects: None
;
; History     : 14-Nov-2001, Kim Tolbert
; Modifications:
;   15-Aug-2003, Kim.  Check for ' - ' as well as ' to ' to separate start/end of interval
;	20-Jun-2005, Kim.  Relaxed restrictions for separator - can have any # blanks followed
;		by 'to' or '-', followed by any # blanks (except for times need at least one blank
;		surrounding '-' since there's a '-' in the time format)
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;-

function unformat_intervals, list, ut=ut, err_msg=err_msg

err_msg = ''

on_ioerror, error_exit

comma = strpos (list, ',')
list = strmids (list, comma+1)

;dash = strpos (list, ' - ')
;q = where (dash ne -1, count)
;if count gt 0 then list = str_replace(list, ' - ', ' to ')
;to = strpos (list, ' to ')
;int1 = strmids (list, 0, to)
;int2 = strmids (list, to+3)

; for non-ut, find any # of blanks followed by '-' or 'to' followed by any # of blanks
; for ut, same thing, but require at least one blank surrounding '-' to differentiate from
; '-' in times.
str2chk = keyword_set(ut) ? '( +- +| *to *)'  : ' *(-|to) *'
strloc = stregex (list, str2chk, length=length)
int1 = strmids (list, 0, strloc)
int2 = strmids (list, strloc+length)

if keyword_set(ut) then begin
	checkvar, utbase, 0.d
	int1 = anytim(int1, /sec, error=error1)
	if error1 then goto, error_exit
	; end of interval may just have time, check if crossed a day boundary
	int2 = anytim(int2, /sec, error=error2)
	if error2 then goto, error_exit
	int1date = anytim(int1, /sec, /date)
	int1time = anytim(int1, /sec, /time)
	int2time = anytim(int2, /sec, /time)
	q = where (int2time lt int1time, count)
	int2 = int1date + int2time
	if count gt 0 then int2[q] = (int1date[q] + 86400.d0) + int2time[q]
	int1 = int1 - utbase
	int2 = int2 - utbase
endif else begin
	int1 = float(int1)
	int2 = float(int2)
endelse

return, transpose([ [int1], [int2]])

error_exit:
	err_msg = 'Error in interpreting intervals.  Aborting.'
	return, -1

end
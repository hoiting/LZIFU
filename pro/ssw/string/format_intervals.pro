
;+
; Project     : HESSI
;
; Name        : FORMAT_INTERVALS
;
; Purpose     : Function to format intervals as ASCII strings
;
; Category    : Utility
;
; Explanation : Output is an array of strings.
;               If intervals are numbers, strings look like:
;                 '2.2 to 3.7', '4.1 to 5.6', with the numbers formatted
;                  as specified by format keyword
;               If intervals are times, strings look like:
;                 '12-Nov-2000 02:40:00.000 to 02:40:00.000' with the times formatted
;                  as specified by user.  Default format is /vms.

; Syntax      : IDL> result = format_intervals (int, ut=ut, format=format, $
;                    left_just=left_just, _extra=_extra)
;
; Inputs      : int - 2xn array of interval start/end values
;
; Input Keywords :
;	UT - if set, treat interval values as time
;         format - string containing format specification for values in interval
;         (ignored if ut is set)
;	LEFT_JUST - if set, then left justify strings
;	PREFIX - if set, then insert 'Interval n' in front of interval
;	MAXINT - maximum number of intervals to format.  If number of intervals
;			  is > maxint, then show first intervals up to maxint, then '...', then last interval.
;	END_DATE - if set, include end date in time intervals. Default is no end date.
;	_EXTRA - any additional keywords to pass to anytim for ut intervals
;
; Outputs     : Returns array of strings with formatted intervals.  If int is not a 2xn array
;               returns the string 'None'.
;
; Opt. Output Keywords: None
;
; Examples:
; IDL> int = [[2,3],[5,6],[7,8]]
; IDL> print,format_intervals(int, format='(f5.1)')
;   2.0 to 3.0
;   5.0 to 6.0
;   7.0 to 8.0
; IDL> int = [[2,3],[12,18],[70,80]] + anytim('2001/9/1 12:00')
; IDL> print,format_intervals(int, /ut, /yohkoh)
;   01-Sep-01 12:00:02.000 to 12:00:03.000
;   01-Sep-01 12:00:12.000 to 12:00:18.000
;   01-Sep-01 12:01:10.000 to 12:01:20.000
;
; Common      : None
;
; Restrictions: Input range must be [2xn]
;
; Side effects: None
;
; History     : 25-Aug-2001, Kim Tolbert
; Modifications:
;	19-Jun-2002, Kim.  Use fstring instead of string to handle arrays > 1024.
;	14-OCt-2002, Kim.  Added maxint keyword
;	31-Jul-2007, Kim.  Changed two indgens to lindgens
;	25-Feb-2008, Kim.  Added end_date keyword
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;-

function format_intervals, int, ut=ut, format=format, $
	left_just=left_just, prefix=prefix, maxint=maxint, end_date=end_date, _extra=_extra

if n_elements(int[*,0]) ne 2 then return, 'None'
nint = n_elements(int[0,*])

trunc = 0
ind = lindgen(nint)
if keyword_set(maxint) then if nint gt maxint then begin
	trunc = 1
	ind = [lindgen(maxint), nint-1]
endif

if keyword_set(ut) then begin
	i1 = anytim(reform(int[0,ind]), _extra=_extra)
	i2 = anytim(reform(int[1,ind]), _extra=_extra, /time)
	; if user didn't pass an ascii format type, then will be a number
	; default format is /vms
	if size(i1,/tname) ne 'STRING' or size(i2,/tname) ne 'STRING' then begin
		i1 = anytim(reform(int[0,ind]), /vms)
		i2 = anytim(reform(int[1,ind]), /vms, time=(keyword_set(end_date) eq 0))
	endif
	if keyword_set(left_just) then i1 = strtrim(i1,1)
endif else begin
	i1 = strtrim (fstring (int[0,ind], format=format), 2)
	i2 = strtrim (fstring (int[1,ind], format=format), 2)
endelse

pre = keyword_set(prefix) ? 'Interval ' + strtrim(indgen(n_elements(i1)),2) + ', ' : ''
ret = pre + i1 + ' to ' + i2
if n_dimensions(ret) gt 1 then ret = reform(ret)

if trunc then ret[maxint-1] = '...'

if n_elements(ret) eq 1 then ret = ret[0]
return, ret

end

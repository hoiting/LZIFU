pro pr_tim2week, intime, t1, t2, range=range
;+
; NAME:
;   pr_tim2week
; PURPOSE:
;   Print Yohkoh week ID for specified time
; CALLING SEQUENCE:
;   pr_tim2week, index(0)
;   pr_tim2week			; Current week ID
;   pr_tim2week, /range		; Print start and stop dates
; OPTIONAL INPUTS:
;   intime	= Time in any Yohkoh format
; OPTIONAL INPUT KEYWORDS:
;   range	= If set, print the time range
; OPTIONAL OUTPUTS:
;   t1, t2	= Time range of specified week(s)
; PROCEDURE:
;   Calls anytim2weekid
;   Short weeks (first and last week of the year) are flagged with a "*".
;   Note:  If the time of the data occurs near 00:00 UT on Sunday, then
;          the Yohkoh data might be included in the previous week.
; MODIFICATION HISTORY:
;   22-jan-94, J. R. Lemen, Written
;-

if n_elements(intime) eq 0 then time = !stime else time = intime
tarr_int = anytim2ints(time)
week_ID = anytim2weekid( intime, t1, t2, ndays ,/str)
flag = replicate('*',8) & flag(7) = ' '

for i=0,n_elements(week_ID)-1 do begin
  str = string(fmt_tim(tarr_int(i)),' is in week ',week_ID(i),format='(3a)')
  if keyword_set(range) then 		$
       str = str + '    ( ' + t1(i) + ' to ' + t2(i) + ' ) '+flag(ndays(i))
  print,str
endfor

end

pro pr_week2tim, week_id, t1, t2, year=year
;+
; NAME:
;   pr_week2tim
; PURPOSE:
;   Print time range for specified Yohkoh week ID 
; CALLING SEQUENCE:
;   pr_week2tim, '94_04a'	; Time range of week 4 of 1994
;   pr_week2tim, 4		; Week 4 of current year
;   pr_week2tim, 4, year=93	; Week 4 of 1993
;   pr_week2tim, '94_04a', t1, t2 ; Return start and stop days
;   pr_week2tim			; Range of the current week
; INPUT:
;   week_id	= Yohkoh Week ID (string) - may be a vector
; OPTIONAL OUTPUTS:
;   t1, t2	= Time range of specified week(s)
; PROCEDURE:
;   Calls weekid2ex
;   Short weeks (first and last week of the year) are flagged with a "*".
; MODIFICATION HISTORY:
;   22-jan-94, J. R. Lemen, Written
;-

time = weekid2ex(week_id, t1, t2, ndays, year=year, week_id_fmt=week_id_fmt)
flag = replicate('*',8) & flag(7) = ' '

for i=0,n_elements(time(0,*))-1 do 					$
	print,string('Week ID ',week_id_fmt(i),		$
	' covers    ',t1(i) + ' to ' + t2(i),' '+flag(ndays(i)),$
	format='(7a)')

end

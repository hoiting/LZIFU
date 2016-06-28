pro filetimes, files, startt, stopt, string=string
;
;+
;   Name: filetimes
;
;   Purpose: return start and stop times in Yohkoh reformatted files
;
;   Input Parameters:
;      files - array of reformatted file names 
;
;   Ouput Paramters:
;	startt - start time of file in external format (7,n)
;       stopt  - stop time of files in external format (7,n)
;
;   Optional Keyword Parameters:
;	string - if set, return time is converted to string strarr(n)
;
;   Method : calls rd_fheader and converts start and stop times
;
;   History: slf, 3-August-1992
;-
; read the files
rd_fheader, files, headers
;
; convert start/stop fields to external format
int2ex,headers.first_time,headers.first_day, startex
int2ex,headers.last_time, headers.last_day,  stopex
startt= startex
stopt = stopex
;
; convert to string on request
if keyword_set(string) then begin
   startt=gt_time(startt,/string) + ' ' + gt_day(startt,/string)
   stopt =gt_time(stopt,/string)  + ' ' + gt_day(stopt,/string)
endif

return
end

;+
; Project     : HESSI
;
; Name        : FILE_SINCE
;
; Purpose     : LOCATE files older/newer than a specified time
;
; Category    : utility system 
;                   
; Inputs      : See keywords
;
; Outputs     : FILES = located files
;
; Keywords    : OLDER = find files older than this interval 
;               NEWER  = files newer than this interval
;               DAYS = interval units in days [def]
;               HOURS = interval units in hours
;               ERR= string error
;               TIME_REF = time to reference against [def= current]
;               COUNT = # of files found
;
; History     : 24-Feb-2002,  D.M. Zarro (EITI/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function file_since,older=older,newer=newer,hours=hours,days=days,$
                    count=count,err=err,patt=patt,_extra=extra,time_ref=time_ref

err='' & count=0 & check_older=1b
case 1 of
  is_number(older): delay=older
  is_number(newer): begin
   delay=newer & check_older=0b
  end
 else: begin
  err=' /older or /newer keyword value required'
  message,err,/cont
  return,''
 end
endcase

;-- list files

if is_blank(patt) then patt='*.*'
files=loc_file(patt,count=count,_extra=extra)
if count eq 0 then return,''

tsec=abs(delay)*3600.d*24.
if keyword_set(hours) then tsec=abs(delay)*3600.d

;-- determine file creation times in TAI format

tbase=anytim2tai('1-Jan-1970')
times=file_content(files,/times,/tai)
tbase=anytim2tai('1-jan-70')

;-- determine reference time in TAI

tref=systime(/sec)+tbase
if exist(time_ref) then begin
 if not valid_time(time_ref) then begin
  message,'Invalid reference time, using current system time',/cont
 endif else tref=anytim2tai(time_ref)
endif

if check_older then $
 chk=where(times le (tref-tsec),count) else $
  chk=where(times ge (tref-tsec), count)

if count eq 1 then chk=chk[0]

if count gt 0 then return,files[chk]

return,''
end

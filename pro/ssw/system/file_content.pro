;+
; Project     : HESSI
;
; Name        : FILE_CONTENT
;
; Purpose     : Determine file content (access time, size in bytes, etc)
;
; Category    : utility system 
;                   
; Inputs      : FILE = scalar or array of file names
;
; Outputs     : VALUE depending upon keyword
;
; Keywords    : /SIZE = return byte size
;             : /TIME = return creation time
;             : /TAI  = time in TAI
;             :  ERR  = string error
;
; History     : 22-Feb-2002,  D.M. Zarro (EITI/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function file_content,file,err=err,times=times,sizes=sizes,tai=tai,$
                      megabyte=megabyte,kilobyte=kilobyte

err=''
np=n_elements(file)
if is_blank(file) then begin
 err='Need at least one non-blank filename'
 message,err,/cont
 return,0
endif

if (not keyword_set(times)) and (not keyword_set(sizes)) then begin
 err='Need at least /times or /sizes'
 message,err,/cont
 return,0
endif

bsize=lonarr(np) & ctime=dblarr(np)
for i=0,np-1 do begin
 openr,lun,file[i],/get_lun,err=status
 if status eq 0 then begin
  s=fstat(lun)
  bsize(i)=s.size
  ctime(i)=s.ctime
 endif
 if exist(lun) then free_lun,lun
endfor

tbase=anytim2tai('1-jan-70')
if np eq 1 then begin
 ctime=ctime[0]
 bsize=bsize[0]
endif

ctime=temporary(ctime)+tbase
if keyword_set(times) then begin
 if keyword_set(tai) then return,ctime else return,anytim2utc(ctime,/vms)
endif

if keyword_set(sizes) then begin
 if keyword_set(megabyte) then return,bsize/1.e6
 if keyword_set(kilobyte) then return,bsize/1.e3
 return,bsize
endif

return,0.

end


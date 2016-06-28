;+
; Project     : HESSI
;
; Name        : RD_ASCII_C
;
; Purpose     : read ASCII files which may be compressed
;
; Category    : utility system
;
; Syntax      : IDL> out=rd_ascii_c(file)
;
; Inputs      : FILE = filename to read
;
; Keywords    : ERR= error string
;               BUFFSIZE = string buffer size to read [def=512]
;
; History     : Written, 12 Dec 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function rd_ascii_c,file,buffsize=buffsize,err=err

err=''
cfile=loc_file(file,count=count,err=err,/verb)
if count eq 0 then return,''

compressed=is_compressed(cfile,type)

openr,lun,cfile,/get_lun,compress=compressed,error=error
if error ne 0 then begin
 err='Error opening file - '+cfile
 message,err,/cont
 return,''
endif

;-- read in chunks of buffsize length character strings until EOF

data=rd_ascii_buff(lun,buffsize)

if exist(lun) then free_lun,lun

if (n_elements(data) eq 1) and (trim(data[0]) eq '')  then begin
 err='Empty file - '+cfile
 message,err,/cont
endif

return,data & end


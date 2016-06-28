;+
; Project     : HESSI
;
; Name        : RD_ASCII_BUFF
;
; Purpose     : read ASCII buffer
;
; Category    : utility system
;
; Syntax      : IDL> out=rd_ascii_buff(lun,buffsize)
;
; Inputs      : LUN = logical unit number
;
; Opt. Inputs : BUFFSIZE = string buffer size to read [def=512]
;
; Keywords    : BYTE_READ = set to call RD_ASCII_BYTE
;
; History     : Written, 27 Dec 2001, D. Zarro (EITI/GSFC)
;               Modified, 24 Nov 2005, Zarro (L-3Com/GSFC) 
;                - added /byte_read
;
; Contact     : dzarro@solar.stanford.edu
;-

function rd_ascii_buff,lun,buffsize,_extra=extra,byte_read=byte_read

if keyword_set(byte_read) then begin
 return,rd_ascii_byte(lun,buffsize,_extra=extra)
endif

if not is_number(lun) then return,''
if not (fstat(lun)).open then return,''

;-- read in chunks of buffsize length character strings until EOF

if is_number(buffsize) then buffsize=long(buffsize) else buffsize=512l

on_ioerror,done

forever=0b
clean_break=0b
repeat begin
 b=strarr(buffsize)
 readf,lun,b
 if exist(temp) then temp=[temporary(temp),b] else temp=b
endrep until forever
clean_break=1b

done: 
on_ioerror,null
if not clean_break and exist(temp) then temp=[temporary(temp),temporary(b)]
if not exist(temp) then temp=temporary(b)

;-- trim off trailing blank lines

nt=n_elements(temp)
noblank=where(strtrim(temp,2) ne '',count)
if count gt 0 then begin
 nbt=noblank[count-1]
 if nbt lt (nt-1) then temp=temporary(temp[0l:nbt])
endif else temp=''

dprint,'% RD_ASCII_BUFF: buff, ',n_elements(temp)

return,temporary(temp)

end

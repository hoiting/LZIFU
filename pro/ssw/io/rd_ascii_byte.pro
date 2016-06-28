;+
; Project     : HESSI
;
; Name        : RD_ASCII_BYTE
;
; Purpose     : read ASCII input as bytes
;              (circumvents internal string buffer limits on some systems)
;
; Category    : utility system
;
; Syntax      : IDL> output=rd_ascii_byte(lun,buffize)
;
; Inputs      : LUN = logical unit number
;
; Opt. Inputs : BUFFSIZE = string buffer size to read [def=512]
;
; History     : Written, 27 Nov 2005, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function rd_ascii_byte,lun,buffsize,err=err

err=''
if not is_number(lun) then return,''
if not (fstat(lun)).open then return,''

;-- read in chunks of buffsize length character strings until EOF

if is_number(buffsize) then buffsize=long(buffsize) else buffsize=512l

on_ioerror,done

forever=0b
clean_break=0b
repeat begin
 b=bytarr(buffsize,/nozero)
 readu,lun,b
 if exist(temp) then temp=[[temporary(temp)],[b]] else temp=b
endrep until forever
clean_break=1b

done:
on_ioerror,null
if not clean_break and exist(temp) then temp=[[temporary(temp)],[temporary(b)]]
if not exist(temp) then temp=temporary(b)

;-- write string array to temp file and then read back as ascii to
;   preserve line breaks

temp=string(temporary(temp))
temp_file=get_temp_file()
openw,lunw,temp_file,/get_lun
printf,lunw,transpose(temp)
close_lun,lunw
temp=rd_ascii(temp_file)
file_delete,temp_file,/quiet

return,temp

end

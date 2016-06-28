;+
; Project     : HESSI
;
; Name        : RD_BUFF
;
; Purpose     : read unformatted data buffer
;
; Category    : utility system
;
; Syntax      : IDL> out=rd_buff(lun,maxsize,chunk)
;
; Inputs      : LUN = logical unit number
;               MAXSIZE = max size of file in bytes
;
; Opt. Inputs : CHUNK = chunk factor to break buffer into [def=10]
;
; History     : Written, 3 April 2002, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function rd_buff,lun,maxsize,chunk,err=err,counts=counts

err=''
if not is_number(lun) then return,0b
if not (fstat(lun)).open then return,0b
if not is_number(maxsize) then return,0b

;-- read in chunks until EOF

if is_number(chunk) then fac=float(abs(chunk)) > 1. else fac=10.
buffsize=long( maxsize/fac)
if buffsize lt 1 then buffsize=maxsize
on_ioerror,done

err_flag=1b
data=bytarr(maxsize,/nozero)
counts=0l
istart=0l
repeat begin
 iend=(istart+buffsize-1) < (maxsize-1)
 bsize=iend-istart+1
 b=bytarr(bsize,/nozero)
 readu,lun,b,transfer=count
 counts=counts+count
 data[istart:iend]=temporary(b)
 istart=istart+buffsize
endrep until (iend eq (maxsize-1))

err_flag=0b
done: 
on_ioerror,null

if err_flag then begin
 err='Problems with buffered read'
 message,err,/cont
 return,0b
endif

return,data

end

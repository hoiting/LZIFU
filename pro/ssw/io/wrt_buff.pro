;+
; Project     : HESSI
;
; Name        : wrt_buff
;
; Purpose     : write unformatted data buffer
;
; Category    : utility system
;
; Syntax      : IDL> wrt_buff,lun,data,chunk
;
; Inputs      : LUN = logical unit number
;               DATA = data array to write
;
; Opt. Inputs : CHUNK = chunk factor to break buffer into [def=10]
;
; History     : Written, 3 April 2002, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro wrt_buff,lun,data,chunk,err=err,counts=counts

err=''
if not is_number(lun) then return
if not (fstat(lun)).open then return

;-- write in chunks 

maxsize=n_elements(data)
if maxsize eq 0 then return

if is_number(chunk) then fac=float(abs(chunk)) > 1. else fac=10.
buffsize=long( maxsize/fac)
if buffsize lt 1 then buffsize=maxsize
on_ioerror,done

err_flag=1b
counts=0l
istart=0l
repeat begin
 iend=(istart+buffsize-1) < (maxsize-1)
 writeu,lun,data[istart:iend],transfer=count
 counts=counts+count
 istart=istart+buffsize
endrep until (iend eq (maxsize-1))

err_flag=0b
done: 
on_ioerror,null

if err_flag then begin
 err='Problems with buffered write'
 message,err,/cont
 return
endif

return

end


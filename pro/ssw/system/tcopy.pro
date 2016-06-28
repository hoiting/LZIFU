;+
; NAME:   
;      TCOPY
; PURPOSE:
;      Copy files from tape to tape
; CALLING SEQUENCE:
;      TCOPY
; INPUTS: 
;      idrv, odrv = unit numbers to copy from and to, respectively
; PROCEDURE
;      does it record by record, and file by file.
; RESTRICTIONS: 
;      VMS only
; HISTORY:
;      written DMZ (ARC Mar'93)
;-

pro tcopy,idrv,odrv,verbose=verbose

on_error,1
buf = bytarr(65000)	; changed from 32768 to 65000 8/5/93 akt
j = 1
i = 0l
if keyword_set(verbose) then verbose=1 else verbose=0

;-- drive choices

if n_elements(idrv)*n_elements(odrv) eq 0 then spawn,'$sh log mt*'

if n_elements(idrv) eq 0 then begin
 repeat begin
  idrv='' & read,'* enter source tape drive number: ',idrv
 endrep until idrv ne ''
endif
idrv=fix(idrv)

if n_elements(odrv) eq 0 then begin
 repeat begin
  odrv='' & read,'* enter target tape drive number: ',odrv
 endrep until odrv ne ''
endif
odrv=fix(odrv)


err_type = -1
neof = 0

;-- copying loop

copyloop:
on_ioerror, ckeof

print, "$(/' * File Number: ', i3, ' *'/)", j
forever=0
repeat begin
    i = i + 1L
    err_type = 0
    taprd, buf, idrv
    if verbose then $
     print, "$('+    Record Number: ', i6, '  Record Size: ', i8)", i, !err
    neof = 0
    err_type = 1
    tapwrt, buf(0:!err-1), odrv
endrep until forever

;-- Handle EOF and other errors

ckeof: on_ioerror,null

error_message = !syserr_string

eot_mark = (strpos(error_message,'%SYSTEM-W-ENDOFTAPE') ge 0)
offline=(strpos(error_message,'VOLINV') ne -1) 
alloc=(strpos(error_message,'ALLOC') ne -1)
invalid=(strpos(error_message,'IVDEVNA') ne -1)
nosuch=(strpos(error_message,'NOSUCH') ne -1)
if eot_mark or offline or alloc or invalid or nosuch then begin
   print,!err_string
   print,strmessage(!error)
   print,error_message
   return
endif

eof_mark = (strpos(error_message,'%SYSTEM-W-ENDOFFILE') ge 0)
if eof_mark then begin		; EOF on read !!!
    print, 'End of File.  Number of records copied = ', i-1
    weof, odrv
    neof = neof + 1
    if (neof eq 2) then message, 'Tape copy finished at '+!stime
    i = 0l
    j= j + 1
endif else begin
    print,!err_string
    print,strmessage(!error)
    print,error_message
    message,'skipping possible bad record # '+string(i,'(i6)'),/contin
    skipf,idrv,1,R
endelse

goto, copyloop


return & end

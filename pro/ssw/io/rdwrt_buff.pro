;+
; Project     : HESSI
;
; Name        : RDWRT_BUFF
;
; Purpose     : read & write unformatted data buffer
;
; Category    : utility system
;
; Syntax      : IDL> rdwrt_buff,ilun,olun,chunk
;
; Inputs      : ILUN = logical unit to read from
;               OLUN = logical unit to write to
;               MAXSIZE = max size in bytes to read/write 
;
; Keywords    : BUFFSIZE = buffer size to read/write [def = 1 MB]
;               COUNTS = bytes actually read/written
;               ERR = error string
;               PROGRESS = set for progress meter
;               CANCELLED = 1 if reading was cancelled
;               SLURP = read without buffering
;               OMESSSAGE = output message (if /VERBOSE)
;
; History     : Written, 6 May 2002, D. Zarro (L-3Com/GSFC)
;             : Modified, 20 Sept 2003, D. Zarro (L-3Com/GSFC) 
;               - added extra error checks
;               Modified, 26 Dec 2005, Zarro (L-3Com/GSFC) 
;               - improved /VERBOSE output
;               Modified, 12 Nov 2006, Zarro (ADNET/GSFC)
;               - moved X-windows check into CASE statement
;               Modified, 21 Jan 2007, Zarro (ADNET/GSFC)
;               - fixed /PROGRESS
;               Modified, 1 Dec 2007, Zarro (ADNET)
;               - support reading files when maxsize is not known
;
; Contact     : dzarro@solar.stanford.edu
;-

pro rdwrt_buff,ilun,olun,maxsize,buffsize=buffsize,counts=counts,err=err,$
               _extra=extra,omessage=omessage,bar=bar,$
               verbose=verbose,cancelled=cancelled,slurp=slurp,progress=progress

cancelled=0b & err='' & counts=0l

;-- input checks

if (1-is_number(ilun)) then return
if (1-is_number(olun)) then return
if (1-(fstat(ilun)).open) then return
if (1-(fstat(olun)).open) then return
if (1-is_number(maxsize)) then maxsize=0l
if (1-is_number(buffsize)) then buffsize=1000000l

on_ioerror,done

;-- show progress bar if file size greater than buffsize (1Mb)

if keyword_set(slurp) and (maxsize ne 0l) then buffsize=maxsize
show_verbose=keyword_set(verbose)
show_progress=keyword_set(progress) and (maxsize ne 0l) 

case 1 of
 show_progress: begin
  if allow_windows() then begin
   if (buffsize lt maxsize) then $
    pid=progmeter(/init,button='Cancel',_extra=extra,input=omessage) else begin
     xtext,omessage,/just_reg,wbase=wbase
     xkill,wbase
   endelse
  endif
 end
 show_verbose: begin
  if is_string(omessage) then begin
   for i=0,n_elements(omessage)-1 do message,omessage[i],/cont,noname=(i gt 0)    
  endif
 end
 else:do_nothing=1
endcase

err_flag=1b
icounts=0l
ocounts=0l
istart=0l
repeat begin

 iend=(istart+buffsize-1) 
 if maxsize gt 0l then iend = iend < (maxsize-1)
 bsize=iend-istart+1l
 if not exist(old_bsize) then data=bytarr(bsize,/nozero) else begin
  if bsize lt old_bsize then data=temporary(data[0:bsize-1])
 endelse

 if show_progress then begin
  val = float(icounts)/float(maxsize)
  dprint,'% val: ',val
  if val lt 1 then begin
   if widget_valid(pid) then begin
    if (progmeter(pid,val) eq 'Cancel') then begin
     xkill,pid
     message,'Downloading cancelled',/cont
     cancelled=1b
     on_ioerror,null
     return
    endif
   endif
  endif
 endif

;-- read and write buffsize bytes 

 readu,ilun,data,transfer=icount
 icounts=icounts+icount

retry:
 writeu,olun,data,transfer=ocount
 ocounts=ocounts+ocount
 istart=istart+icount
 old_bsize=bsize
 if (maxsize eq 0) then quit=0b else quit=(iend eq (maxsize-1))
endrep until quit

;-- wrap up

err_flag=0b
done:

;-- check if apparent end-of-file reached (can happen with proxy servers)

if err_flag then begin
 icount=(fstat(ilun)).transfer_count
 if icount gt 0 then begin
  icount=icount < n_elements(data)
  data=data[0:icount-1]
  icounts=icounts+icount
  writeu,olun,data,transfer=ocount
  ocounts=ocounts+ocount
  if (maxsize eq 0l) then begin
   if eof(ilun) then err_flag=0b
  endif else begin
   if (maxsize eq ocounts) then err_flag=0b
  endelse
 endif
endif

on_ioerror,null

if err_flag then begin
 err='Problems with buffered read/write. Aborting...'
 message,err,/cont
 return
endif

counts=ocounts

bail:
xkill,wbase
xkill,pid
delvarx,data

return

end

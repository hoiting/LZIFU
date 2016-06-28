;+
; Project     : VSO
;
; Name        : strip_crt
;
; Purpose     : strip annoying <CR>'s from ASCII file
;
; Category    : utility string
;
; Syntax      : IDL> strip_return,ifile,ofile
;
; Inputs      : IFILE = input file
;
; Outputs     : OFILE = output file
;               [if not present, then IFILE is clobbered]
;
; Keywords    : ERR = error string
;
; History     : 12-Nov-2005, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro strip_crt,ifile,ofile,err=err

err=''

if n_params() eq 0 then begin
 pr_syntax,'strip_return,ifile,ofile'
 return
endif

if file_break(ifile,/ext) eq '' then dfile=ifile+'.pro' else dfile=ifile
chk=loc_file(dfile,count=count,err=err)
if count eq 0 then begin
 message,err,/cont
 return
endif

;-- strip by reading and rewriting

text=rd_ascii(dfile)
if is_blank(ofile) then ofile=dfile
message,'writing to '+ofile,/cont
wrt_ascii,text,ofile,err=err

return & end

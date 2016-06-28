;+
; Project     : SOHO - CDS
;
; Name        : STRIP_WILD
;
; Category    : Utility, string, help
;
; Purpose     : Strip wild characters (*,?) from procedure name
;
; Explanation : Used in WWW search engine
;
; Syntax      : IDL> fproc=strip_wild(proc)
;
; Inputs      : PROC = procedure name (e.g. *xdoc, or xdoc*)
;
; Opt. Inputs : None
;
; Outputs     : FPROC = stripped name (e.g. xdoc)
;
; Opt. Outputs: None
;
; Keywords    : WBEGIN = true if input has wild character at beginning
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  2-Oct-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function strip_wild,proc,wbegin=wbegin

on_error,1
if datatype(proc) ne 'STR' then return,''

temp=strcompress(strupcase(proc),/rem)
break_file,temp,fdsk,fdir,fproc
fproc=strep(fproc,'?','*',/all,/compress)
abyte=byte('*')
astpos=where(byte(fproc) eq abyte(0), acount)
wbegin=0
if acount gt 0 then begin
 chk=where(astpos eq 0,pcount)
 wbegin=(pcount gt 0)
endif
fproc=strep(fproc,'*','',/all,/compress)

return,fproc & end

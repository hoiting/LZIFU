;+
; Project     : SOHO - CDS
;
; Name        : LIST_PRINTER_UNIX
;
; Purpose     : LIST available printers from /etc/printcap or /etc/printers.conf
;
; Category    : Help, Device
;
; Explanation : Reads /etc/printcap or /etc/printers.conf
;
; Syntax      : IDL> printers=list_printer_unix(desc)
;
; Examples    :
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : PRINTERS - printer que names
;
; Opt. Outputs: DESC -  description of each printer
;
; Keywords    : ERR - error messages
;
; Common      : LIST_PRINTER_UNIX - contains last reading of printcap file
;
; Restrictions: Unix only.
;
; Side effects: None
;
; History     : Version 1,  8-Aug-1995, D M Zarro . Written
;               Version 2,  1 July 1996, S.V.H.Haugan (UiO)
;                       Added PSLASER/PSCOLOR/PSCOLOR2 environmentals check.
;               1-Nov-2000, Kim Tolbert - Previously only worked for unix machines with
;                       /etc/printcap file for printers (DEC, ?). Added check
;                       for /etc/printers.conf (Sun) also.
;               18-Dec-2001, Kim Tolbert.  Some unix (linux) allows pipe symbol (|) in
;                       lp definition (like :lp=|/usr/share/printconf/jetdirectprint:\)
;                       so have to look for names in lines with | but no colon in first column.
;                       Also, names can be in lines with |, or lines with : (if not in
;                       first column), so append result of both kinds of search instead of
;                       doing one or the other.
;                       Also, eliminate all comment lines first
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function list_printer_unix,desc,err=err

common list_printer_unix,printers_com,desc_com

printers=''
err=''
desc=''

if exist(printers_com) then begin
 printers=printers_com
 if exist(desc_com) then desc=desc_com
 return,printers
endif

printcap=['/etc/printcap', '/etc/printers.conf']           ;-- sorry Unix only
clook=loc_file(printcap,count=nf)  ;-- look for printer definition file
def_printers=[getenv("PRINTER"),getenv("PSLASER"), $
              getenv("PSCOLOR"),getenv("PSCOLOR2")]
def_desc=['PRINTER','PSLASER','PSCOLOR','PSCOLOR2']

if nf eq 0 then begin
 err='Cannot determine printers, trying PRINTER/PSLASER/PSCOLOR environmentals'
 message,err,/cont
 printers=def_printers
 desc = def_desc
 ix = where(printers  ne '',count)
 if count eq 0 then begin
  printers = ''
  desc = ''
 end else begin
  printers = printers(ix)
  desc = desc(ix)
 end
endif else begin

;-- read and parse printer definition file

 file=rd_ascii(clook(0))
 file=strnocomment(file, comment='#', /remove)
 vert=strpos(file,'|')
 colon=strpos(strtrim(file,1),':')
 ; if line has | but colon is first character then it's not a printer name line
 ok=where(vert gt -1 and colon ne 0,count)
 if count gt 0 then begin
  printers=strarr(count) & desc=printers
  temp=file(ok) & vert=vert(ok)
  for i=0,count-1 do begin
   tp=strmid(temp(i),0,vert(i))
   printers(i)=tp
   colon=strpos(temp(i),':')
   if colon gt -1 then begin
    sub= string(reverse(byte(strmid(temp(i),0,colon))))
    vert2=strpos(sub,'|')
    if vert2 gt 0 then begin
     sub2=string(reverse(byte(strmid(sub,0,vert2))))
     desc(i)=sub2
    endif
   endif
  endfor
 endif

 ;always do the following, not as an else to the above if, because some
 ;printcap files might have names both with | and without |.  So here, don't
 ;redo the ones we did above (want vert eq -1).  Append new list to old list. - kim

 vert=strpos(file,'|')
 colon=strpos(strtrim(file,1),':')
 ; printer name lines have colon, but not in first character
 ok = where (vert eq -1 and colon gt 0, count)
 if count gt 0 then begin
  more_printers = strmids(strtrim(file(ok),1), 0, colon(ok))
  if printers[0] eq '' then begin
  	printers = more_printers
  	desc = more_printers
  endif else begin
  	printers = [printers,more_printers]
  	desc = [desc, more_printers]
  endelse
 endif


 desc=strtrim(desc,2)
 printers=strtrim(printers,2)
 for i=0,n_elements(def_printers)-1 do begin
  chk=where(strupcase(def_printers(i)) eq strupcase(printers),cnt)
  if cnt gt 0 then begin
   desc(chk(0))=desc(chk(0))+' ('+def_desc(i)+')'
  endif
 endfor
endelse

if printers(0) ne '' then begin
 printers_com=printers
 desc_com=desc
endif

return,printers
end



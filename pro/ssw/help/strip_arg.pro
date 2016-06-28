;+
; Name        : STRIP_ARG
;
; Purpose     : Strip argument and keyword calls from an IDL program.
;
; Explanation : 
;
; Syntax:     : strip_arg,proc
;
; Inputs      : PROC = string array with text of program.
;
; Outputs     : QUIET = inhibit printing
;
; Keywords    : OUT = list of procedure/function calls
;
; Category    : Documentation, Online_help.
;
; History     : Written, Dominic Zarro, ARC, 10 October 1994.
;               Modified, Zarro (SM&A/GSFC), 8 Oct 1999
;                -- fixed bug with $ continuations  
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU 
;-

pro strip_arg,proc,output,quiet=quiet

on_error,1           

if datatype(proc) ne 'STR' then begin
 message,'input must be string array',/cont
 return
endif

;-- read source code and search for call line identified by PRO or FUNCTION

valid=0 & nlines=n_elements(proc)
loud=1-keyword_set(quiet)

;-- strip off comment lines and blanks

tproc=strtrim(proc,2)
ok=where( (tproc ne '') and (strpos(tproc,';') ne 0),nlines)
if nlines gt 0 then begin
 tproc=tproc(ok)
 for i=0,nlines-1 do begin
  line=strcompress(tproc(i))
  procd=strpos(strupcase(line),'PRO ')
  func=strpos(strupcase(line),'FUNCTION ')
  pfound=((procd eq 0) or (func eq 0))
  if pfound then begin  
   valid=1
   semi=strpos(line,';')
   if semi gt 0 then line=strmid(line,0,semi)
   if loud then print,'---> Call: ',line
   out=line
   repeat begin
    doll=strpos(line,'$')
    contin=(doll gt -1) 
    if contin then begin
     i=i+1
     line=tproc(i)
     semi=strpos(line,';')
     if semi gt 0 then line=strmid(line,0,semi)
     if loud then print,line
     out=out+' '+line 
     out=str_replace(out,'$','')    
    endif
   endrep until not contin
   sum=append_arr(sum,out)
  endif
 endfor
endif

if exist(sum) then output=sum else output=''

if not valid then message,'not a procedure/function',/continue,/noname

return & end



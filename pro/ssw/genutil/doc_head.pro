pro doc_head, source, header, definition
;
;+
;   Name: doc_head
;
;   Purpose: return idl documentation header from source file
;
;   Input Paramters:
;      source - file name containing idl source code and header
;      
;   Output Paramters:
;      header - all text between  ;+ and ;-
;      definition - procedure/function definition
;
;   History: slf, 8-feb-1993
;   	     slf, 15-mar-1993	; add case check for definition
;	     slf, 25-Jan-1993   ; allow comments = ;-----------------
;            slf, 30-Mar-1994   ; case where 2 headers in one file, protect
;	     MDM,  8-Mar-1995	; Fixed problem case
;            slf,  9-mar-1995   ; definition termination criteria
;-
header=''
definition=''

file=rd_tfile(source)		; generic text file reader

remtab,file,cfile			; remove tabs
cfile=(strtrim(cfile,2))		; remove blanks

; identify documentation header
hstart=where(strpos(file,';+') eq 0,startcnt)
hstop=where(strpos(file,';-') eq 0 and strmid(file,3,1) ne '-',stopcnt)

; pick off the function/procedure definition
pro_def  =wc_where(cfile,'pro *',/case_ignore,procnt)		; procedure?
if procnt eq 0 then $
  pro_def=wc_where(cfile,'function *',/case_ignore,procnt)	; function?

if procnt gt 0 then begin
   line=pro_def(0) > 0
;  look for first non-continuation line...
   nocont=where((strpos(cfile(line:*),'$')) ne (strlen(cfile(line:*))-1))
   term= nocont(0) + line 
   case 1 of 
     term eq line: definition=cfile(line) 
     term gt line: definition=cfile(line:term <(n_elements(cfile)-1) )
     else: definiton=""
   endcase
endif
; 
; header is everything between delimiters (if any)
if startcnt gt 0 and stopcnt ge  startcnt then $
	header=file(hstart(0):hstop(n_elements(hstop)-1) > hstart(0))	

return
end


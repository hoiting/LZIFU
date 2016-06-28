;+
; Project:    : SOHO-CDS
;
; Name        : STRIP_DOC
;
; Purpose     : Strip internal documentation from an IDL program.
;
; Explanation : 
;
; Syntax      : doc=strip_doc(array)
;
; Inputs      : 
;	        ARRAY = string array with text of program.
;
; Outputs     : 
;	        DOC = string array with documentation part.
;
; Keywords    : ERR = error string
;
; Category    : Documentation, Online_help.
;
; History     : Written, Dominic Zarro, ARC, 10 October 1994.
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU 
;-

function strip_doc,proc,err=err  ;-- strip documentation from procedure

on_error,1

err=''
tproc='No documentation found.'
if datatype(proc) ne 'STR' then begin
 err='Input must be string array'
 message,err,/cont
 return,tproc
endif

np=n_elements(proc)
begun=0 & done=0 & i=-1
repeat begin
 i=i+1 & line=proc(i)
 if not begun then begin
  begun = (strpos(line, ";+") ne -1)
 end else if (strpos(line,";-") ne -1) then begin
  begun = 0				; start again and look for more
 end else begin
  tproc=[tproc,line]
 endelse
endrep until (i eq np-1)		; search whole file
if n_elements(tproc) gt 1 then tproc=tproc(1:*) else err=tproc

return,tproc & end

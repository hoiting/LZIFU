;+
; Project     : SOHO - CDS     
;                   
; Name        : WAS_CALLED
;               
; Purpose     : check if procedure has been called in a heirarchy of calls
;               
; Category    : utility
;               
; Explanation : Useful to know if a procedure has been called somewhere
;               along the line before current application is reached.
;               
; Syntax      : IDL> status=was_called(name)
;    
; Examples    : 
;
; Inputs      : NAME = string procedure name to check
;               
; Opt. Inputs : None.
;               
; Outputs     : status = 1 if procedure was called
;
; Opt. Outputs: None.
;               
; Keywords    : None
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; History     : Version 1,  17-May-1997,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function was_called,name

;-- check inputs

status=0
if datatype(name) ne 'STR' then return,status
break_file,name,fdsk,fdir,fname
fname=strupcase(fname)
if fname eq '' then return,status

;-- now look for name in list of calls

help,calls=calls
apos=strpos(calls,'<')
ncalls=n_elements(calls)
for i=0,ncalls-1 do begin
 if apos(i) gt -1 then begin
  called=trim(strupcase(strmid(calls(i),0,apos(i))))
  status=called eq fname
  if status then return,status
 endif
endfor

return,status & end


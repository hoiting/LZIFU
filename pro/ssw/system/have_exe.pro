;+
; Project     : SOHO - CDS     
;                   
; Name        : HAVE_EXE
;               
; Purpose     : Check if an executable program exists
;               
; Category    : utility system
;               
; Syntax      : IDL> have=have_exe(name)
;
; Inputs      : NAME = program name
;               
; Outputs     : HAVE = 1/0 for have/have not
;               
; History     : Zarro (SM&A/GSFC), 20 April 2000
;
; Contact     : dzarro@solar.stanford.edu
;-            

function have_exe,name,out=out

out=''
if os_family(/lower) ne 'unix' then return,0b
if datatype(name) ne 'STR' then return,0b
espawn,'which '+name,out,/noshell
out=trim(out(0))
found=(strpos(strlowcase(out),'not found') eq -1) and (out ne '')
return,found

end

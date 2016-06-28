;+
; Project     : SOHO - CDS
;
; Name        : RSTRMID
;
; Purpose     : Reverse of STRMID
;
; Category    : Utility
;
; Explanation : 
;
; Syntax      : IDL> new=rstrmid(input,start,length)
;
; Inputs      : INPUT = input string
;               START = start character (starting from end)
;               LENGTH = characters to strip
;
; Opt. Inputs : START is optional. If not entered, last character is used
;
; Outputs     : OUTPUT = new string array

; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  25-May-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function rstrmid,input,start,length

if datatype(input) ne 'STR' then begin
 pr_syntax,'output=rstrmid(input,length)'
 if exist(input) then return,input else return,''
endif

clength=0 & cstart=0
if n_params() eq 2 then begin
 cstart=0
 if exist(start) then clength=start else clength=0
endif

if n_params() gt 2 then begin
 if exist(start) then cstart=start else cstart=0
 if exist(length) then clength=length else clength=0
endif

if (clength eq 0) then return,input
np=n_elements(input)
output=strarr(np)
for i=0,np-1 do begin
 temp=string(reverse(byte(input(i))))
 temp=strmid(temp,cstart,clength)
 output(i)=string(reverse(byte(temp)))
endfor

if np eq 1 then output=output(0)
return,output & end

;+
; Project     : SOHO - CDS
;
; Name        : REM_SEQ
;
; Purpose     : remove runs of sequential array elements to a single value
;
; Category    : Utility
;
; Explanation : None
;
; Syntax      : IDL> new = rem_seq(array,value)
;
; Inputs      : ARRAY = array of values to check
;               VALUE = value to remove
;               (e.g. entering a value of 4 reduces a sequence of -4,-4,-4 
;                to -4)
;               If value not entered then all sequential elements will be
;               reduced
;
; Opt. Inputs : None
;
; Outputs     : Reduced array
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: Input should be an array
;
; Side effects: None
;
; History     : Version 1,  29-July-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function rem_seq,array,value

;-- check inputs

if not exist(array) then return,-1
if not exist(value) then begin
 return,array(uniq([array]))
endif

vtype=datatype(value)
atype=datatype(array)
if ((atype eq 'STR') or (vtype eq 'STR')) and (atype ne vtype) then $
 return,array

clook=where(value eq array,count)
if count eq 0 then return,array

;-- now search for sequential value runs

np=n_elements(array)
b=intarr(np)
for i=0,np-2 do begin
 if (array(i) eq value) and (array(i) eq array(i+1)) then b(i+1)=1
endfor

ok=where(b eq 0,count)
if count eq 0 then return,array else return,array(ok)

end



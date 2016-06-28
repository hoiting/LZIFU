;+
; Project     : SOHO - CDS
;
; Name        : STR_SPACE
;
; Purpose     : Break up a string array with spaces between elements 
;               into an array of separate pieces without spaces.
;
; Category    : Utility
;
; Explanation : 
;
; Syntax      : IDL> new=str_space(array)
;
; Inputs      : ARRAY = array to break
;
; Opt. Inputs : None
;
; Outputs     : NEW = new string array

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
; History     : Version 1,  25-May-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function str_space,array

if datatype(array) ne 'STR' then begin
 message,'syntax --> new=str_space(array)',/cont
 if exist(array) then return,array else return,''
endif

delvarx,buff
np=n_elements(array)
blank_space=where(trim(array) eq '',count)
for i=0,count-1 do begin
 if i eq 0 then istart=0 else istart=blank_space(i-1)
 iend=blank_space(i)
 iend = iend < (np-1)
 if istart lt iend then begin
  temp=array(istart:iend)
  ok=where(trim(temp) ne '',bcount)
  if bcount gt 0 then boost_array,buff,temp
 endif
endfor

;-- get last one

if iend lt (np-1) then begin
 temp=array(iend+1:np-1)
 ok=where(trim(temp) ne '',bcount)
 if bcount gt 0 then boost_array,buff,temp
endif

if not exist(buff) then buff=array
return,buff
end


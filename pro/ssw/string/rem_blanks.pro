;+
; Project     : HESSI
;
; Name        : rem_blanks
;
; Purpose     : remove blank elements from string array
;
; Category    : string utility 
;
; Syntax      : IDL> out=rem_blanks(array)
;
; Inputs      : ARRAY = array to process
;
; Outputs     : OUT = processed array
;
; Keywords    : COUNT = # of non-blanks
;
; History     : Written 20 June 2000, D. Zarro (EIT/GSFC)
;               Modified 27 Dec 2005, Zarro (L-3Com/GSFC) - added COUNT
;
; Contact     : dzarro@solar.stanford.edu
;-

function rem_blanks,array,count=count

count=0
if not exist(array) then return,''
if (1-is_string(array)) then return,array

ok=where(strtrim(array,2) ne '',count)
if count gt 0 then return,array[ok] else return,''

end

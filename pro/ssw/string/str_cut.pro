;+
; Project     : HESSI     
;                   
; Name        : str_cut
;               
; Purpose     : cut string to max size, appending "..."
;               e.g, str_cut('testing',4) -> 'test...'
;               
; Category    : string utility
;               
; Syntax      : IDL> spos=str_cut(in,max)
;
; Inputs      : IN = input string 
;               MAX = max size or string
;               
; Outputs     : cut string
;
; History     : 5-May-2000,  D M Zarro (SM&A/GSFC)  Written
;     
; Contact     : dzarro@solar.stanford.edu
;-

function str_cut,in,max,pad=pad

if not exist(in) then return,''
if not is_number(max) then return,in
if is_blank(in) then return,in

ms=(max-2) > 1
copy=strmid(strtrim(in,2),0,ms)
stripped=where(strlen(strtrim(in,2)) gt ms,count)
if count gt 0 then copy[stripped]=copy[stripped]+'..'

if is_number(pad) then begin
 copy=strpad(copy,pad,/after,/no_copy)
endif
return,copy
end

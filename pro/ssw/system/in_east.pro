;+
; Project     : HESSI     
;                   
; Name        : IN_EAST
;               
; Purpose     : check if east of Royal Greenwich Observatory, UK
;               
; Category    : time utility
;               
; Syntax      : IDL> print,in_east()
;
; Inputs      : None
;               
; Outputs     : 1/0 if east or west of Royal Greenwich Observatory in UK
;               
; Keywords    : None
;               
; History     : 6-Nov-2002, Zarro (EER/GSFC)  Written
;     
; Contact     : dzarro@solar.stanford.edu
;-

function in_east

;-- compute hours difference between local and UT. If negative, we are
;   east of Greenwich

diff=(systime(/julian,/sec)-systime(/julian,/utc))*24.

return, diff lt 0.
end

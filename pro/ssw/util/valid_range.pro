;+
; Project     : HESSI
;
; Name        : VALID_RANGE
;
; Purpose     : determine if input range is non-zero 2-element vector
;
; Category    : utility
;
; Syntax      : IDL> valid=valid_range(range)
;
; Inputs      : RANGE: 2-element vector (e.g. [10,20]
;
; Input Keywords:  /ALLOW_ZEROS - if set, [0.,0.] or ['',''] is a valid range
;                  /TIME - if set, check that both inputs are valid times
;
; Output Keyword: ZEROS - 1 if range is [0.,0] or ['','']
;
; Outputs     : VALID = 1/0 if valid/invalid
;
; History     : 12-July-2000,  D M Zarro (EIT/GSFC)  Written
;               13-Nov-2000 Kim Tolbert - added all_zeros keyword
;               6-Sept-2001, Zarro (EITI/GSFC) - allow string input
;               14-Jan-2004, Zarro (L-3Com/GSFC) - allow range input
;               with equal min/max 
;               29-Jan-2004, Zarro (L-3Com/GSFC) - added /TIME
;
; Contact     : dzarro@solar.stanford.edu
;-

function valid_range,range, allow_zeros=allow_zeros,zeros=zeros,time=time

zeros=0b
if n_elements(range) ne 2 then return,0b

rmax=max(range,min=rmin)

if size(range,/tname) eq 'STRING' then begin
 arg=''
 rmin=strtrim(rmin,2) & rmax=strtrim(rmax,2)
endif else arg=0.

allow_zeros=keyword_set(allow_zeros)
zeros=(rmax eq arg) and (rmin eq arg)

if zeros or (rmax eq rmin) then return,allow_zeros

if keyword_set(time) then begin
 chk=valid_time(range)
 return, (chk[0] eq 1b) and (chk[1] eq 1b)
endif

return,1b
end


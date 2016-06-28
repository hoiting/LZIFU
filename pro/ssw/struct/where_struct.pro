;+
; Project     : SOHO - CDS
;
; Name        : WHERE_STRUCT
;
; Purpose     : WHERE function for structures
;
; Category    : Utility
;
; Explanation :
;
; Syntax      : IDL> ok=where(entry,struct,count)
;
; Inputs      : ENTRY = scalar structure to search for
;               STRUCT = array of structures to search in
;
; Opt. Inputs : None
;
; Outputs     : subscripts of elements in STRUCT that match ENTRY
;
; Opt. Outputs: COUNT = # of matches found
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: Inputs must be structures 
;
; Side effects: None
;
; History     : Version 1,  25-Dec-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function where_struct,entry,struct,count

count=0
if (datatype(struct) ne 'STC') or (datatype(entry) ne 'STC') then return,-1l

if n_elements(entry) ne 1 then begin
 message,'search entry must be single element',/cont
 return,-1l
endif

if not match_struct(entry,struct,/tags) then return,-1l

np=n_elements(struct)
chk=lonarr(np)
for i=0,np-1 do chk(i)=match_struct(entry,struct(i))
clook=where(chk gt 0,count)
return,clook

end

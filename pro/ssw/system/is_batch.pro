;+
; Project     : HESSI
;
; Name        : IS_BATCH
;
; Purpose     : return 1/0 if in batch mode or not
;
; Category    : System
;
; Syntax      : IDL> batch=is_batch()
;
; Inputs      : None
;
; Keywords    : None
;
; Outputs     : 1/0 if in batch mode or not
;
; History     : 24-March-2000, Zarro (SM&A/GSFC) - written
;               24-Feb-2002, Zarro (EITI/GSFC) - added check for FSTAT.interactive
;                9-Jan-2006, Zarro (L-3Com/GSFC) - fixed use of fstat()
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function is_batch

chk=fstat(-1)
if have_tag(chk,'interactive') then return,1-chk.interactive

if os_family(/lower) ne 'unix' then return,0b

spawn,'tty',out,count=count,/noshell

return,(trim(out[0]) eq 'not a tty') or (count eq 0) 

end

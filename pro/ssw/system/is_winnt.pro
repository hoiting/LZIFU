;+
; Project     : HESSI
;
; Name        : is_winnt
;
; Purpose     : check if current Windows OS is NT
;
; Category    : windows system
;
; Syntax      : IDL> i=is_winnt()
;
; Inputs      : None
;
; Outputs     : 1/0 if is or isn't
;
; History     : Written 20 June 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_winnt

if os_family(/lower) ne 'windows' then return,0b

;-- check if WINNT system directory is somewhere in path

espawn,'path',out

chk=str_match(out,'winnt',count=count)
return,count ne 0

end

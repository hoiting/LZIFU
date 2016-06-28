;+
; Project     : SOHO - CDS
;
; Name        : GET_TEMP_FILE
;
; Purpose     : Create a temporary filename in a writeable directory
;
; Category    : Utility
;
; Syntax      : IDL> file=get_temp_file()
;
; Inputs      : FILE = file name [def='temp.dat']
;
; Outputs     : NAME = file name with added path
;
; Keywords    : RANDOM - prepend a random set of digits to force uniqueness
;
; History     : 13 Nov 2005, Zarro (L-3Com/GSFC) - Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_temp_file,file,_ref_extra=extra

return,mk_temp_file(file,direc=get_temp_dir(_extra=extra),_extra=extra,/random)
     
end


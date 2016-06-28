;+
; NAME:
;	get_path_delim
; PURPOSE:
;	returns IDL !path delimiter that is appropriate to OS
; CALLING SEQUENCE:
;	delim=get_path_delim()
; INPUTS:
;	none
; OUTPUTS:
;       DELIM = delimiter string
; PROCEDURE:
;	checks !version.os system variable
; MODIFICATION HISTORY:
;       Written 25 May 1999, Zarro (SM&A/GSFC)

function get_path_delim,dummy

os=os_family(/lower)

case os of
 'vms'    : delim=','
 'windows': delim=';'
 else     : delim=':'
endcase

return,delim & end

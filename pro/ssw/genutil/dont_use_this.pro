pro dont_use_this, other, this, extra
;
;+
;NAME:
;	dont_use_this
;PURPOSE:
;	To print a message to the screen asking that the routine not be
;	used and optionally lists the name of the routine that should be
;	used
;CALLING SEQUENCE:
;	dont_use_this, 'YODAT'
;	dont_use_this, 'GET_RB0P', 'SUN_R', 'Sample calling sequence: r = get_rb0p(times)'
;OPTIONAL INPUT:
;	other	- The name of the other routine to use (new routine)
;	this	- The name of the routine not be used (Old routine)
;	extra	- Extra string array information to print
;HISTORY:
;	Written 22-Feb-93 by M.Morrison
;	18-Jul-93 (MDM) - Added THIS and EXTRA inputs
;-
;
str1 = ''
if (n_elements(this) ne 0) then str1 = ' ('+this+') '
print, ' '
tbeep, 5
print, '***********************************************************************'
print, '***********************************************************************'
print, '            THIS ROUTINE', str1, 'SHOULD NOT BE USED ANYMORE
if (n_elements(other) ne 0) then print, '                 PLEASE USE ', other, ' INSTEAD'
if (n_elements(extra) ne 0) then begin
    print, ' '
    prstr, extra
    print, ' '
end
print, '***********************************************************************'
print, '***********************************************************************'
print, ' '
;
end

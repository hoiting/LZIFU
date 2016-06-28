;+
; Name: hsi_get_debug
;
; Project: HESSI
;
; Purpose: Return the current debug level from SSW_FRAMEWORK_DEBUG or
;          from the DEBUG env. var
;
; Calling sequence:  debug = get_debug()
;
; Written: Kim Tolbert 23-Oct-2002
; Modifications:
;          2003-11-29 changed from hsi_get_debug to get_debug and adds
;          a test for the debug env. var (used by dmz)
;-
;---------------------------------------------------------------------------

function get_debug

framework_debug = fix (getenv('SSW_FRAMEWORK_DEBUG') )
dmz_debug =   fix (getenv('DEBUG') )

return,  max( [framework_debug,  dmz_debug] )

end

pro clear_screen, dummy
;+
; NAME:
;	CLEAR_SCREEN
; PURPOSE:
;	Writes escape sequence to clear screen and set cursor to top left corner
; CALLING SEQUENCE:  
;	clear_screen
; INPUTS:
;	none
; OUTPUTS:
;	none
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;	RDB  17-Feb-94	Written
;-

;	define escape sequence and print
code=bytarr(8)
code(0) = 27 	;<esc>
code(1) = 91 	;[
code(2) = 59	;;
code(3) = 72	;H
code(4) = 27 	;<esc>
code(5) = 91 	;[
code(6) = 50	;2
code(7) = 74	;J
print,string(code)

return
end


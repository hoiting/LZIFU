;+
; Project     : SOHO - CDS
;
; Name        : SAME_DATA2()
;
; Purpose     : Check if two variables are identical.
;
; Explanation : Checks if the values contained in the 2 inputs are the same.
;               Works on any type of data input. This is called by same_data for
;               IDL versions 5.4 and greater because it's much faster.
;
; Use         : IDL> if same_data2(a,b) then print,'a and b are identical'
;
; Inputs      : a  -  first input
;               b  -  second input
;
; Opt. Inputs : None
;
; Outputs     : Function returns 1 for identity, 0 otherwise.
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Calls       : MATCH_STRUCT
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; Category    : Util, numerical
;
; Prev. Hist. : None
;
; Written     : Andre Csillaghy, Dominic Zarro 2005
;
; Modified    : This version replaces the online version 3-Nov-2005.  Eliminates a lot
;               of checking and relies on catch to trap some cases.  Much faster.
;               16-nov-2005, Andre.  Removed check for error_code eq -203. The number
;                   changed in newer versions of IDL, plus not necessary anyway.
;
;-

pro same_data2_test

t = systime( /sec ) & for i=0l, 100000l do a = same_data2( 1,1 ) & print, systime( /sec ) - t
t = systime( /sec ) & for i=0l, 100000l do a = same_data ( 1,1 ) & print, systime( /sec ) - t

ff = {a:0, b:1}
t = systime( /sec ) & for i=0l, 100000l do a = same_data2( ff,ff ) & print, systime( /sec ) - t
;       22.001926
t = systime( /sec ) & for i=0l, 100000l do a = same_data( ff,ff ) & print, systime( /sec ) - t
;       24.342722
help, same_data2( {a:0, b:1}, 1 )

help, same_data2( {a:0, b:1}, 1 )

help, same_data2( {a:0, b:1}, 1 )
help, same_data2( {a:0, b:1}, {a:0, b:1} )
help, same_data2( {a:0, b:1}, {a:0, b:2} )
help, same_data2( {a:0, b:1}, ptr_new() )
help, same_data2( ptr_new(), ptr_new() )
help, same_data2( ptr_new(1), ptr_new(1) )
a = ptr_new(1) & help, same_data2(a,a)
help, same_data2( {a:findgen(10), b:1}, {a:findgen(10), b:2} )
help, same_data2( {a:findgen(10), b:1}, {a:findgen(10), b:1} )
t = systime( /sec ) & for i=0l, 100000l do a = same_data2( ff,ff ) & print, systime( /sec ) - t
;       23.386349

end

;--------------------------------------------------------------------------------

function same_data2, a, b, notype_check = notype_check

error_code = 0b
catch, error_code
if error_code ne 0 then begin

    catch, /cancel

    sizea = size( a, /struct )
    sizeb = size( b, /struct )

; struct expression not allowed
; ACS 20051103 that might not be needed, as we check anyway time in
; sizea and sizeb.
;    if error_code eq -203 then begin

        if sizea.type eq 8 and sizeb.type eq 8 then begin
            return, match_struct(a,b)
        endif

;    endif ;else stop

    return, 0

endif

nelsa = N_elements( a )
nelsb = n_elements( b )

if nelsa ne nelsb then return, 0b

if not keyword_set( notype_check ) then begin
    if size( a, /type ) ne size( b, /type ) then return, 0B
endif

ret = array_equal( a, b )

catch, /cancel

return, ret

end

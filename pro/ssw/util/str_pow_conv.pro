;+
; Name: str_pow_conv
;
; Category: HESSI, UTIL
;
; Purpose: Convert a units string with exponentials [ to/from ] [ IDL plot
; 	control format / FITS format ].  A units string of 'keV cm**(-2)' becomes
; 	'keV cm!U-2!N', or vice versa.
;
; Calling sequence:  new_units_string = str_pow_conv( input, 'FITS' )
;
; Inputs:
; 	input - string to be converted
;
; Input keywords:
; 	IDL_PLOT - set if converting from FITS style string to IDL plot unit string
; 	FITS - set if converting from IDL plot style string to FITS unit string
; Output keywords:
; 	ERR_MSG = error message.  Null if no error occurred.
; 	ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
;	arr2str, str2arr, str_chunk
;
; Restrictions:
; 	Components of the units string must be separated by spaces.  If a units string
; 	of the form 'counts cm**(-2)keV**(-1)s**(-1)' is passed, only the first
; 	occurrence of the control characters will be converted, and even that may
; 	not be converted properly.
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;-
;-------------------------------------------------------------------------------
FUNCTION str_pow_conv, input, IDL_PLOT=idl_plot, FITS=fits, ERR_MSG=err_msg, $
	ERR_CODE=err_code

err_msg = ''
err_code = 1

CATCH, err
IF err NE 0 THEN BEGIN
	err_msg = !err_string
	RETURN, ''
ENDIF

do_fits = Keyword_Set( fits )
do_fits = 1 - Keyword_Set( idl_plot )

; remove all spaces from the string
arr = str2arr( input, ' ')

; Remove any null strings from arr
nonnull = Where( arr NE '', n_nonnull )
IF n_nonnull GT 0L THEN arr = arr[ nonnull ]

IF do_fits THEN BEGIN
	FOR i=0L, N_Elements( arr ) -1L DO BEGIN
		s = Strpos( Strupcase( arr[ i ] ), '!U' )
		e = Strpos( Strupcase( arr[ i ] ), '!N' )
		IF s GT -1L THEN BEGIN
			pow = '**(' +Strmid( arr[ i ], s+2L, e-s-2L ) + ')'
			arr[ i ] = Strmid( arr[ i ], 0L, s ) +  pow + $
				Strmid( arr[ i ], e+2L, Strlen( arr[ i ] ) - e -2L )
		ENDIF
	ENDFOR
ENDIF ELSE BEGIN
	FOR i=0L, N_Elements( arr ) -1L DO BEGIN
		s = Strpos( arr[ i ], '**' )
		IF s GT -1L THEN BEGIN
			rem = strmid( arr[ i ], s+2L, Strlen(arr[i])-s-2L )
			tmp = str_chunk( rem, 1 )
			op = Where( tmp EQ '(', nop )
			cp = Where( tmp EQ ')', ncp )
			IF ncp EQ nop AND ncp GT 0L THEN BEGIN
				; remove the first '(' and the last ')'
				pow_s = op[0]+1L
				pow_e = cp[ncp-1L]-1L
				pow = arr2str( tmp[pow_s:pow_e], '' )
				rem = cp[ncp-1L]+1L GE N_Elements(tmp) ? '' : $
					arr2str( tmp[cp[ncp-1L]+1L:*] )
			ENDIF ELSE BEGIN
				pow = rem
				rem = ''
			ENDELSE
			arr [ i ] = Strmid( arr[ i ], 0L, s ) + '!U' + pow + '!N' + rem
		ENDIF
	ENDFOR
ENDELSE

output = arr2str( arr, ' ' )

err_code = 0

RETURN, output

END
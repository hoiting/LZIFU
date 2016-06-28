;+
; NAME:
;	WR_ASC
; PURPOSE:
;	To write arrays into columns of ASCII numbers
; CATEGORY:
;	I/O
; CALLING SEQUENCE:
;	WR_ASC, append=APPEND, F,H,X0,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11
; INPUTS:
;	F = If it is a string, interpreted as output file name
;	H = If it is a string, interpreted as header
;	X'i = i'th vector input
; RESTRICTIONS:
;	Limited to 10 input vectors. Cannot handle 3-D vectors
; PROCEDURE:
;	Use array concatenation
; MODIFICATION HISTORY:
;	Written DMZ (ARC), July 1990
;	Converted to version 2, Paul Hick (ARC), Feb 1991
;-

pro WR_ASC, append=APPEND, F,H,X0,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,$
            eflag=eflag

on_error,1

ok=test_open(/write)
eflag= (ok ne 1)
if not ok then return

NPAR = n_params()
if NPAR eq  0 then message, 'Insufficient command line parameters' else $
if NPAR gt 14 then message, 'Excessive command line parameters'

; Check if first parameter is filename (if not then prompt for file name)
S = size(F)
if S(n_elements(S)-2) ne 7 then begin
    repeat begin FILE = '' & read, '* enter file name for output : ', FILE  &  endrep until FILE ne ''
endif else FILE = F

; Check if second parameter is a string header (if not then leave it blank)
S = size(H)
if S(n_elements(S)-2) ne 7 then HEADER = '       ' else HEADER = H

; Cycle thru each parameter and determine user inputs. Concatenate all data that are not of string type
for I=0,NPAR-1 do begin
    X = "EMPTY"
    case I of
    0: if n_elements(F) ne 0 then X = F
    1: if n_elements(H) ne 0 then X = H
    2: if n_elements(X0) ne 0 then X = X0
    3: if n_elements(X1) ne 0 then X = X1
    4: if n_elements(X2) ne 0 then X = X2
    5: if n_elements(X3) ne 0 then X = X3
    6: if n_elements(X4) ne 0 then X = X4
    7: if n_elements(X5) ne 0 then X = X5
    8: if n_elements(X6) ne 0 then X = X6
    9: if n_elements(X7) ne 0 then X = X7
    10: if n_elements(X8) ne 0 then X = X8
    11: if n_elements(X9) ne 0 then X = X9
    12: if n_elements(X10) ne 0 then X = X10
    13: if n_elements(X11) ne 0 then X = X11
    else: message, 'Data problems ...'
    endcase
    S = size(X)
    if S(n_elements(S)-2) ne 7 then begin			; If not a string
	if S(0) lt 3 then boost_array, DATA, X else message, 'Cannot handle dimensions greater than 2', /info
    endif
endfor

S = size(DATA)
case S(0) of
1: begin NROWS = S(1)  &  NCOLS = 1  &  end
2: begin NROWS = S(1)  &  NCOLS = S(2)  &  end
else: message, 'No data available'
endcase

if not keyword_set(APPEND) then begin
    openw, LUN, /get_lun, FILE		;-- open file
    OP = 'written'
endif else begin
    openu, LUN, /get_lun, /append, FILE
    OP = 'appended'
endelse

message,'writing ASCII data to '+file,/cont

printf, LUN, HEADER
printf, LUN, NROWS, NCOLS
printf, LUN, transpose(DATA)
free_lun, LUN
message, string(NROWS,'(I4)')+' rows and '+string(NCOLS,'(I3)')+' columns '+  $
	OP+' to file '+strupcase(FILE), /info

return & end

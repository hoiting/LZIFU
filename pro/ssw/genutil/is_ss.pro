;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;     IS_SS determines whether a file is a valid IDL save set
;
;DESCRIPTION:  
;     IS_SS attempts to open FILENAME and read the first two bytes.
;     IDL save sets have the first two bytes set to 83 and 84 so we 
;     check the values of these bytes and return a 1 if the test is
;     positivie and a 0 if either one is negative.
;
;CALLING SEQUENCE:  
;     RESULT = IS_SS(filename)
;
;ARGUMENTS (I = input, O = output, [] = optional):
;     RESULT        O   int        Return value = 1 if FILENAME is 
;                                  determined to be an IDL save set
;                                  and 0 if it is not.
;     FILENAME      I   str        Name of file to be checked        
;
;WARNINGS:
;	This algorithm is based on the first two bytes of the save
;	set record begin equal to 83 and 82.  It has been observed
;	that IDL save sets start with these bytes.  Invalid results
;	will occur if  RSI changes this convention (possible) or if
;	a non-IDL save set starts with 83 82 (also possible).
;
;EXAMPLE:
;	To determine if 'file' is a valid IDL save set use:
;
;	   status = is_ss('file')
;
;	Status = 1 if it is a save set and 0 if it is not.
;#
;COMMON BLOCKS:
;     None
;
;PROCEDURE (AND OTHER PROGRAMMING NOTES): 
;
;PERTINENT ALGORITHMS, LIBRARY CALLS, ETC.:
;     None
;  
;MODIFICATION HISTORY:
;     Written by Dave Bazell,  General Sciences Corp. 4 Feb 1993 spr 10463
;
;.TITLE
; Routine IS_SS
;-
function is_ss, filename

on_error, 2
;
x=bytarr(2)
val = 0b

; Open the input files
on_ioerror, return_status
openr, unit, filename, /get_lun

;Read the first two bytes in the file
readu, unit, x

; Check if the byte values are 83 and 82 respectively.  If 
; this is true then set the return value to 1, file is a save
; set otherwise set return to 0, file is not a save set.

val = ((x(0) eq 83) and (x(1) eq 82))

return_status:
; Close file and return
    if n_elements(unit) gt 0 then begin
        close, unit
        free_lun, unit
    endif

    return, val
 
end

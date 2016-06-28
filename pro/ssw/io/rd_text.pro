;+
;
;  Name:
;       RD_TEXT
;
;
; PURPOSE:   read an ascii file into an IDL session
;
;
; CATEGORY:  GEN, STRING, TEXT, I/O
;       
;
; CALLING SEQUENCE:    text = rd_text( file )
;
;
; CALLED BY:
;
;
; CALLS:
;	READ_SEQFILE
;
; INPUTS:
;       file - scalar string, full filename
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       The result is text array with the file contents.
;
; OPTIONAL OUTPUTS:
;	ERROR - set if there was a problem.
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Tries to use RD_ASCII. If that fails it reads 10 lines at a 
;	time until an ioerror occurs.
;
; MODIFICATION HISTORY:
;	ras, use read_seqfile to protect against rd_ascii problems
;	with exported vms disks, 4-dec-1996 
;-
function rd_text, file, error=error

read_seqfile, lines, file, error=error

return, lines
end

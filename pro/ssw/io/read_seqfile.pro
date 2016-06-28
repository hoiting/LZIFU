;+
;
;  Name:
;       READ_SEQFILE
;
;
; PURPOSE:   read an ascii file into an IDL session
;
;
; CATEGORY:  i/o
;       BATSE
;
; CALLING SEQUENCE:    read_seqfile, lines, file
;
;
; CALLED BY:
;
;
; CALLS:
;	RD_ASCII
;
; INPUTS:
;       file - scalar string, full filename
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       lines - text array with file contents
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
;	Tries to use RD_ASCII. If that fails it reads 10 lines at a time until an ioerror occurs.
;
; MODIFICATION HISTORY:
;	akt, 1994
;   	ras, 9 May 1995, put in on_ioerror to fix some wierd osf bug
;	ras, use rd_ascii unless there is an error, 13 Sep 1996
;-


pro read_seqfile, lines, file, error=error

lines = ''
error=0

filefound = (findfile(file(0), count=count))(0)
if count eq 0 then begin
	error=1
	message,/continue, "Can't find "+file
        return
endif
test = execute( 'lines = rd_ascii(filefound, error=error)')
if not test or error then begin
 

line = ' '
lines = strarr(10)

openr, lun, filefound, /get_lun
fstat = fstat(lun)
irec = -1
on_ioerror, close_up_shop
while fstat.cur_ptr lt fstat.size do begin
   irec = irec + 1
   if (irec mod 10) eq 0 then lines = [lines,strarr(10)]
   readf, lun, line
   lines(irec) = line
   fstat = fstat(lun)
endwhile
close_up_shop:
on_ioerror, null

free_lun, lun
lines = lines(0:irec)
end
end

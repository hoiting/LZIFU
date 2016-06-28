pro wrt_ebc2asc, infil, outfil, recsizin, recsizout
;+							(11-nov-91)
;  NAME:
;       wrt_ebc2asc
;  PURPOSE:
;       Given an EBCDIC input file, create
;       an ASCII output file.  The input file must
;       have fixed record lengths.
;  INPUT:
;       infil   - The name of the input file
;       outfil  - The name of the output file
;       recsiz  - The number of characters per line
;  HISTORY:
;       Written Oct-91 by M.Morrison to convert the
;       Solar-A "AOSLOS" mainframe orbital prediction
;       files to ASCII (their records are 137 characters)
;	Updated, 18-Oct-91, J. Lemen to allow for independent input
;				and output record sizes.
;	Updated, 11-nov-91, J. Lemen:  Force output record size if the
;				output string contains null bytes.
;-
get_lun, lunin
get_lun, lunout

if n_elements(recsizout) eq 0 then recsizout = recsizin
;
openr, lunin, infil
openw, lunout, outfil
;
while not eof(lunin) do begin
    barr = bytarr(recsizin)
    readu, lunin, barr				; Read an ebcdic string
    out_str = str_ebc2asc(barr,/str)		; Convert to ascii
    
; Force the output string to have the correct record length
; (If the input string contains nulls, then the length may be too short)

    if strlen(out_str) ne recsizout then 				$
	out_str = out_str + 						$
		string(replicate(32b,recsizout-strlen(out_str)))

    printf, lunout, out_str, format='(a)'
end
;
free_lun, lunin
free_lun, lunout
end

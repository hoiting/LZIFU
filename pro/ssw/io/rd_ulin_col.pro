function rd_ulin_col, infil, ncol, nocomment=nocomment, $
	strarray=strarray, noheader=noheader, $
	first_char_comm=first_char_comm
;+
;NAME:
;	rd_ulin_col
;PURPOSE:
;	Generic text file reader which has columns identified
;	in the second line by "------" string
;HISTORY:
;	Written 6-Oct-97 by M.Morrison
;	29-Oct-97 (MDM) - Corrected error (ncol=7 hardwired)
;			- Added /NOHEAD option
;	11-Feb-99 (MDM) - Added first_char_comm
;-
;
strarray = rd_tfile(infil, nocomment=nocomment, first_char_comm=first_char_comm)
remtab, strarray, strarray
def_lin = strarray(1)		;second line has the "----" strings
arr = str2arr( strcompress(def_lin), delim=' ')
if (n_elements(ncol) eq 0) then ncol = n_elements(arr)
temp = [def_lin, strarray]	;put it at the top for STR2COLS to work off
mat = str2cols(temp, ncol=ncol)   
mat = mat(*,1:*)		;remove the temp line
mat = strcompress(strtrim(mat,2))
if (keyword_set(noheader)) then mat = mat(*,2:*)
;
return, mat
end
;+
;
; NAME: 
;       CLEAN_JOURNAL
;
; PURPOSE:
;	This procedure removes some of the output in journal files to make
;	the resultant files more easily modified into procedures.
;
; CATEGORY:
;	UTIL, GEN, STRING
;
; CALLING SEQUENCE:
;	clean_journal, file, items=items
;
; CALLS:
;	none
;
; INPUTS:
;       File: The file to clean.
;
; OPTIONAL INPUTS:
;       ITEMS: An array of text strings.  The lines which begin with these strings are
;	eliminated.  The defaults are:
;	['print',';','retall','xmanager','wdelete','chkarg', $
;	'.',',','help','$']
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
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
;	none
;
; MODIFICATION HISTORY:
;	Version 1, RAS 5-June 1996
;	Version 2, RAS 4-dec-1996
;-
pro clean_journal, file, items=items

a = rd_text( file )

checkvar, items, ['print',';','retall','xmanager','wdelete','chkarg', $
	'.',',','help','$']
for i=0,n_elements(items)-1 do begin
	wprint = where( strpos(a,items(i)) ne 0, nprint)
	a = a(wprint)
endfor

openw,lu,/get,file

printf,lu, a, form='(a)'
free_lun,lu
end

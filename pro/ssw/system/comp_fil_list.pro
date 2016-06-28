pro comp_fil_list, source_list, ref_list=ref_list, files=ifiles, ofiles, status=status
; NAME:
;  comp_fil_list
; PURPOSE:
;  Compare two unix directory listings and produce a list of file names
;  which differ in some way (size, time of creation, ownership, protection).
;
; CALLING SEQUENCE:
;  comp_fil_list, source_list, ref_list=ref_list, ofiles, status=status
;  comp_fil_list, source_list, ref_list=ref_list, files=files, ofiles, status=status
;
;  If all cases if source_list match ref_list, then status = 0
;  Else, status = number of cases that DO NOT match.
;
; INPUTS:
;  source_list	- Unix type of directory listing made from ls -l .
; OPTIONAL INPUT KEYWORDS:
;  ref_list	- Unix type of directory listing made from ls -l .
;  files	- List of target files that should be checked (all other
;		  files in source_list are ignored).
; OUTPUTS:
;  ofiles	- List of files that differ (just the file name is returned).
;  status	- If in the range 0 to N, the number of files which differ.
;		 -1: No files in ifiles match the list in source_list
; METHOD:
;  It is assumed that source_list and ref_list are string arrays containg 
;  directory listings produced by an ls -l type of operation. Thus, the 
;  last column is assumed to the filename.
;
; HISTORY:
;   1-Feb-96, J. R. Lemen (LPARL), written.
;  28-Feb-96, JRL, Minor bug fix
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-

delvarx, ofiles			; Start with a clean slate
status = -1			; Ditto
if strlen(strtrim(source_list(0),2)) eq 0 then $
		message,'Error:  Null source string',/info

;----------------------------------------------------
; Step 1: Compare ref_list to source_list
;----------------------------------------------------

if n_elements(ref_list) gt 0 then begin
  new = rem_elem(source_list,ref_list, status) 
  if status eq 0 then return			; All cases match. Finished.
endif else begin
  ncount = n_elements(source_list)		; No ref_list supplied
  new = indgen(status)
endelse

; Extract file names from the listing:
source_files = ssw_strsplit(source_list(new),' ',/last,/tail)
ij = indgen(status)				; In case there is no ifiles

;----------------------------------------------------
; Step 2: Remove cases that don't match ifiles:
;----------------------------------------------------

if n_elements(ifiles) ne 0 then begin		; Filter the list

  ij = -1
  for i=0,n_elements(ifiles)-1 do ij = [ij,wc_where(source_files, ifiles(i))]
  k = where(ij ne -1, nc)

  if nc eq 0 then begin
     message,'List updated but none of the target files were updated',/info
     status = -1
     return
  endif else status = nc

  ij = ij(k)
endif

ofiles = source_files(ij)		; Return the filenames that don't match


end

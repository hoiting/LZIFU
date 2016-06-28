pro pr_path_lib, name, directory = direct, multi = multi, nopro = nopro, out=out
;+
; NAME:
;   pr_path_lib
; PURPOSE:
;   Print the path of a file in !path
;   Calls path_lib() to do the work.
; CALLING SEQUENCE:
;   pr_path_lib,'yodat'
;   pr_path_lib,'gt_*'
; INPUTS:
;   String containing search string
; OPTIONAL INPUT KEYWORDS:
;   nopro	= Set to search for non *.pro files
;   multi	= Multiple file search.  Default (unless name caontains
;		  a * (wildcard) is search until first match.  Setting
;		  multi will cause the search to continue through the
;		  entire tree.
;   directory	= directory to search.  If omitted, use the !path and
;		  current directories.
; OPTIONAL OUTPUT KEYWORDS:
;   out		= String vector of all cases found
; MODIFICATION HISTORY:
;   30-apr-93, J. R. Lemen, Written
;-

if n_elements(name) eq 0 then doc_library,'pr_path_lib' else 	$
out = path_lib(name,directory = direct, multi = multi, nopro = nopro)

if n_elements(out) eq 1 and strlen(strtrim(out(0),2)) eq 0 then $
	print,'-- No files found --' else begin
  i = 0
  ans = ''
  while i le n_elements(out)-1 do begin
    print,out(i)
    if (i+1) mod 20 eq 0 then begin
	print,' ' & print,'<Hit q to quit>',format='(30x,a,$)'
	ans = get_kbrd(1)		; Get a character
	print,' '
	if strlowcase(strmid(ans,0,1)) eq 'q' then i=n_elements(out)
    endif
    i = i + 1
  endwhile
endelse

end



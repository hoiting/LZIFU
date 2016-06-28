pro doc_library2, arg, files
;+
;NAME:
;	doc_library2
;PURPOSE:
;	To find a routine and to display the full contents of the file.
;	Search in the order of !path.  If a wildcard * is used, then
;	all matches in !path are found.
;SAMPLE CALLING SEQUENCE:
;	doc_library2, 'file_info2'
;	doc_library2, 'plot_*'
;INPUTS:
;	arg	- The input routine name to search for.
;OPTIONAL OUTPUT:
;	files	- The files found
;HISTORY:
;	Written 7-Mar-95 by M.Morrison
;-
;
if (n_elements(arg) eq 0) then begin
    print, 'DOC_LIBRARY2, routine_name
    return
end
;
files = path_lib(arg)
;
if (files(0) eq '') then begin
    print, 'No routines found for: ', arg
end else begin
    print, 'Files found:'
    prstr, '    ' + files
    print, '-------------------------------------------'
    ;
    more, rd_tfile(files(0))
    ;
    if (n_elements(files) gt 1) then begin
	qdone = 0
	ifil = 1
	while not qdone do begin
	    print, 'Do you wish to see ' + files(ifil)
	    input, '(Enter QUIT to exit DOC_LIBRARY2)', ans, 'No'
	    if (strupcase(strmid(ans,0,1)) eq 'Y') then more, rd_tfile(files(ifil))
	    ifil = ifil + 1
	    qdone = (ifil ge n_elements(files)) or (strupcase(strmid(ans,0,1)) eq 'Q')
	end
    end
end
;
end
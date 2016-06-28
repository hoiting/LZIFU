function str2pages, str, tit, page_tit, page_numbers=page_numbers, $
	nline=nlin
;+
;NAME:
;	str2pages
;PURPOSE:
;	To take a string array and to break it into page blocks
;SAMPLE CALLING SEQUENCE
;	out2 = str2pages(str, tit, page_tit, /page_numbers, nlin=35)
;INPUT:
;	str	- The 1-D string array
;OPTINAL INPUT:
;	tit	- A fixed set of lines to put at the top of each page
;	page_tit- A 2-D array of  Npages X NLinesOfHeaderof header
;		  information to prepend on each page (used when
;		  different header information is needed on each 
;		  page
;OPTIONAL KEYWORD INPUT:
;	page_numbers - Add a string "Page 1 of 30" type of string
;	nlin	- The number of non-title information per page
;		  (default is 40)
;HISTORY:
;	Written 24-Feb-98 by M.Morrison
;	11-Mar-98 (MDM) - Correction to handle where there is one page
;-

if (n_elements(nlin) eq 0) then nlin = 40.
;
out = str
n = n_elements(out)
nblocks = ceil(n / float(nlin))

npad = nblocks*nlin - n
if (npad ne 0) then out = [out, strarr(npad)]
out = reform(out, nlin, nblocks, /over)
out = rotate(out,1)
;
;---- Fixed title per page (work backwards from last line of title up)
;
if (keyword_set(tit)) then begin
    out = [[replicate(tit(0), nblocks)], [out]]
    out = [[strarr(nblocks)], [out]]
end
;
;---- Variable title per page
;
if (keyword_set(page_tit)) then begin
    if (n_elements(page_tit(*,0)) eq nblocks) then begin
	out = [[ rotate(page_tit,5)], [out]]
    end else begin
	print, 'STR2PAGES: The "page_tit" variable is not dimensioned correctly
	help, page_tit
	help, out, nblocks
    end
end
;
;---- Page Break and page number stuff
;
page_break = ''
if (nblocks gt 1) then page_break = [replicate(string(12b), nblocks-1), '']
if (keyword_set(page_numbers)) then page_break = page_break + 'Page ' + $
				strtrim(nblocks-indgen(nblocks),2) + ' of ' + strtrim(nblocks,2)
out = [[page_break], [out]]
;
out = rotate(out,3)
out = reform(out, n_elements(out), /over)

return, out
end
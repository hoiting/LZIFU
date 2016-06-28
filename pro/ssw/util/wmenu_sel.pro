function wmenu_sel, array, one=one, qstop=qstop
;
;+
;NAME:
;	wmenu_sel
;PURPOSE:
;	To allow a user to select a series of array elements
;	using the WMENU option.  Options exist to select many
;	elements.
;CALLING SEQUENCE:
;	subs = wmenu_sel(array)
;	subs = wmenu_sel(files, /one)
;INPUT:
;	array	- a string array of any length
;OPTIONAL INPUT KEYWORDS:
;	one	- if set, return after one element is selected
;OUTPUT:
;	Returns the indicies of the array elements selected
;HISTORY:
;	Written Dec '91 by M.Morrison
;	18-Mar-92 (MDM) - Added option to select all elements on
;			  the current page.
;			- Also added the keyword option "one"
;			- Also adjusted page size to look at the length
;			  of the string array
;	18-Mar-92 (MDM) - Added case statement to get screen size
;	 4-Aug-92 (MDM) - Added common block storage of number of lines and
;			  columns that are used for a given display.
;	 8-Apr-93 (MDM) - Added code to recognize when the display device
;			  is the NCD x-terminal.
;	23-apr-93 (JRL) - Moved the code that sets nchar and nlin to wmenu_sel_set
;	13-may-93 (SLF) - force scaler return if only one element 
;	25-Apr-94 (MDM) - Modified to print options to the screen if the device is
;			  not an X terminal.
;-
;
common wmenu_sel, nchar, nlin
;
ref = ['Quit/Exit', 'Previous Page', 'Next Page', 'All btwn last 2', 'All on Page', 'Reset']
nref = n_elements(ref)
;
nextra = 2 + 2			;WMENU puts 2 characters between each column + WMENU_SEL puts a marker in '*'
if (keyword_set(one)) then nextra = 2	;only WMENU extra characters
maxlen = max(strlen(array))
maxlen = max([maxlen, strlen(ref)])
;
if n_elements(nchar) eq 0 then wmenu_sel_set,/reset	; Reset to factory values
ncol = fix(nchar/(maxlen+nextra))	;210 characters can fit on DEC 5000 workstation
;
npp = fix(nlin*ncol-nref)		;# elements per page - TODO - system dependent
n = n_elements(array)
npage = fix(n / npp)
if ((n mod npp) ne 0) then npage = npage + 1
;
if (keyword_set(qstop)) then stop
;
sel = bytarr(n)
;
ago1 = -1
ago2 = -1
page = 0
repeat begin
    ref2 = ref
    if (page eq 0) then ref2(1) = ' '
    if (page eq npage-1) then ref2(2) = ' '
    ;
    if (keyword_set(one)) then ref2(3:nref-1) = ' '	;blank out "all btween last 2", "all on page" and "reset" options
    ;
    ist = page*npp
    ien = (ist+npp-1)<(n-1)
    nn = ien-ist+1
    blank = strarr(nn) + '  '
    ss = where(sel(ist:ien))
    if (ss(0) ne -1) then blank(ss) = '* '
    if (keyword_set(one)) then temp = [ref2, array(ist:ien)] else temp = [ref2, blank + array(ist:ien)]
    if (!d.name eq 'X') then begin		;MDM modified 25-Apr-94
	imenu = wmenu(temp)
    end else begin
	prstr, string(indgen(n_elements(temp)), format='(i4)') + ' === ' + temp, /nomore
	input, 'Enter the option number you desire', imenu, 0
    end
    ;
    case imenu of
	0: 
	1: page = (page-1)>0 
	2: page = (page+1)<(npage-1)
	3: begin
		if ((ago1 ne -1) and (ago2 ne -1)) then begin
		    sel(ago1<ago2:ago2>ago1) = 1
		end else begin
		    print, 'You must have selected the beginning and ending first'
		end
	    end
	4: sel(ist:ien) = 1
	5: sel = bytarr(n)
	else: begin
		item = (imenu - nref) + page*npp
		if (not sel(item)) then sel(item) = 1 $
				else sel(item) = 0		;reset
		ago2 = ago1
		ago1 = item
	      end
    endcase
    ;
    qdone = 0
    if (imenu eq 0) then qdone = 1
    if (keyword_set(one) and (imenu ge nref)) then qdone = 1
end until (qdone)
;
; slf, 13-may - force scaler if only one element 
retval=where(sel)
if n_elements(retval) eq 1 then retval=retval(0)	; make scaler
return, retval
end

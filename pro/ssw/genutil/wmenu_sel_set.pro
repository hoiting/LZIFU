pro wmenu_sel_set, nchar, nlin, reset=reset, get=get
;
;+
;NAME:
;	wmenu_sel_set
;PURPOSE:
;	To allow a user to manually set the number of characters and lines
;	are used in the WMENU_SEL routine
;CALLING SEQUENCE:
;      	wmenu_set_set,/reset		; Reset to values given below
;	wmenu_sel_set,nchar,nlin	; Set to nchar and nlin
;	wmenu_sel_set,nchar,nlin,/get	; Get current values
;INPUT:
;	nchar	- Number of characters
;	nlin	- Number of line
;EXAMPLES:
;				nchar		nlin
;	ULTRIX Workstations:	210		61
;	SUN Workstations	190		54
;	VMS Workstations (?)	170		50
;	X-Terminals (small ver)	132		46
;	X-Terminals (large ver)	150		43
;	X-Terminals (large ver)	124		43 (large font)
;	INDY			100		54
;HISTORY:
;	Written by M.Morrison 4-Aug-92
;	 8-Apr-93 (MDM) - Updated header information
;	21-apr-93 (JRL) - Added reset and get options
;	28-Jun-94 (MDM) - Added interactive setting option
;	11-Jan-95 (MDM) - Changed Xterminal nchar from 132 to 110
;	23-Jan-95 (MDM) - Added option to enter values manually
;	 8-Feb-95 (MDM) - Added INDY option
;			- Added some instructions/comments
;-
;
common wmenu_sel, nchar0, nlin0
;
if (n_params() eq 0) and (not keyword_set(reset)) then begin
    n = 7
    descr = strarr(n)
    nchar_arr = intarr(n)
    nlin_arr  = intarr(n)

    descr(0) = 'ULTRIX Workstations'			& nchar_arr(0) = 210	& nlin_arr(0) = 61
    descr(1) = 'SUN Workstations'			& nchar_arr(1) = 190	& nlin_arr(1) = 54
    descr(2) = 'VMS Workstations'			& nchar_arr(2) = 170	& nlin_arr(2) = 50
    descr(3) = 'X-Terminals (small ver)'		& nchar_arr(3) = 110	& nlin_arr(3) = 46
    descr(4) = 'X-Terminals (large ver)'		& nchar_arr(4) = 150	& nlin_arr(4) = 43
    descr(5) = 'X-Terminals (large ver/Large Font)'	& nchar_arr(5) = 124	& nlin_arr(5) = 43
    descr(6) = 'SGI INDY    '				& nchar_arr(6) = 100	& nlin_arr(6) = 54
    descr = strmid(descr+'                               ', 0, 40)
    menu = descr + '(' + strtrim(nchar_arr,2) + 'x' + strtrim(nlin_arr,2) + ')'
    menu = [menu, 'Enter two values by hand']
    qdone = 0
    while not qdone do begin
	qdone = 1
	imenu = wmenu_sel(menu, /one)
	if (imenu ne -1) then begin
	    test_menu = 'TEST' + strtrim(indgen(1000),2)
	    if (imenu eq (n_elements(menu)-1)) then begin
		input, 'Enter number of characters ', nchar0, nchar0
		input, 'Enter number of lines      ', nlin0, nlin0
		wmenu_sel_set, nchar0, nlin0
	    end else begin
		wmenu_sel_set, nchar_arr(imenu), nlin_arr(imenu)
	    end

	    print, '   **** Putting up a test pattern.  Select any option ****'
	    print, '**** If the procedure crashes, type RETALL and try again ****'
	    print, '**** The ideal case is when the last column has info all the way to the last line ****
	    !err=0
	    ;;on_ioerror, skip2err
	    itest = wmenu_sel(test_menu, /one)
	;    if (!err ne 0) then begin
	;	print, !err
	;	skip2err:
	;	print, 'Wrong choice, please choose a smaller numbers'
	;	qdone = 0
	;    end
	end
    end
end
;
if keyword_set(reset) then begin
    case strupcase(!version.os) of
       'ULTRIX':   begin & nlin0 = 61 & nchar0 = 210 & end
       'SUNOS':    begin & nlin0 = 54 & nchar0 = 190 & end
       else:       begin & nlin0 = 50 & nchar0 = 170 & end
    endcase
    if (strupcase(strmid(getenv('DISPLAY'), 0, 3)) eq 'NCD') then begin & nlin0 = 43 & nchar0 = 124 & end
endif else if keyword_set(get) then begin
    nchar = nchar0
    nlin  = nlin0
endif else if (n_params() eq 0) then return else begin	; Don't clobber with undefined
  nchar0 = nchar
  nlin0 = nlin
endelse

end

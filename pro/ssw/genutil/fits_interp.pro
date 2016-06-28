;+
;
; Interprets a FITS header and returns a structure with the
;	tagnames matching the FITS keywords and tag values 
;	equal to the keyword values.
;

PRO fits_interp, header, result, $
	inname=inname, instruc=instruc, ishort=ishort, fshort=fshort, $
	DASH2UNDERSCORE=dash2underscore
	
; INPUT PARAMETERS:
;	header = FITS header, string array.

; OUTPUT PARAMETERS:
;	result = structure with values.
;
; OPTIONAL INPUT KEYWORDS:
;	inname = name of structure to be created, string.  Ignored
;		if /INSTRUC is passed.  Default, generate a name
;		based on the current date and time UT.
;	instruc = structure to use for interpreting header.
;		Default, create a structure based on the header
;		and the values it contains.
;	ishort - If set, use Integer type rather than Long.
;		Ignored if INSTRUC is provided.
;	fshort - If set, use Float type rather than Double.
;		Ignored if INSTRUC is provided
;	(See Restrictions)
;	DASH2UNDERSCORE - If set, replace all instances of '-' with '_'
;		instead of the default '_D$' (Unnecessary if INSTRUC is provide)
;
; USAGE:
;	The header string array for a given FITS file can be read
;	either with
;		image = READFITS( 'FITS.filename', header )
;	or
;		header = HEADFITS( 'FITS.filename' ).
;	The initial call to FITS_INTERP will define the
;	structure with datatypes based on the values in the
;	header.  It is good practice to use the /INNAME
;	keyword to avoid structure definition conflicts.
;
;	Subsequent calls to FITS_INTERP for the
;	same kind of image files should use the INSTRUC keyword
;	to enforce compatibility of the output structures.
;	It is not possible to redefine the contents of a structure
;	with a given name.
;
; RESTRICTIONS:
;	All byte, integer, and long values are interpreted as long;
;	all float, double and E format values are interpreted as real*8.
;	These conventions insure that if the range of values in the
;	current header is small, there is still room for later, large
;	data values.  The keywords ISHORT and FSHORT can be set
;	to save storage if the data value ranges are KNOWN to be small.
;	Remember, you cannot redefine the structure with a different
;	choice for ISHORT or FSHORT.
;
;	Blank fields may be interpreted with incorrect data types.
;
;	Multiple Comment and History lines in the header are gathered into
;	single .COMMENT and .HISTORY tags as string arrays.
;
;
; HISTORY:
;	Written  September 30, 1994  Barry LaBonte
;	Bug fix for structure name  October 6, 1994  BJL
;	Separate comment and history tags  October 10, 1994  BJL
;	Fix structure name case, order  October 14, 1994  BJL
;	Better logic to identify value field  October 25, 1994 BJL
;	Verify the END line in header  March 3, 1995   BJL
;       4-April-1996 (S.L.Freeland)  - fixed (kluged?) problem with COMMENT
;       11-April-1997 (S.L.Freeland) - same with HISTORY problem
;       13-april-1997 (Craig DeForest) - protection if no comments
;	5-August-1997 (Craig DeForest) - Fixed bug that prevented
;		finding multiple {comment|header} lines with a structure 
;		template.  Now you find up to the number of strings that
;		are allocated in the structure template.
;       21-August-1997 (S.L.Freeland) - implement Barry LaBonte suggestion
;                                       (systime instead of ut_time)
;       20-June-1998 (Zarro, SAC/GSFC) - changed REPCHR call to STR_REPLACE
;	25-Jan-1999 (Craig DeForest) - Diked out use of the vascii array;
;		replaced it with ID_ESC call.
;       18-Jan-2006 (A. Vourlidas, W.T.Thompson)  - expanded typecode list to
;                                     include UINT (SECCHI images)
;	20-Jul-2006 (N.Rich) - Add DASH2UNDERSCORE keyword
;   	18-Sep-2006 (N.Rich) - Fix(?) DASH2UNDERSCORE; initialize HEADER and
;		COMMENT in result because was getting incorrect values in line 313
;-

; Codes for datatype in CREATE_STRUC call
typecode = ['U', 'B', 'I', 'L', 'F', 'D', 'C', 'A', 'S',$
            'DC', 'P', 'O', 'UI', 'UL', 'L64', 'UL64'] ;Added by Vourlidas

;;; Remap ASCII sequence to give valid tag names
;;   (Removed by CED 25-Jan-1999; now we use ID_ESC instead)
;;vascii = BINDGEN(256)
;;vascii(0:35) = BYTE(95)
;;vascii(37:47) = BYTE(95)
;;vascii(58:64) = BYTE(95)
;;vascii(91:94) = BYTE(95)
;;vascii(96) = BYTE(95)
;;vascii(123:*) = BYTE(95)

; Handle the inputs  ------------------------------------------------
IF( KEYWORD_SET( instruc ) EQ 0 ) THEN BEGIN
	IF( KEYWORD_SET(inname) NE 0 ) THEN BEGIN
		sname = STRMID( inname, 0, 10 )
   	ENDIF ELSE BEGIN
		sname = SYSTIME()
		sname = STR_REPLACE( sname, ':', ' ' )
		sname = STR_SEP( sname, ' ' )
		sname = STRMID( sname(1), 0, 2 ) + sname(2) + sname(3) $
			+ sname(4) + sname(5)
		sname = STRLOWCASE( sname )
	ENDELSE

	IF( KEYWORD_SET( ishort ) NE 0 ) THEN intcode = 'I' ELSE intcode = 'L'
	IF( KEYWORD_SET( fshort ) NE 0 ) THEN fltcode = 'F' ELSE fltcode = 'D'
ENDIF

; Slice up the header  -----------------------------------------------
nhead = N_ELEMENTS( header )

; Pick up the keyword fields
front = STRMID( header, 0, 7 )

; Verify that location of the END line
endline = WHERE( STRTRIM(front,2) EQ 'END' ,ecount )
IF( ecount LT 0 ) THEN BEGIN
	PRINT, 'FITS_INTERP: No END line in header'
	RETURN
   ENDIF ELSE BEGIN
	endline = endline(0)
	nhead = endline + 1
	front = front(0:endline-1)
ENDELSE
tagarr = STRARR( nhead-1 )
valarr = STRARR( nhead-1 )


; Find comments and history
coms = WHERE( front EQ 'COMMENT', ncoms )
comarr=''
IF( ncoms GT 0 ) THEN BEGIN
        comarr = STRTRIM( STRMID( header(coms), 8, 72 ), 2 )
ENDIF
IF( ncoms EQ 1 ) THEN comarr = comarr(0)
hists = WHERE( front EQ 'HISTORY', nhist )
IF( nhist GT 0 ) THEN BEGIN
	histarr = STRTRIM( STRMID( header(hists), 8, 72 ), 2 )
ENDIF
IF( nhist EQ 1 ) THEN histarr = histarr(0)
 
; Now get tags, value strings
keys = WHERE( front NE 'COMMENT' AND front NE 'HISTORY', nkeys )
keyarr = header(keys)
tagarr = STRARR( nkeys )
valarr = STRARR( nkeys )

FOR i=0,nkeys-1 DO BEGIN
	tmp = keyarr[i]
; Tag name is keyword
	IF keyword_set(DASH2UNDERSCORE) THEN $
	tagtmp =  repchr(STRTRIM( GETTOK( tmp, '=' ), 2 ), '-', '_') ELSE $
	tagtmp =  ID_ESC(STRTRIM( GETTOK( tmp, '=' ), 2 ))

; Value field should be ended by a slash (/).
; If the value is a string, it may include a slash.
	pslash = STRPOS( tmp, '/' )
	pquote = STRPOS( tmp, "'" )
; No quotes, or they are after /
	IF( (pquote LT 0) OR (pslash GE 0 AND pslash LE pquote) ) THEN BEGIN
		 valarr(i) = GETTOK( tmp, '/' )
	   ENDIF ELSE BEGIN
; Look for the second quote
		pq2 = STRPOS( tmp,  "'", pquote+1 )
; Found the second quote
		IF( pq2 GT pquote ) THEN BEGIN
			valarr(i) = STRMID( tmp, pquote, pq2-pquote+1 )
	   	ENDIF ELSE BEGIN
; No second quote, but found the slash
			IF( pslash GT pquote ) THEN $
				valarr(i) = GETTOK( tmp, '/' ) $		
; Neither one
				ELSE valarr(i) = tmp
		ENDELSE
	ENDELSE

;; Clean out illegal characters in tag names
;; [ This is commented out because it's now handled by ID_ESC up
;; above! -- CED 25-Jan-99]
;;	btmp = BYTE(tagtmp)
;;	btmp = vascii(btmp)
;;	tagarr(i) = STRING(btmp)
	tagarr(i) = tagtmp

ENDFOR
tagarr =  STRTRIM( tagarr, 2 )
IF( ncoms GT 0 ) THEN tagarr = [tagarr, 'COMMENT']
IF( nhist GT 0 ) THEN tagarr = [tagarr, 'HISTORY']
valarr = valarr
strsarr = STRTRIM( valarr, 2 )

; Read the values in this header  -----------------------------------
number = INTARR(nkeys)
values = DBLARR(nkeys)
inum = INTARR(nkeys)

; Find the numbers, convert to Real*8
FOR i=0,nkeys-1 DO BEGIN
	tmp = valarr(i)
	num = STRNUMBER( tmp, val )
	number(i) = num
	IF( num EQ 1 ) THEN BEGIN
		 values(i) = val
		 inum(i) = MAX ( [STRPOS(tmp, '.'), STRPOS(tmp,'e'), $
			STRPOS(tmp,'E'), STRPOS(tmp,'d'), STRPOS(tmp,'D')] )
	ENDIF
ENDFOR

num = WHERE( number EQ 1, nnum )
fixed = WHERE( inum LT 0, ifixed )

; Find the strings, peel off quotation marks
strs = WHERE( number EQ 0, nstrs )
IF( nstrs GT 0 ) THEN BEGIN
	strnew = STRARR(nkeys)
	FOR i=0,nstrs-1 DO BEGIN
		tmp = strsarr(strs(i))
		len = STRLEN(tmp)
		IF( STRMID(tmp,0,1) EQ "'" ) THEN low = 1 ELSE low = 0
		IF( STRMID(tmp,len-1,1) EQ "'" ) THEN len = len - 1
		strnew(strs(i)) = STRTRIM( STRMID(tmp, low, len-low), 2 )
	ENDFOR
ENDIF

; Choose the data types  ---------------------------------------------
ntags = nkeys
IF( ncoms GT 0 ) THEN ntags = ntags + 1
IF( nhist GT 0 ) THEN ntags = ntags + 1
typarr = STRARR(ntags)
IF( KEYWORD_SET( instruc ) EQ 0 ) THEN BEGIN

; The data defines the types
	typarr(strs) = 'A'
	typarr(num) = fltcode
	typarr(fixed) = intcode
	IF( ncoms EQ 1) THEN typarr(nkeys) = 'A'
	IF( ncoms GT 1 ) THEN typarr(nkeys) = 'A(' +  $
				STRTRIM(STRING(ncoms),2) + ')'
	IF( nhist EQ 1 ) THEN typarr(ntags-1) = 'A'
	IF( nhist GT 1 ) THEN typarr(ntags-1) = 'A(' +  $
				STRTRIM(STRING(nhist),2) + ')'
	CREATE_STRUCT, result, sname, tagarr, typarr
	countarr = REPLICATE(1, nkeys)

   ENDIF ELSE BEGIN

; The input structure defines the types
	intags = TAG_NAMES( instruc )
	nintags = N_TAGS( instruc )
	invalues = DBLARR(nintags)
	instrs = STRARR(nintags)
	intyp = STRARR(nintags)
	countarr = INTARR(nintags)
	FOR i=0, nintags-1 DO BEGIN
		hit = WHERE( tagarr EQ intags(i), count )
		countarr(i) = count
		IF( count GT 0 ) THEN BEGIN
			invalues(i) = values(hit) 
			; in case there is DATE-OBS and DATE_OBS in header 7/06, nbr
			instrs(i) = strnew(hit)
			sz = SIZE( instruc.(i) )
			sz = sz( N_ELEMENTS(sz)-2 )
			intyp(i) = typecode(sz)
		ENDIF
	ENDFOR
; Find comments and history
	hitcom = WHERE(intags EQ 'COMMENT', ncoms)
	IF( ncoms GT 0 ) THEN hitcom = hitcom(0)
	ncoms = -ncoms
	hithist = WHERE(intags EQ 'HISTORY', nhist)
	IF( nhist GT 0 ) THEN hithist = hithist(0)
;
; Find multiple comment and history lines with input structure...
; (CED 5-August-1997)
	if(n_elements(instruc) gt 0) then  begin
		if (nhist eq 1) then nhist = n_elements(instruc.(hithist))
		if (ncoms eq 1) then ncoms = n_elements(instruc.(hitcom))
	end
	nhist = -nhist
; Now stuff into arrays
	typarr = intyp
	strnew = instrs
	values = invalues
	nkeys = nintags
	result = REPLICATE(instruc, 1)
	result = result(0)
ENDELSE

; Fill in the structure values  --------------------------------------

good = WHERE(countarr GE 1, ngood)
IF( ngood LE 0 ) THEN RETURN

; Values first
FOR j=0,ngood-1 DO BEGIN
	i = good(j)
	
	CASE typarr(i) OF
		'A'   : result.(i) = strnew(i)
		'B'   : result.(i) = BYTE( values(i) )
		'C'   : result.(i) = COMPLEX( values(i) )
		'D'   : result.(i) = values(i) 
		'F'   : result.(i) = FLOAT( values(i) )
		'I'   : result.(i) = FIX( values(i) )
		'L'   : result.(i) = LONG( values(i) )
                'DC'  : result.(i) = DCOMPLEX( values(i) )      ;Added by WTT
                'UI'  : result.(i) = UINT( values(i) )
                'UL'  : result.(i) = ULONG( values(i) )
                'L64' : result.(i) = LONG64( values(i) )
                'UL64': result.(i) = ULONG64( values(i) )
	ENDCASE
ENDFOR

; Comments if present
IF( ncoms GT 0 ) THEN result.(nkeys) = comarr
IF( ncoms LT 0 ) THEN BEGIN
	nout = -ncoms
	nin = N_ELEMENTS(comarr)
	result.(hitcom)=''  	    	;nbr, 9/18/06
	IF( nin LE nout ) THEN BEGIN
		result.(hitcom) = comarr
	   ENDIF ELSE BEGIN
		result.(hitcom) = comarr(0:nout-1)
	ENDELSE
ENDIF

; History if present
IF( nhist GT 0 ) THEN result.(ntags-1) = histarr
IF( nhist LT 0 ) THEN BEGIN
        nout = -nhist
        nin = N_ELEMENTS(histarr)
	result.(hithist)=''  	    	;nbr, 9/18/06
        IF( nin LE nout ) THEN BEGIN
                result.(hithist) = histarr
           ENDIF ELSE BEGIN
                if nout eq 1 then result.(hithist) = (histarr(0:nout-1))(0) else $
                result.(hithist) = histarr(0:nout-1)
        ENDELSE
ENDIF

ncom=n_elements(comarr)
if tag_exist(result,'COMMENT') and ncom gt 0 then begin
   ncom_str=n_elements(result.comment)
   carr=comarr(0:(ncom < ncom_str)-1)
   if ncom_str eq 1 then carr=carr(0)           ; force scalar
   result.comment(*)=''
   result.comment=carr
end 

RETURN
END

	PRO REV_SWAP, DATA
;+
; Project     :	SOHO - CDS
;
; Name        :	REV_SWAP
;
; Purpose     :	Swaps data between reverse network and host byte order.
;
; Explanation :	This routine takes data with bytes in reverse network
;		(little-endian) order, as used by DEC computers and PCs, and
;		converts it to the correct byte order for the current host.
;		Conversely, it can also convert data in host to reverse network
;		order.
;
; Use         :	REV_SWAP, DATA
;
; Inputs      :	DATA	= Data in reverse network order.
;
; Opt. Inputs :	None.
;
; Outputs     :	DATA	= The byte swapped data is returned in place of the
;			  input array. 
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	DATATYPE
;
; Common      :	The common block REV_SWAP_CMN is used internally to keep track
;		of whether the current computer uses network or reverse network
;		byte order.
;
; Restrictions:	Only the byte order of the data is affected.  No other
;		conversions, such as for example IEEE to host floating point
;		formats, are performed on the data.  If such conversions are
;		necessary, then the call to REV_SWAP can be followed up with
;		either IEEE_TO_HOST or HOST_TO_IEEE.
;
; Side effects:	None.
;
; Category    :	Utilities, Operating_system.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 10 February 1994
;
; Modified    :	Version 1, William Thompson, GSFC, 10 February 1994
;
; Version     :	Version 1, 10 February 1994
;-
;
	ON_ERROR, 2
	COMMON REV_SWAP_CMN, LITTLE_ENDIAN
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  REV_SWAP, DATA'
;
;  If the common block variable hasn't been initialized yet, then test to see
;  if the current host uses network (big-endian) or reverse network
;  (little-endian) byte ordering.
;
	IF N_ELEMENTS(LITTLE_ENDIAN) EQ 0 THEN BEGIN
		TEST = 1
		BYTEORDER, TEST, /NTOHS
		LITTLE_ENDIAN = TEST NE 1
	ENDIF
;
;  If the current host uses reverse network order, then no byte swapping is
;  needed.
;
	IF LITTLE_ENDIAN THEN RETURN
;
;  Otherwise, swap the bytes according to the data type.
;
	CASE DATATYPE(DATA,2) OF
		0:  MESSAGE, 'DATA not defined'
		1:  RETURN			;Byte
		2:  BYTEORDER, DATA, /SSWAP	;Short integer
		3:  BYTEORDER, DATA, /LSWAP	;Long integer
		4:  BYTEORDER, DATA, /LSWAP	;Floating point
		5:  BEGIN			;Double precision
			SZ = SIZE(DATA)
			NPOINTS = N_ELEMENTS(DATA)
			DATA = BYTE(TEMPORARY(DATA), 0, 8, NPOINTS)
			DATA = ROTATE(TEMPORARY(DATA), 5)
			DATA = DOUBLE(TEMPORARY(DATA), 0, NPOINTS)
			IF SZ(0) NE 0 THEN	$
				DATA = REFORM(DATA, SZ(1:SZ(0)), /OVERWRITE)
		    END
		6:  BYTEORDER, DATA, /LSWAP	;Complex
		7:  RETURN			;String
		8:  BEGIN			;Structure
			NTAG = N_TAGS(DATA)
			FOR T = 0,NTAG-1 DO BEGIN 
				TEMP = DATA.(T)
				REV_SWAP, TEMP
				DATA.(T) = TEMP
			ENDFOR
			END
		ELSE:  MESSAGE,'Unrecognized data type'
	ENDCASE
;
	RETURN
	END

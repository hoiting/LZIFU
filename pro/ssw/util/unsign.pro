;+
; Project     : SOHO - CDS     
;                   
; Name        : UNSIGN()
;               
; Purpose     : Produces longword equivalent of an unsigned 16-bit integer.
;               
; Explanation : If an unsigned 16-bit value is held internally in IDL in an
;               INT variable, overflow can occur.  This routine translates 
;               the value to a longword so that the value can be handled as
;               required.  Optionally, it can also be used to extract the lower
;		NBITS bits in a number in which the higher order bits should be
;		suppressed.
;               
; Use         : lword = UNSIGN( INT16  [, NBITS ] )
;    
; Inputs      : INT16  - 16-bit integer whose bytes represent an unsigned
;                        2-byte integer.
;               
; Opt. Inputs : NBITS  - Number of low-order bits to use in extracting the
;			 unsigned value.  If not passed, then 16 is assumed.
;               
; Outputs     : Function returns the longword equivalent.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, numerical
;               
; Prev. Hist. : Original by MK Carter
;
; Written     : CDS version by C D Pike, RAL, 22-Oct-93
;               
; Modified    : Version 1, C D Pike, RAL 22-Oct-93
;		Version 2, William Thompson, GSFC, 19 November 1993.
;			Modified to speed up.  Added DATATYPE check.
;		Version 3, William Thompson, GSFC, 20 June 1995
;			Added optional parameter NBITS
;		Version 4, William Thompson, GSFC, 24 May 1999
;			Accommodated IDL/v5.2 hex constants change
;		Version 5, William Thompson, GSFC, 7 June 1999
;			Continue processing if something other than a short
;			integer is passed, but print an error message.
;
; Version     : Version 5, 7 June 1999
;-            

FUNCTION UNSIGN , VALUE, NBITS

IF DATATYPE(VALUE,1) NE 'Integer' THEN MESSAGE,	/CONTINUE, $
	'Input array should be short integer'

IF N_PARAMS() EQ 2 THEN MASK = 2L^NBITS - 1 ELSE MASK = 'FFFF'XL

RETURN, LONG(VALUE) AND MASK

END

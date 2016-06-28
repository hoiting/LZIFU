;+
; Project     : SOHO - CDS     
;                   
; Name        : BYTESWAP()
;               
; Purpose     : Swaps the bytes in an integer (as a function).
;               
; Explanation : Call the internal IDL routine BYTEORDER to perform byte
;               swapping on integers as a function call.  Handles arrays
;               the same as BYTEORDER but passes none of the keywords.
;               
; Use         : IDL> ba = byteswap(ab)
;    
; Inputs      : ab    - integer [array]
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns byte swapped version of input
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : IDL BYTEORDER
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, Numerical
;               
; Prev. Hist. : Written by Arnulf (Spacetec)
;
; Written     : CDS version  C D Pike, RAL, 1 Oct 93
;               
; Modified    : Version 1, C D Pike, RAL 1 Oct 93
;		Version 2, William Thompson, GSFC, 12 November 1993
;			Added /NTOHS to BYTEORDER for platform independence.
;
; Version     : Version 2, 12 November 1993.
;-            


FUNCTION ByteSwap, I
  
BYTEORDER, I, /NTOHS

RETURN, I

END

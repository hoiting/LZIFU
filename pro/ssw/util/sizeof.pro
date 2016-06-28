;+
; Project     : SOHO - CDS     
;                   
; Name        : SIZEOF()
;               
; Purpose     : Calculates the size of an IDL variable 
;               
; Explanation : Calculates the size of an IDL variable. In the current
;               Ultrix IDL release (2.3.0 ), size of structures cannot be 
;               obtained since recursive calls are not supported. String
;               variables are countedas one byte each (??)

;               
; Use         : x= sizeof( input )
;    
; Inputs      : input -  any IDL variable
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns size of input variable
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
; Category    : Util, misc
;               
; Prev. Hist. : Arnulf, Oct-93
;
; Written     : For FM sci_ana program, C D Pike, RAL, 22-Oct-93
;               
; Modified    : 
;
; Version     : Version 1, 22-Oct-93
;-            

FUNCTION sizeof, DataItem

;
; First get the information regarding the item
;
Info = SIZE (DataItem)

;
;  deduce type and number of elements
;
Type = Info(Info(0)+1)
Nitems = Info(Info(0)+2)
Size = 0

;
;  calculate number of bytes depending on item type
;
CASE Type OF

   1:  Size = 1 * Nitems

   2:  Size = 2 * Nitems

   3:  Size = 4 * Nitems

   4:  Size = 4 * Nitems

   5:  Size = 8 * Nitems

   6:  Size = 8 * Nitems

   7:  Size = 1 * Nitems

   8:  BEGIN
          Tags = TAG_NAMES (DataItem)
          Info1 = SIZE (Tags)
          FOR j = 0, Info1(Info1(0)+2)-1 DO BEGIN
             String = "Size = Size + sizeof(DataItem." + Tags(j) + ")"
             ret = EXECUTE (String)
          ENDFOR
       END

ENDCASE

;
;  return size in bytes
;
RETURN, LONG(Size)

END

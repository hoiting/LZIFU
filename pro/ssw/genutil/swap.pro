pro swap,x
;+
; NAME:
;   SWAP
; PURPOSE:
;   Procedure to swap bytes
; CALLING SEQUENCE:
;   SWAP,X
; INPUT:
;   X - variable to be byte swapped.  Can be BYTE, INTEGER*2 or INTEGER*4.
;       The order of the bytes will be reversed. For a byte array, 
;       the number of bytes should be even and every other byte will be 
;       swapped.
; REVISION HISTORY:
;   Written  D. Lindler 1986
;   Converted to version 2 IDL B. Pfarr, STX, 1/90 added code to 
;      swap bytes in byte array
;	19-May-93 (MDM) - Made the INDGEN statement a LINDGEN to handle
;			  large arrays.
;-
s=size(x)
type=s(s(0)+1)	;data type
;
case type of
;
 1 :  begin            ;byte array
         s=n_elements(x)
         ;skpodd=indgen(s/2)*2       ;Even numbered characters in one line
         skpodd=lindgen(s/2)*2       ;Even numbered characters in one line
         k=x(skpodd)		    ;Store even numbered characters
         x(skpodd)=x(skpodd+1)      ;Shift odd numbered characters to even slots
         x(skpodd+1)=k              ;Fill odd numbered slots with stored chars
      end
  2 : begin		;integer*2
	i1=ishft(x,-8) and "377
	i2=x and "377
	x=ishft(i2,8) or i1
      end
;
  3 : begin		;integer*4
	i1=ishft(x,-24) and "377
	i2=ishft(x,-16) and "377
	i3=ishft(x,-8) and "377
	i4=x and "377
	x=ishft(i4,24) or ishft(i3,16) or ishft(i2,8) or i1
      end
else : return
endcase
return
end

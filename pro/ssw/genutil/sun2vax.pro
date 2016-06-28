
pro sun2vax, ainput

;+
;NAME:
;	sun2vax
;PURPOSE:
;	Converts data written on a DEC machine to SUN format by swapping
;	bytes appropriately for the type of the input data.
;CATEGORY:
;	Byte-swapping
;CALLING SEQUENCE:
;	sun2vax,a
;INPUTS:
;	a = input variable which is to have its bytes swapped
;OPTIONAL INPUT PARAMETERS:
;	none
;KEYWORD PARAMETERS
;	none
;OUTPUTS:
;	a = reformatted variable is passed back in the original variable
;COMMON BLOCKS:
;	None
;SIDE EFFECTS:
;	None
;RESTRICTIONS:
;	None.
;PROCEDURE:
;	Determines the type of the variable and swaps the bytes depending
;	on the type.  If the variable is a structure, the tags are 
;	recursively searched so that the bytes are swapped throughout
;	the structure.
;MODIFICATION HISTORY:
;	T. Metcalf 9/17/91  Version 1.0
;           Modified vax2sun.pro
;
;-

   a = ainput  ; Protect the input variable in case of error

   sofa = size(a)
   ns = n_elements(sofa)

   ; If not a structure, then swap bytes

   if (sofa(ns-2) NE 8) then begin
      case sofa(ns-2) of
       0:                                  ; Undefined
       1:                                  ; Byte
       2: byteorder,a,/sswap               ; Integer
       3: byteorder,a,/lswap               ; Longword integer
       4: ieee2vax,a                       ; Floating Point
       5: ieee2vax,a                       ; Double precision floating point
       6: begin                            ; Complex floating point
            rc=float(a)
            ic=imaginary(a)
            ieee2vax,rc
            ieee2vax,ic
            a = complex(rc,ic)
          end
       7:                                  ; String
       else: print,'WARNING: sun2vax: Unknown type code'
      endcase
   endif $
   else begin
      na = sofa(ns-1)

      ; In the case of a structure, search all the fields (recursively if 
      ; necessary) to swap all bytes which need swapping in the structure.

      for tag = 0, n_tags(a)-1 do begin

         temp = a.(tag)      ; byteorder won't work on a structure field
         sofa = size(temp)
         ns = n_elements(sofa)
         case sofa(ns-2) of
          0:                                  ; Undefined
          1:                                  ; Byte
          2: byteorder,temp,/sswap            ; Integer
          3: byteorder,temp,/lswap            ; Longword integer
          4: ieee2vax,temp                    ; Floating Point
          5: ieee2vax,temp                    ; Double precision floating point
          6: begin                            ; Complex floating point
               rc=float(temp)
               ic=imaginary(temp)
               ieee2vax,rc
               ieee2vax,ic
               temp = complex(rc,ic)
             end
          7:                                  ; String
          8: sun2vax, temp                    ; Structure (recursive)
          else: print,'WARNING: sun2vax: Unknown type code'
         endcase
         a.(tag) = temp
   
      endfor

   endelse

   ainput = a

end

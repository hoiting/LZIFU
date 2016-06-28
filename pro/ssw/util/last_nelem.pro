function last_nelem, data, nelems, overwrite=overwrite
;+
;   Name: last_nelem
;
;   Purpose: return last NN elements of vector or last NN images of data cube 
;
;   Input Parameters:
;      data   - the source data item
;      nelems - number of subscripts (default=1 => the 'last' element)
; 
;   Ouput:
;      function returns last NN elements (last NN images if input is 3D)
;
;   Calling examples:
;      IDL> print,last_nelem(findgen(100))  ; default is last element
;                99.0000
;      IDL> print,last_nelem(indgen(10),3)  ; 2nd parameter for last NN
;           7       8       9
;     
;      IDL> help,last_nelem(indgen(256,256,10), 4)    ; last NN images if 3D
;      <Expression>    INT       = Array[256, 256, 4]
;
;   History:
;      16-July-1998 - S.L.Freeland - tired of repeating this logic.
;-
ndata=n_elements(data)
nimages=data_chk(data,/nimages)

case 1 of
   ndata eq 0: begin 
      box_message,'IDL> lastelems=last_nelem(data [,nn])'
      return,-1
   endcase
   nimages le 1: begin 
      case 1 of 
         n_elements(nelems) eq 0:retval=data(ndata-1)  ; last elem
         nelems ge ndata: retval=data                  ; everything
         else: retval=data(ndata-nelems:ndata-1)      
      endcase
   endcase
   else: begin  ;----------- cube - extract last NN images --------
      case 1 of 
         n_elements(nelems) eq 0:retval=data(*,*,nimages-1)  ; last elem
         nelems ge nimages: retval=data                      ; everything
         else: begin
            retval=make_array(data_chk(data,/nx), data_chk(data,/ny), nelems,$
                              type=data_chk(data,/type),/nozero)
            for i=0,nelems-1 do $
                retval(0,0,i)=data(*,*,nimages-(nelems-i))
         endcase
      endcase
   endcase
endcase

return, retval
end
 
   

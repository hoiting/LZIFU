function positive, inarg, inval=inval
;+
;   Name: positive
;
;   Purpose: boolean - 1 (true) if positive - scaler/arrays ok
;
;   Keyword Parameters:
;      inval - switch, if set, invalid data returns 0 (false) not -1 (invalid)
;
;   Calling Sequence:
;      pos=positive(array [,/inval])
;      
;   Calling Example:
;      if positive(scaler) then .. 	  ; scaler returns scaler for boolean
;					  ; compare (assume arithmetic input)
;      if positive(scaler,/inval) then... ; false if negative OR invalid input
;					  ; type (string/structure/undefined)
;   History:
;      27-Apr-1993 (SLF)
;   
;   Restrictions:
;      no strings/structures/undefined input please (returns -1)
;-
;
result=-1			; intialize return value
; filter invalid input
invalid=[0,7,8]
invtypes=['Undefined','String','Structure']
sarg=size(inarg)
type=sarg(sarg(0)+1)
test=where(type eq invalid,count)
;
case 1 of 
   count eq 0: begin			   ; valid input data
      result = inarg eq abs(inarg)
      if n_elements(result) eq 1 then $
	   result=result(0)
   endcase
   keyword_set(inval): result=0		   ; invalid, but keyword set
   else: begin				   ; invalid, no keyword
      result=-1
      message,/info,'Invalid input type: ' + invtypes(test(0))
   endcase
endcase   

return,result
end


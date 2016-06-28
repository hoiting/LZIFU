function totvect, vector, derivative=derivative
;+
;   Name: totvect
;
;   Purpose: running sum of a vector (must have been done at lease 10e9 times)
;
;   Input Parameters:
;      vector - vector to perform running total on
;
;   Keyword Parameters:
;      derivative - switch, if set, running total of derivative(vector)
;            
;   Calling Sequence:
;      runsum=totvec(vector [,/derivative])
;
;   Method: brute force 
;   
;   History:
;      14-mar-1995 (SLF)
;      22-oct-1996 (SLF) - made output double , error check, ucon->gen 
;                          change name from <totvec> to <totvect>
;      28-jan-1999 (RAS) - switch to Long index on do loop and do a
;                          true running sum.
;      3-Dec-1999 (RAS) - fixed syntax error in CASE statement
;-
derivative=keyword_set(derivative)
;
; ---------------------- check input ---------------------------
case 1 of 
   n_params() eq 0: begin
      message,/info," IDL> runningsum=totvec( vector [,/derivative])
      return,-1                                ; early exit!
   end
   n_elements(vector) eq 1 and derivative: begin
      message,/info," Must have at least 2 elements w /DERIVATIV switch
      return,-1                                ; early exit!
   end
   else: ivec=vector                           ; copy input
endcase

; -------------------- compute running total --------------------------
if derivative then ivec=temporary(deriv_arr(ivec))    ; act on derivative?
ovec=dblarr(n_elements(ivec))                          ; define output vector
ovec(0) = ivec(0)
for i=1L,n_elements(ovec)-1 do ovec(i)= ovec(i-1) + ivec(i)  ; running total
; --------------------------------------------------------------------

return,ovec
end

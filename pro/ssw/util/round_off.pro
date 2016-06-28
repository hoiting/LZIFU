;+
; Project     : SOHO - CDS     
;                   
; Name        : ROUND_OFF()
;               
; Purpose     : To round a number to a specified accuracy
;               
; Explanation : Rounds the input number to the accuracy specified.
;               
; Use         : IDL> out = round_off(x,acc)
;               IDL> out = round_off(12.278,0.01) ==> out = 12.28
;    
; Inputs      : x    - the number to be operated on
;               acc  - the numerical accuracy required
;               
; Opt. Inputs : None
;               
; Outputs     : The function value is the input rounded to the desired accuracy
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : NINT
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 17-May-1993
;               
; Modified    : Replace calls to NINT by ROUND.  CDP, 17-Jun-95
;
; Version     : Version 2, 17-Jun-95
;-            

function round_off,num,acc

;
;  check enough parameters
;
if n_params() lt 2 then begin
   bell
   print,'Use: num = round_off(input, accuracy)'
   return,0.0
endif

;
;  check for negative input
;
if num lt 0.0 then neg=1 else neg=0

;
;  round off according to the accuracy required
;
num = abs(num)
if acc lt 1.0 then begin
   factor = round(1.0/acc)
   x = long((num+0.5*acc)*factor)/double(factor) 
endif else begin
   x = long((long((num+acc/2.)/acc))*acc)
endelse

;
;  return in same form received
;
case datatype(num) of
   'BYT': x = byte(x)
   'INT': x = fix(x)
   'LON': x = long(x)
   'DOU': x = double(x)
   'FLO': x = float(x)
endcase

if neg then return,-x else return,x

end

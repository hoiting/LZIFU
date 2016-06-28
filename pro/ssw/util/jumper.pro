;+
; Project     : SDAC
;                   
; Name        : JUMPER
;               
; Purpose     : This procedure corrects 2-byte or other counter overflow.
;               
; Category    : GEN, MATH, NUMERICAL, TELEMETRY
;               
; Explanation : 
;  This procedure looks for overflow in 2-byte or other counter data and then adjusts
;  it to the true rate.  The algorithm looks for abrupt changes in the rate, 
;  OVERFLOW, of more than 65536/2.  It is assumed that these jumps are produced 
;  by overflow.  After finding these jumps it is simply bookkeeping to reset the 
;  data to the true rate.
;               
; Use         : 
;	jumper, overflow, reset [, summed_rolls=nn, single=single, max_value=max_value]
; Example     :
;	jumper, temp, reset
;   
; Inputs      : 
;	Overflow - Input 2byte counter values as longwords or float
;               
; Opt. Inputs : None
;               
; Outputs     : 
;	Reset - Counter value corrected for rollover, same type as Overflow
;
; Opt. Outputs: None
;               
; Keywords    : 
;	Inputs:
;	MAX_VALUE - maximum unsigned value in counter before rollover, for
;	integer data it is 65535L (default).  For byte data set max_value
;	to 256, and use an integer to save memory.
; 	Outputs:
;	SUMMED_ROLLS - signed values of successive rollovers. 
;		Should total zero for successful correction.
;	SINGLE - If set, then a single unmatched overflow can be corrected
;
; Calls	      : CHECKVAR
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: 
;               
; Prev. Hist  :
;	written for BATSE data 1991, based on an original Hugh Hudson idea!!!
; Modified    : 
;	Version 1 ras, 5 March 1996
;	Version 2, ras, 21-mar-1997, eliminate a temporary variable, jump.
;		added SINGLE keyword, and max_value
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-            
;==============================================================================
pro jumper, overflow, reset , summed_rolls=nn, single=single, max_value=max_value

checkvar, max_value, 65535L
roll_value = max_value+1
comp_value = roll_value/2

;LOOK FOR JUMPS IN THE COUNT RATE
;
reset = overflow
nn = intarr(1)
;
;jump = overflow - overflow(1:*) 
overflow = overflow - overflow(1:*) 
;
;w = where( abs(jump) gt comp_value, ncount)
w = where( abs(overflow) gt comp_value, ncount)
;
if ncount eq 0 then goto,ALLDONE
;
;nn = jump(w)/65536
nn = overflow(w)/(1.0 * roll_value)
nn = fix( nn + .5 * nn/abs(nn)) ;round nn to it's nearest integer value
overflow = reset	;don't change input variable.
;
;nn is a vector of plus or minus one's, plus one for a true increase
;
;sum up successive rollovers
;
ntot=nn
for i=1,ncount-1 do ntot(i)=nn(i)+ntot(i-1)
;
;CORRECT FOR THE OVERFLOWS
if not keyword_set(single) or ncount ne 1 then $
	for i=0,ncount-2 do reset(w(i)+1)=reset(w(i)+1:w(i+1))+ntot(i)*roll_value $
else reset(w(0)+1) = reset(w(0)+1:*) + nn(0)*roll_value
;
ALLDONE: 
end

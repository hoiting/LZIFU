;+
; Project     : SDAC
;                   
; Name        : Jumper2
;               
; Purpose     : This procedure corrects 2-byte or other counter overflow.
;               
; Category    : GEN, MATH, NUMERICAL, TELEMETRY
;               
; Explanation : 
;  This procedure looks for counter overflow in the counter data and then adjusts
;  it to the true rate.  The algorithm looks for abrupt changes in the 2nd 
;  difference in the rate,
;  OVERFLOW, of more than 65536/2.  It is assumed that these jumps are produced 
;  by overflow.  After finding these jumps it is simply bookkeeping to reset the 
;  data to the true rate.;               
; Use         : 
;	 jumper2, overflow, reset , summed_rolls=nn   
; Examples    :
;        jumper2, reform(clean-data(last_chan,last_id,wnz)), clean, summed=summed
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
;	SUMMED_ROLLS - signed values of successive rollovers. 
;		Should total zero for successful correction.
;
; Calls	      :
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  :
;	written for BATSE data 1991
; Modified    : 
;	Version 1 ras, 5 March 1996
;       Version 2, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-            
;==============================================================================
pro jumper2, overflow, reset , summed_rolls=nn

;LOOK FOR JUMPS IN THE COUNT RATE

reset = overflow
nn = intarr(1)
;
jump = overflow - overflow(1:*) 
jump2 = jump - jump(1:*)
;
w = where( abs(jump2) gt 32768L, ncount)
;
if ncount eq 0 then goto,ALLDONE
;
nn = jump2(w)/65536.
nn = fix( nn + .5 * nn/abs(nn)) ;round nn to it's nearest integer value
;
;nn is a vector of plus or minus one's, plus one for a true increase
;
;sum up successive rollovers
;
ntot=nn
for i=1,ncount-1 do ntot(i)=nn(i)+ntot(i-1)
;
;CORRECT FOR THE OVERFLOWS
for i=0,ncount-2 do $
	if (w(i)+1) lt w(i+1) then $
	   reset(w(i)+1)=reset(w(i)+1:w(i+1)+1)+ntot(i)*65536
;
ALLDONE: return
end

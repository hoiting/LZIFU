;+
; NAME:
;       MATCH_INTERVALS
; PURPOSE:
;       Routine to match intervals in two vectors of intervals
;
; CALLING SEQUENCE:
;       match_intervals, a, b, suba, subb, [ COUNT =, EPSILON = ]
;
; INPUTS:
;       a,b - two [2,n] vectors to match elements, numeric or string data types
;
; OUTPUTS:
;       suba - subscripts of rows in vector a with a match
;               in vector b
;       subb - subscripts of the positions of the rows in
;               vector b with matches in vector a.
;
;       suba and subb are ordered such that a[*,suba] equals b[*,subb]
;
; OPTIONAL INPUT KEYWORD:
;       epsilon - if values are within epsilon, they are considered equal. Used only
;               in non-integer matching.  Default=0.
;
; OPTIONAL KEYWORD OUTPUT:
;       COUNT - set to the number of matches, integer scalar
;
; SIDE EFFECTS:
;       The obsolete system variable !ERR is set to the number of matches;
;       however, the use !ERR is deprecated in favor of the COUNT keyword
;
; RESTRICTIONS:
;       The vectors a and b should not have duplicate values within them.
;       You can use rem_dup function to remove duplicate values
;       in a vector
;
; EXAMPLE:
;       If a = [ [3,4], [5,6], [8,9] ]
;        & b = [ [5,6], [7,8], [8,9], [10,12] ]
;       then
;               IDL> match_intervals, a, b, suba, subb, COUNT = count
;
;       will give suba = [1,2], subb = [0,2],  COUNT = 2
;       and       a[*,suba] = b[*,subb] = [ [5,6], [8,9] ]
;
;
; METHOD:
;       Calls match to compare the start value of intervals in a and b.  Then uses the
;		matching subset to find which end values of intervals a and b match.
;
; HISTORY:
; Written: 22-Mar-2008, Kim Tolbert

;-
;-------------------------------------------------------------------------

pro match_intervals, inta, intb, suba, subb, count=count, epsilon=epsilon

on_error,2
count = 0
suba = -1 & subb = -1

dima = size(inta,/dim)  &  dimb = size(intb,/dim)
if dima[0] ne 2 or dimb[0] ne 2 then $
	message, 'Input arrays must be 2xn (n can be different for two arrays).'

; first find where start of intervals match within epsilon
match, reform(inta[0,*]), reform(intb[0,*]), suba, subb, count=count, epsilon=epsilon

if count eq 0 then return

; find which end of intervals match within epsilon, starting from subset with matched start
isa = suba  &  isb = subb
endinta = reform(inta[1,isa])  &  endintb = reform(intb[1,isb])

match, endinta, endintb, suba, subb, count=count, epsilon=epsilon

if count eq 0 then return

suba = isa[suba]  &  subb = isb[subb]

return

end

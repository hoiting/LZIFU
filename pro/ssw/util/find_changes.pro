;+
; Project     : HESSI
;
; Name        : find_changes
;
; Purpose     : Procedure to find changes of value in an array.
;
; Category    : Utility
;
; Syntax      : IDL> find_changes, inarray, index, state [, count=count]
;
; Explanation : Output are two arrays:  an array of indices into inarray where the value of
;               the array changes, and an array of the value of inarray at each change. Note
;               that the start of the array is considered a change, so element 0, and starting
;               value will always be included in the output arrays.  If you just want changes
;               in the array, ignore the first element in the output arrays.
;
; Inputs      : inarray - input vector
;
; Opt. Input Keywords : None
;
; Outputs     : index - vector of indices into array where value changes
;               state - vector of values at beginning of each value change
;
; Opt. Output Keywords: count - number of changes found
;
; Examples:
; IDL> inarray = [0,0,2,2,3,3,3,0,0,2]
; IDL> find_changes, inarray, index, state
; IDL> print,index
;           0   2  4  7  9
; IDL> print,state
;           0  2  3  0  2
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : 28-Jan-2002, Kim Tolbert
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;-

pro find_changes, inarray, index, state, count=count
nin = n_elements(inarray)
;added the exception for 1 element array, jmm, 13-jun-2002
if(nin eq 1) then count = 0 $
	else q = where (inarray(1:*) - inarray(0:nin-2) ne 0, count)
if count eq 0 then index = 0 else index = [0, q+1]
state = inarray(index)
count = count+1

return
end

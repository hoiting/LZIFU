;+
; Project     : SOHO - CDS     
;                   
; Name        : MODE_VAL()
;               
; Purpose     : Returns the modal value of an array.
;               
; Explanation : The modal value of an array (any dimension) is deduced from
;               the max value of the histogram.  If several values occur
;               with equal frequency, a warning is given but only the smallest
;               value of the group is returned.
;               
; Use         : IDL> m = mode_val(array [,freq])
;
;               eq print,mode_val([2,3,4,5,2,2,3,4,2,2,7,8,9]) --> 2
;                  print,mode_val('asdfghaaasdfvbnm') --> a
;                  print,mode_val(['asdf','ghaaa','asdf','vbnam'],freq) --> a
;                    and freq returned with value 6
;    
; Inputs      : array  -  the n-dimensional integer array in which to find the
;                         mode.
;                         Can be a string array but not a structure. The string
;                         option is a little restricted in that whatever the
;                         input format, the string is viewed as a byte array
;                         and the most frequent byte value returned
;               
; Opt. Inputs : None
;               
; Outputs     : Function return is the modal value
;               
; Opt. Outputs: freq  - the number of occurrences of the modal value
;               
; Keywords    : BIN - sets binning size for histogram and hence 'resolution'
;                     of modal value.
;
; Calls       : None
;               
; Restrictions: Non-real arrays or strings only
;               
; Side effects: None
;               
; Category    : Utilities, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 1-Jul-1993
;               
; Modified    : Fix typo, add BIN keyword.  CDP, 24-Jul-96
;
; Version     : Version 2, 24-Jul-96
;-            

function mode_val, array, freq, bin=bin

;
;  check has minimum parameter
;
if n_params() eq 0 then begin
  bell
  print,'MODE_VAL: must have at least one parameter, the input array.'
  return,0
endif

;
;  cannot cope with structures
;
if datatype(array,2) gt 5 and datatype(array,2) ne 7 then begin
  bell
  print,'MODE_VAL: cannot deal with non-real datatypes and structures.'
  return,0
endif

;
;  for strings
;
str = 0
if datatype(array) eq 'STR' then begin
   str = 1
   sarr = array
   array = byte(array)
endif

;
;  check if default bin size
;
if (not keyword_set(bin)) or str then bin = 1

;
;  calculate histogram
;
h = histogram(array,min=0,bin=bin)

;
;  get index and hence value of most common value and number of occurrences
;
freq = max(h)
mode = where(h eq freq)

;
;  translate string back if necessary and return
;
if str then begin
   array = sarr
   return,string(byte(mode(0)))
endif else begin
   return,mode(0)*bin
endelse

end

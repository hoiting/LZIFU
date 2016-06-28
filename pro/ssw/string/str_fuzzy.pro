;+
; Project     : HESSI
;
; Name        : STR_FUZZY
;
; Purpose     : fuzzy string pattern match
;
; Method      : INPUT contains an array of the minimum characters required for a match.
;               PATTERN contains a string that must at least have the characters in input
;               for a match but could contain other characters.  Useful for user input, where
;               users might roughly remember parameter name, but not exactly.
; Example     :
;               Say the user requested 'rates' but the standard parameter name is 'rate'
;               standard_name = ['counts', 'rate', 'flux']
;               print,standard_name (str_fuzzy( ['co', 'ra', 'fl'], 'rates') )
;
; Category    : string utility
;
; Inputs      : INPUT = input string or string vector
;               PATTERN = scalar string pattern to find (approximately) in input string(s)
;
; Outputs     : Index into INPUT of match, or -1 if no match
;
; Keywords    : NONE
;
; Written:  Kim Tolbert,  July 2003
;-

function str_fuzzy, input, pattern

if n_params() ne 2 then return, -1

if size(input,/type) ne 7 or size(pattern,/type) ne 7 then return, -1

for i=0,n_elements(input)-1 do if grep(input[i], pattern) ne '' then return, i

return,-1
end
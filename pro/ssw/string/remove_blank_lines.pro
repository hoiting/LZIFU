;+
; NAME
;
;           REMOVE_BLANK_LINES()
;
; PROJECT
;
;           SOLAR-B/EIS
;
; EXPLANATION
;
;           Remove blank lines from a string array
;
; INPUTS
;
;           array - a string array
;
; HISTORY
;
;     V0.1, Written 28-June-2006, John Rainnie
;-
FUNCTION remove_blank_lines , array

string_lengths = STRLEN(STRMID(STRCOMPRESS(array,/REMOVE_ALL),2))
; If there are no blank lines, then bail out
null_strings = WHERE(string_lengths EQ 0 , count , complement = indicies) 
IF (count EQ 0) THEN RETURN , array

RETURN , array[indicies]

END

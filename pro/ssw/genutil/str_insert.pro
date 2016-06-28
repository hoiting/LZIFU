pro str_insert, str_array, str, i
;
;+
;NAME:
;	str_insert
;PURPOSE:
;	To insert one structure into an identical array of structures,
;	but which might have a different structure name.
;SAMPLE CALLING SEQUENCE:
;	str_insert, str_array, str, i
;INPUT/OUTPUT:
;	str_array - the array of structures
;INPUT:
;	str	- The structure to put into the array of structures
;	i	- The indicy of where to insert "str"
;HISTORY:
;	Written 6-Jun-93 by M.Morrison
;-
;
str_temp = str_copy(str_array(0), str)
str_array(i) = str_temp
end

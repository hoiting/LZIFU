function str_ver_update, str, ref_str
;+
;NAME:
;	str_ver_update
;PURPOSE:
;	Allow old structures to be copied to new structure definitions
;	where the tag names match.
;INPUT:
;	str	- old structure
;	ref_str	- reference structure type which should have the data
;		  copied over to
;OUTPUT:
;	returns	- a structure of type "ref_str" with the contents of
;		  "str" copied into it.
;RESTRICTIONS:
;	It assumes that the general organization of the two structures
;	is close and that only a few tags do not match.
;HISTORY:
;	Written 10-Nov-91 by M.Morrison
;-
;
n = n_elements(str)
temp = replicate(ref_str(0), n)
;
out = str_copy_tags(temp,str)	;str_copy_tags uses recursion and we need
				;to make sure that the output array
				;is the proper size before doing the
				;copy
;
;TODO - Optionally have a table that matches old tag names to new tag
;	names where possible.
;
return, out
end

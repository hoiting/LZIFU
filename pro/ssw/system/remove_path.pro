;+
;
; NAME: 
;	REMOVE_PATH
;
; PURPOSE:
;	This procedure removes directories with the input string
;	from the software path.
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
; 	REMOVE_PATH, TEST_STRING
;	
;	E.G.
;	remove_path, 'schwartz' 
;
; 	!path will not have any elements with the string 'schwartz'
;
; CALLS:
;	STR_SEP, ARR2STR
;
; INPUTS:
;       Search_string- remove directories with this substring
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	OLD_PATH- the inititial !path
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	Cleaned documentation, RAS, June 1996
;	Version 2, richard.schwartz@gsfc.nasa.gov, 2-sep-1998.  Made Windows and MacOS compatible.
;-


pro remove_path, search_string, old_path=old_path

old_path = !path

ON_ERROR, 2
IF N_ELEMENTS(search_string) EQ 0 THEN MESSAGE, $
      'Syntax: REMOVE_PATH, path_name.'
   
IF datatype(search_string) NE 'STR' THEN MESSAGE, $
         'The input parameter has to be of string type.'



CASE OS_FAMILY() OF
      'vms': delim = ',' 
      'Windows': delim = ';'
      ELSE: delim = ':' 
      ENDCASE

dir_names = str_sep(!path, delim)




if os_family() ne 'vms' then $
	wuse = where( strpos(dir_names, search_string) eq -1, nuse) else $
	wuse = where( strpos(strupcase(dir_names), strupcase(search_string)) eq -1, nuse) 


if nuse ge 1 then !path=arr2str( dir_names(wuse), delim )

end

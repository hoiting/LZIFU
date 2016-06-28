function build_str , unit , mainsize, struc=struc 

;+
;   Name: build_str
;
;   Purpose: build data structure for generic files using size 
;	     information encoded by wrt_str.pro
;
;   Input Parameters:
;      unit - logical unit number (file opened before call)
;      mainsize - saved on first call
;   Keyword Paramters:
;      structure (Input) - string representation of intermediate data
;			   structure used in recursive calls
;
;   Method: recursive for nested structures
;	    calls make_str for every structure level
;
;
;   History: SLF, 10/30/91
;	10-Feb-96 (MDM) - Modified to handle two dimensional structures
;
;-
n_dimension = 0L

if not keyword_set(struc) then begin		; 1st (non recursive) call
   struc=''					; initialize string 
   readu, unit, n_dimension			; number elements in
   arr_size=make_array(n_dimension+2,/long)	; size vector
   readu, unit, arr_size			; read size vector
   mainsize=arr_size(2)				; number of upper level strs
endif
;
n_tags=0L					;
readu,unit,n_tags
;
structure=struc+'{buildstr'
tagnames=make_array(n_tags,/string)
readu, unit, tagnames
;  
; for each tag, append string tag definition
;  
for tag=0, n_tags-1 do begin
   readu, unit, n_dimension			; number elements in
   arr_size=make_array(n_dimension+2,/long)	; size vector
   readu, unit, arr_size			; read size vector
   type=arr_size(n_elements(arr_size)-2)	; detemine data type
;
   structure=structure + ',' + tagnames(tag) + ':' 
   if type ne 8 then begin 
      structure = structure + fmt_tag([n_dimension,arr_size]) 
   end else begin	  
;
;     its a structure, so recursivly define via make str 
;;;      structure= structure + 'replicate({' + $
;;;          tag_names(build_str(unit,mainsize,struc=structure),/structure) + $
;;;		'},' + strcompress(string(arr_size(2))) +  ')'  
      if (n_dimension eq 2) and (arr_size(0) eq 1) then begin
	n_dimension = 1
	arr_size(0) = arr_size(1)
      end
      case n_dimension of
	1:  structure= structure + 'replicate({' + $
          tag_names(build_str(unit,mainsize,struc=structure),/structure) + $
		'},' + strcompress(string(arr_size(0))) +  ')'  
        2: structure= structure + 'replicate({' + $
          tag_names(build_str(unit,mainsize,struc=structure),/structure) + $
		'},' + strcompress(string(arr_size(0))) + ',' + strcompress(string(arr_size(1))) +  ')' 
	else: stop
      endcase 
   end
;
endfor 
;
structure=structure+'}' 
nested=str_lastpos(structure,':{build')	; find last structure in string 
;
; one structure level is complete - call make_str to generate data str.
if nested ne -1 then $ 
   nested=make_str(strmid(structure,nested+1,strlen(structure))) else $ 
      nested=replicate(make_str(structure),mainsize)
;
return,nested
end


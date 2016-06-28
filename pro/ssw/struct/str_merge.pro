function str_merge, str1_in, str2, nest_name=nest_name, down=down
;
;+
;   Name: str_merge
;
;   Purpose: merge (append) a new structure tag into an existing structure
;
;   Input Parameters:
;      str1 - top level structure (or vector of stuctures)
;      str2 - new structure to merge (becomes new tag of str1)
;
;   Optional Keyword Parameters:
;      nest_name - optional tag name (default is 1st 3 char of structure name)
;      down      - switch, if set, nest str1 (str1 and str2 at same level)
;
;   History: 30-Jun-93 (SLF) - Adapt 'make_str' to MDM str_merge logic
;	      7-Jul-93 (SLF) - allow vectors and assign values properly
;	      8-Jul-93 (MDM) - Corrected problem when STR2 was one element
;				and STR1 had several elements.
;	     28-Jul-93 (SLF) - allow non-structure tages
;	     29-Jul-93 (SLF) - 1 parameter option, down keyword (recursive)
;            20-Nov-02 (Zarro) - fixed potential IDL >5.4 structure array problem
;                                and duplicate tag names when using /nest
;   Calling Sequence:
;      newstr=str_merge(str1, str2 [,nest_name=nest_name, /down])
;
;   Calling Examples:
;      newstr=str_merge(str1,str2)	 ; str2 becomes new tag of str1
;      newstr=str_merge(str1)		 ; nests str1 one level down
;      newstr=str_merge(str1,str2,/down) ; same and then merges str2
;
;   Method: uses make_str to assure uniq structure names
;-
str1=str1_in			; don't clobber input 

sstr1=size(str1)
sstr2=size(str2)

if sstr1(sstr1(0)+1) ne 8 then begin
   message,/info,'First parameter must be a structure, returning...'
   return,-1
endif

; optionally nest str1 down one level (use 1 parameter option via recursion)
if keyword_set(down) then for i=0,down-1 do $
	str1=str_merge(str1)			; recurse to lower str1 level

name1=tag_names(str1,/struct)		; top level

; slf, 29-jul-1993 - added 1 parameter option (nest str1 down 1 level)
;----------------------------------------------------
if n_params() eq 1 then begin	
   newtag=strmid(name1,0,3)				; default tag name
   if keyword_set(nest_name) then newtag=nest_name  	; user's tag name
   outstr=make_str('{dummy,' + newtag + ':{' + name1 + '}}')
   outstr.(0)=str1					; copy values
;---------------------------------------------
endif else begin
   if sstr2(sstr2(0)+1) ne 8 then begin
      message,/info,'Second Parameter must be a structure, returning...'
      return,-1
   endif

   name2=tag_names(str2,/struct)		; structure to append (merge)
;  build the 'current' structure string definition for use by make_str
   tags=tag_names(str1)
   exestr='{dummy'
   for i=0,n_elements(tags)-1 do begin
      stag=size(str1.(i))
      case stag(stag(0)+1) of
      8: begin
            exestat=execute('strname=tag_names(str1.(' + strtrim(i,2) + ') ,/struct)')
            exestr=exestr + ',' + tags(i)+ ':{' + strname + '}'
         endcase
      else:   exestr=exestr + ',' + tags(i) + ':' + fmt_tag(stag)
      endcase      
   endfor

;  now append the new tag (structure) and 'close' the structure string
   newtag=strmid(name2,0,3)			; default tag name
   if keyword_set(nest_name) then newtag=nest_name  ; user supplied tag name

;-- ensure non-duplicate tag names
   
   chk=strpos(strlowcase(exestr),strlowcase(newtag)+':') gt -1
   if chk then newtag=newtag+'_'
   exestr=exestr+ ',' + newtag + ':{' + name2 + '}}'

;  use make_str to allocate uniq structure name
   outstr=make_str(exestr)

;  now copy tags to new structure 
   if n_elements(str1) gt 1 then outstr=replicate(outstr,n_elements(str1))
   for i=0,n_elements(tags)-1 do outstr.(i)=str1.(i)

;;outstr.(i) = str2	;MDM removed
;
   n1 = n_elements(str1)
   n2 = n_elements(str2)
   if (n1 ne n2) and (n2 ne 1) then begin
    message, 'If number of elements of STR1 and STR2 do not match, ', /info
    message, 'then there can only be one element in the second array.  Returning...', /info
    return, -1
   end

; ################# modified (ZARRO) ################


;   if (n1 eq n2) then outstr.(i) = str2 else outstr.(i) = replicate(str2, n1)


   if (n1 eq n2) then outstr.(i) = str2 else begin
    if (size(outstr.(i)))(0) eq 2 then begin
     tmp_outstr=outstr.(i)
     tmp_outstr(0,*) = replicate(str2, n1)
     outstr.(i) = tmp_outstr
    endif else outstr.(i) = replicate(str2, n1)
   endelse

; ################# modified ##################

endelse

return,outstr
end


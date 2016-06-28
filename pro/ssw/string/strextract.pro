function strextract, source, patt1, patt2, include=include
;+
;   Name: strextract
;
;   Purpose: extract substring between patt1 and patt2
;
;   Input Parameters:
;      source  - source string or string array 
;      patt1   - pattern 1
;      patt2   - pattern 2
;
;   Keyword Parameters:
;      include - if set, return substrings include patt1/patt2 (delimiters)
;
;   Calling Sequence:
;      substr=strextract(source, patt1, patt2)
;
;   Calling Examples:
;      IDL> print,strextract('this is a "test" of strextract','"','"')
;           test
;
;      IDL> print,strextract('<a href="file/junk.html"><b>descript</b>','"')
;           file/junk.html            
;      
;      IDL> print,strextract('<a href="file/junk.html"><b>descript</b>','"',/include)
;           "file/junk.html"
;
;
;   History:
;       16-dec-96 - S.L.Freeland - simplify common parsing function
;	28-May-97 - M.D.Morrison - Mod to send output out as scalar if 
;				   it is a single element
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;  Method: call ssw_strsplit  twice (implies vector inuput is fine)
;-
case n_params() of
   3:
   2: patt2=patt1
   else: begin 
      message,/info,"IDL> substring=strextract(source, pattern1, pattern2)  
      return,strarr(n_elements(source)>1)
   endcase
endcase

head=ssw_strsplit(source,patt1,tail=tail)       ; ssw_strsplit does the work
substr=ssw_strsplit(tail,/head,patt2)           ; once more on the 'tail'

if keyword_set(include) then begin                  ; reattach the delimiters
  ssgood=where(substr ne '',sscnt)                  ; where substring was found
  if sscnt gt 0 then $
      substr(ssgood)=patt1 + substr(ssgood) + patt2
endif

if (n_elements(substr) eq 1) then substr = substr(0)
return,substr
end

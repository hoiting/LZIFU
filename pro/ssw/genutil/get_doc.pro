function get_doc, modules , $
	quiet=quiet, full=full, summ=summ, print=print
;
;+
;   Name: get_doc
;
;   Purpose: retrieve a subset of idl header info. in a standard structure
;
;   Input Parameters:
;  	modules -  string or string array of idl module names
;
;   Output Paramters:
;     	function returns a vector of documentation structures
;   
;   Optional Keyword Parameters:
;       quiet - if set, no output (just return documentation structures)
;       summ  - if set, brief output (fmt_doc(doc_str)) - default
;       full  - if set, full header is printed
;
;
;   Method:
;	calls get1doc for each element of modules
;
;   Calling Sequence: docstrs=get_doc(modules)
;
;-
quit=0
quiet = keyword_set(quiet)
brief = keyword_set(summ)
full  = (brief or quiet) eq 0

modn=-1
repeat begin
   modn=modn+1
   nextdoc=get1doc(modules(modn),head=head)
endrep until str_is(nextdoc) or modn eq n_elements(modules)-1

if str_is(nextdoc) then begin
   docstrs=[nextdoc]
   while modn lt n_elements(modules) and not quit do begin
      case str_is(nextdoc) of
         brief: moreidl,fmt_doc(nextdoc,/lf),quit
         full:  moreidl,head, quit
         else:
      endcase
      ans = get_kbrd2(0)                        ; Get a character
      quit=strupcase(strmid(ans,0,1)) eq 'Q'
      if (ans ne ''  and not quit) then ans = get_kbrd2(1)
      quit=strupcase(strmid(ans,0,1)) eq 'Q'
      nextdoc=get1doc(modules(modn), print=print,head=head)
      if str_is(nextdoc) then docstrs=[docstrs,nextdoc]
      modn=modn+1
   endwhile
endif else begin
   message,/info,'No valid idl files in input'
   docstrs=''
endelse

return, docstrs
end

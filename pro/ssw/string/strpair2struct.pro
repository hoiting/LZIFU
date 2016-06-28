function strpair2struct, strings, delim
;+
;   Name: strpair2struct
;
;   Purpose: convert string array of field/value pairs to structure
;
;   Input Parameters:
;       strings - string array of pairs or file name containing same
;       delim   - optional field/value delimiter (default="=")
;      
;   Output Parameters:
;      function returns structure of form:
;           {xx, tag1:val1 [,tag2:val2, tag2:val3 ... tagNN:valNN] }
;
;   Keyword Parameters:
;      delim - field/value delimiter (default is blank)

;   Calling Sequence:
;      struct=strpair2struct(strings [,delim=delim] )
;
;   Example:
;      help,strpair2struct(['one=1','two=2','name=xxx']),/struct
;		** Structure MS_205021778009, 3 tags, length=24:
;		   ONE             STRING    '1'
;		   TWO             STRING    '2'
;		   NAME            STRING    'xxx';    
;
;   Method:
;      use ssw_strsplit, rd_tfile, & make_str to do dirty work
;
;   Catagory:
;      programming, system, WWW
;
;   History:
;      25-June-1996 - S.L.Freeland (originally for environment via CGI)
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-

if not keyword_set(delim) then delim='='		  ; environ default

if not data_chk(strings,/string) then begin		  ; need string input
   message,/info,"Need string array or file name...
   return,''
endif

if n_elements(strings) eq 1 and file_exist(strings(0)) $  ; file name input?
   then instr=rd_tfile(strings(0)) else instr=strings	  ;  if so, read file

field=ssw_strsplit(instr, delim, tail=value)	          ; split field/values

struct=make_str('{dummy,' + arr2str(field+":''") + '}')   ; make structure
for i=0,n_tags(struct)-1 do struct.(i)=value(i)		  ; fill structure

return,struct
end

function table2struct, table, names, $
	format=format, nocomment=nocomment, strtemplate=strtemplate
;+
;   Name: table2struct
;
;   Purpose: convert ascii table data to structure - optionally read file
;     
;   Input Parameters:
;      table - table data - string array OR ascii file name (ala rd_tfile)  
;      names - (if FORMAT option used) optional list of tag names
;              (should map 1:1 to FORMAT data )
;              (names can be an array or a comma delimited scalar string)
;                
;   Output Parameters:
;      function returns structure converted version of ascii table
;  
;   Keyword Paramters:
;      FORMAT - format string describing one line (SIMPLE ONLY FOR NOW)
;               A, I , F, and D formats are mapped->structure tags
;      STRTEMPLATE - (instead of FORMAT) template structure to use 
;      NOCOMMENT - comment delimiter (';', '#', etc)
;                  (scalar, array or comma delimited list)
;
;   Calling Sequence:
;      table_structure=table2struct(tabledata [,names=names] , format='(XXXX)',$
;                                   nocomment='c1,c2...cn')
;   OR
;      table_structure=table2struct(tabledata, strtemplate={template}, $
;                      nocomment=comment_characters )
;
;   Calling Example:
;      Let's say you have a file named 'table.dat' table which looks like...
;       --------------------------------
;      ; Comment 1
;      ; Comment 2
;      ; Comment N
;      ;
;       1996  02  01   123.12  [other stuff]  ; partial comment line OK
;       1997  05  15   456.21  [other stuff]  
;       1997  09  25   107.33  [other stuff]  
;      ; embedded comments   ok
;      ; arbitrary number of data lines ...(etc)..
;       1998  01  13  2012.11  [other stuff]  
;       --------------------------------
;      You can read/convert into a vector of structures (just dates in this ex)
;  
;      ------------------ CALL -----------------------
;      IDL> tstruct=table2struct('table.dat', nocomment=';', $      ; FILE
;                            'year,month,day,data', $               ; NAMES
;                            format='(1x,i4,2x,i2,1x,i2,2x,f7.2)' ) ; FORMAT
;      ------------------------------------------------
;
;      --- here is what the above call returned for the file above ---
;      IDL> help,tstruct & help,tstruct,/str
;      TSTRUCT         STRUCT    = -> MS_246991521002 Array(4) ; <<< 1 per line
;      ** Structure MS_246991521002, 4 tags, length=16:
;         YEAR            LONG              1996                 
;         MONTH           LONG                 2
;         DAY             LONG                 1
;	  DATA            FLOAT           123.120
;       --------------------------------
;	    
;   History:
;      23-Oct-1997 - S.L.Freeland based on G.L.Slater suggestion/requirements
;      24-Oct-1997 - S.L.Freeland - document, call 'strnocomment' 
;                                   (remove comments and null lines)
;      17-Nov-1997 - Allow NOCOMMENT to be array or comma delimited list
;                    Add STRTEMPLATE keyword and function
;      18-nov-1997 - Allow multiple file handling (filename vector)
;  
;   Restrictions:
;     FORMAT or STRTEMPLATE currently required (describes layout of typical line)
;     Groups (imply array tag) not yet handled (would use call to fmt_tag.pro) 
;     Not much error checking - assumes all lines are uniform
;     If multiple file name input, assume all files have like structure
;-  

retval=''
; ---------------- check input ----------------------
if (1-data_chk(table,/string)) or $
   ( 1-keyword_set(format)  and 1-data_chk(strtemplate,/struct)) then begin
   prstr,strjustify(['Need a table or an ascii file & a format string', $
     'IDL> tablestr=table2struct(file,  [names,] format="(yourformat)"' ],/box)
   return,retval
endif

itable=table                                              ; dont clobber input
; -------- if input is file or file list, read the files --------
if file_exist(itable(0)) then begin
   itable=rd_tfile(itable(0 ))
   for i=1,n_elements(table)-1 do itable=[itable,rd_tfile(table(i))]
endif
   
case 1 of 
    data_chk(nocomment,/string,/scalar): commchar=str2arr(nocomment) ; list ok 
    data_chk(nocomment,/string): comcharr=nocomment                  ; arr ok
    else: commchar=''                                                ; default
endcase

; ----- remove comment lines (partial and full) and eliminate nulls ---
for i=0,n_elements(commchar)-1 do $
     itable=strnocomment(itable,comment=commchar(i), /remove_nulls)
; --------------------------------------------------------------------

ntab=n_elements(itable)
; --------------------------------------------------------------------

if data_chk(strtemplate,/struct) then newstruct=strtemplate else begin
   ; --------- convert format->data type via map_format.pro ---------------
   fmttypes=map_format(format(0))
   nftags=n_elements(fmttypes)

   ; define names if not passed in 
   if data_chk(names,/scalar,/string) then names=str2arr(names) 
   case 1 of
     nftags eq 0: begin
        message,/info,"Warning - no valid Format->Tag conversions"
        return,retval
     endcase     
     n_elements(names) eq n_elements(fmttypes): inames=names
     n_elements(names) gt 0: begin
         prstr,strjustify(["Mismatch betwwen NAMES and FORMAT list", $
   	     'Using generated tag names'],/box)
         inames="t2s_"+ string(indgen(nftags),format='(i3.3)')   
     endcase      
     else: inames="t2s_"+ string(indgen(nftags),format='(i3.3)')   
   endcase
   ; --------------------------------------------------------------------
   ; ----- construct dynamic structure and generate via make_str--------
   strstring='{dummy,'+ arr2str(inames +':' + fmttypes) + '}'
   newstruct=make_str(strstring)
endelse
; --------------------------------------------------------------------

; --------- make one per record and read->convert via reads ----------
retval=replicate(newstruct, n_elements(itable))   ; make enough structures
if data_chk(format,/string) then  reads, itable, retval, format=format $
    else reads, itable, retval
; --------------------------------------------------------------------

return,retval
end

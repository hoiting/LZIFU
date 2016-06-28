function strarrinsert, strdest,strsource,d1,d2,quiet=quiet, $
   first=first, last=last , multi=mult, status=status, deldelim=deldelim, $
   debug=debug
;+
;   Name: strarrinsert
;
;   Purpose: insert/replace one text array into/by another at specifed delimiter
;
;   Input Parameters:
;      strdest   - destination string/text array 
;      strsource - source - string/text array to be inserted->strdest
;      d1 - optional delimeter - string pattern -> target for insertion
;           (default is first line of <strdest> )
;      d2 - optional last delimiter - in this case, text strdest(d1:d2)
;           is REPLACED  by strsource
;
;   Keyword Parameters:
;      first,last,multi - in case of multple delimiter matches, these
;                         EXCLUSIVE switches direct which one to use
;      deldelim - if set, line with delimiter is replaced/deleted
;      status - insertion/replacement success? 1=OK, 0=NOT OK
;      quiet  - if set, suppress status messages
;
;   Calling Sequence:
;      newtext=strarrinsert(oldtext,newarray [,d1 , d2, /first,/last,/multi]
;
;   Calling Example:
;     newhtml=strarrinsert(curhtml,newhtml,'<!** insert here **>')
;
;     ---- Example - Replace documentation header in ROUTINE  ---
;     newrout=strarrinsert(rd_tfile(routine),newdoc,';+',';-',status=status)
;     if status then file_append,routine,newrout
;     ------------
;
;   Illusrations:
;   IDL> print,strarrinsert(['a','b','c','d'],['one','two'],'c')    ; << insert
;        a b c one two d
;   IDL> print,strarrinsert(['a','b','c','d'],['one','two'],'a','d') ;<< replace
;        a one two d
;
;   History:
;     12-Jun-1997 - S.L.Freeland - simplify common text/html functions
;
;-
;
status=0
if (1-data_chk(strdest,/string)) or (1-data_chk(strsource,/string)) then begin
   message,/info,"IDL> newarr=strarrinsert(strdest,strsource [,d1,d2]"
   if n_elements(strdest) eq 0 then strdest=''
   return,strdest
endif

npar=n_params()

debug=keyword_set(debug)
loud=1-keyword_set(quiet)
deldel=keyword_set(deldelim) or npar lt 3

if not keyword_set(d1) then d1 = strsource(0)     ; default is first line
d1=d1(0)
if n_elements(d2) eq 0 then d2=d1

ssd1=where(strpos(strdest,d1) ne -1,d1cnt)
ssd2=where(strpos(strdest,d2) ne -1,d2cnt) 

case 1 of 
   d1cnt eq 0: begin 
      if loud then message,/info,"Delimiter " + d1 + " not found, returning"
      return,strdest
   endcase
   d1cnt eq 1: ssd1=ssd1(0)
   keyword_set(first): ssd1=ssd1(0)
   keyword_set(last):  ssd1=ssd1(d1cnt-1)
   keyword_set(multi): 
   else: begin
      if loud then message,/info,"Multiple delimiters - must use /first,/last or /multi"
      return,strdest
   endcase
endcase

ssd1=ssd1-([0,1])(deldel)
      
if d2cnt eq 0 then begin
    if loud then message,/info,"Could not find end delimiter,  returning...
    return,strdest
endif

ssd2=( [([ssd2,ssd2+1])(deldel),ssd1+1])(npar lt 4) + ([0,1])(deldel)
if debug then stop

newtext=[strdest(0:ssd1),strsource]
if ssd2 lt n_elements(strdest) then newtext=[newtext,strdest(ssd2:*)]
status=1
   
return,newtext
end


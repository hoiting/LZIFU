function gt2exe, input, addind=addind, gtfunctions=gtfunctions, $
   noss=noss, debug=debug, noind=noind, range_delim=range_delim, $
   string_fields=string_fields, fold_case=fold_case
;+
;   Name: gt2exe
; 
;   Purpose: convert gt function shorthand to valid calls (for use w/execute)
;
;   Input Parameters:
;      input - string of form "<item> <relation> <value>"
;              <item>     = function name OR structure/fits field
;                           {filta, filtb, expmode, dpe, percentd, etc}
;              <relation> = { = , >, <, >=, <=, <>}
;              <value>    = value, list (ex: 1,2,5) or range (ex: 4~10)
;   Keyword Parameters:
;      string_fields - optional list of variables which should be
;      treated as strings
;               
;   Examples:
;      IDL> print,gt2exe('dpe=[12~20]',/addind)
;      IDL> gt_dpe(index(ss)) ge 12 AND gt_dpe(index(ss)) le 20
;
;      IDL> print,gt2exe('filta=[2,5]', /addind)
;      IDL> gt_filta(index(ss)) eq 2 OR gt_filta(index(ss)) eq 5
;      IDL> print,gt2exe('crpix1=[256,512,1024]')
;           gt_tagval(index(ss),/crpix1) eq 256 OR
;           gt_tagval(index(ss),/crpix1) eq 512 OR
;           gt_tagval(index(ss),/crpix1) eq 1024
;
;   History:
;      Circa jan-93 (S.L.Freeland) - for spd files
;      22-mar-1995  (SLF) - add range and list (expanded for obs searches)
;      13-jan-1998  (SLF) - make unmapped functions a call to 'gt_tagval'
;                           made ADDIND the default
;      26-Feb-1998  (SLF) - define some default strings (ssw standards)
;      22-apr-1998  (SLF) - added some stuff
;                           if value includes wild card/?? use wc_where  
;      13-May-1998  (SLF) - add RANGE_DELIM and made default= '~'
;       8-Sep-1998  (CED) - Add '==' as synonym for 'eq'
;       8-Sep-1998  (SLF) - &&/AND and ||/OR recursion
;      20-Jan-1999  (SLF) - remove 'percentd' from gt_xxx list
;      21-apr-2005  (SLF) - add string_fields keyword + function
;                           add auto addition of non-numbers to string algorithm
;      28-sep-2006 (SLF) - use strmatch for strings, protect against seaarch strings which
;                          include embedded reserve words (like, Gband and for for example...)
;      30-may-2007 (SLF) - add FOLD_CASE (-> strmatch for strings)
;                                                                  ^^^      ^^
;-
; map shorthand name to standard functions 'gt_xxx, gtt_yyy'
; TODO - get these from a file (derive from sswloc file)
gt_functions=str2arr('expmode,dp_mode,filta,filtb,res,dpe,comp')
gtt_functions=str2arr('trace_expdur,trace_res')
gt_stringf=str2arr('wave_name,wave_len,sci_obj,cmp_id,frm_nam,obs_prog,seq_nam,seqid,object,telescop,telescope')
if data_chk(string_fields,/string) then gt_stringf=[gt_stringf,string_fields]

if keyword_set(gtfunctions) then return,'gt_' + gt_functions

debug=keyword_set(debug)

; check for booleans
ubools=' ' + ['&&','and','||','or'] + ' '
bequiv=str2arr('AND,AND,OR,OR')
bequiv=' ' + bequiv + ' ' 

for i=0,n_elements(ubools)-1 do begin
  bpieces=str2arr(input,ubools(i))
  np=n_elements(bpieces)
  if np gt 1 then begin
    retval='(' + gt2exe(bpieces(0)) + ') ' 
    for p=1,np-1 do retval=retval + bequiv(i) + '(' + gt2exe(bpieces(p)) + ')'
    return,retval
  endif
endfor

; define boolean/symbolic translations
log_operators=	['>=','<=','<>' ,'==','<', '>', '=']
bool_equiv   =  ' ' + ['ge','le','ne' ,'eq','lt','gt','eq'] + ' '  ;blank padded

tinput=strcompress(input,/remove)				; protect input
tinput=str_replace(tinput,'gt_','')	; remove gt root if it is there
					; already (handle both ways)

ind=['','index(ss)'] & str=['',',/string']
case 1 of
   data_chk(addind,/string): index=addind
   keyword_set(noind):index=''
   else: index='index(ss)'
endcase

for i = 0, n_elements(log_operators)-1 do $
   tinput=str_replace(tinput,log_operators(i), bool_equiv(i))

tinput=strcompress(strtrim(tinput,2))	; elminate extraneous blanks

; brackets are optional for list and range values - eliminate them
tinput=str_replace(tinput,'[','')
tinput=str_replace(tinput,']','')

; break the input (<item><relationship><value>)
tinput=str2arr(tinput,' ')
if n_elements(tinput) ne 3 then begin
   box_message,["Illegal format for input, - need a relational opertor",$
		"IDL> exestr=gt2exe('<item> <relation> <value>')"]
   return,tinput
endif

; check for list syntax (ex: [1,4,6]) 
list=where(strpos(tinput,',') ne -1,lcnt)	; comma delimited
if lcnt gt 0 then tinput= $
   arr2str(tinput(0) + ' ' + tinput(1) + ' ' + str2arr(tinput(2)),' OR ')

; expand ranges ex: [1-5] -> ge low AND le hi
if not keyword_set(range_delim) then range_delim='~'
range=where(strpos(tinput,range_delim) ne -1,rcnt)	; dash delimited

if rcnt gt 0 then begin
   rng=str2arr(tinput(range),range_delim)   
   tinput= tinput(0) + ' ge ' + rng(0) + ' AND ' + $
           tinput(0) + ' le ' + rng(1)
endif

tinput=str_replace(arr2str(tinput,' '),' (','(')

efunc=(strmids(tinput,0,strpos(tinput,' ')))(0)

case 1 of
   is_member(efunc,gt_functions):  tinput=str_replace(tinput,efunc,'gt_'+efunc+'('+ index)
   is_member(efunc,gtt_functions): tinput=str_replace(tinput,efunc,'gtt_'+efunc+'('+index)
   strpos(efunc,'(') ne -1: 
   else: tinput=str_replace(tinput,efunc,'gt_tagval('+index+',/'+efunc)
endcase   

efunc=(strmids(tinput,0,strpos(tinput,' ')))(0)

if strpos(efunc,'(') ne -1 and strmid(efunc,strlen(efunc),1) ne ')' then $
   tinput=str_replace(tinput,efunc,efunc+')')

if keyword_set(noss) then tinput=str_replace(tinput,'(ss)','')
pieces=str2arr(tinput,' ')
np=n_elements(pieces)
for i=0,np-1,4 do begin
  if total(is_member(strtrim(bool_equiv,2),pieces(i+1))) gt 0 then begin
     funct=strextract(pieces(i),'/',')')
     if total(is_member(gt_stringf,funct,/ignore_case)) gt 0  or (1-is_number(pieces(i+2))) then begin
   ;     pieces(i+2)=str_replace(str_replace(pieces(i+2),'*',''),'?','')
   ;     pieces(i)="strpos(strupcase("+pieces(i)+"),strupcase('"+pieces(i+2)+"'))"
         pieces(i)="strmatch("+pieces(i)+",'"+pieces(i+2)+"',fold_case=fold_case)"
	pieces(i+1:i+2)=['eq','1']
      endif 
   endif 
endfor  

if debug then stop
tinput=arr2str(pieces,' ')

return,tinput

end      




function struct_where, structures, count, test_array=test_array, $
    conf_file=conf_file, quiet=quiet, debug=debug,  gtarr=gtarr, $ 
    search_array=search_array, $
    _extra=_extra, fold_case=fold_case
;+
;   Name: struct_where
;
;   Purpose: filter a structure array; return SubScripts which satisfy
;
;   Input Parameters:
;      structures - The structure vector to match
; 
;   Output Parameters:
;      count - number of matches
;
;   Keyword Parameters:
; 	test_array  - string array containing the tag tests
;       search_array - synonym for 'test_array', maybe more intuitive 
;       conf_file   - name of configuration file (instead of test_array)
;       quiet 	  - if set, suppress messages
;	gtarr     - Debugging variable that gets a list of the
;			expressions executed
;	debug	  - Cause struct_where to stop before returning
;        
;
;   Calling Sequence:
;        ss=struct_where(structures [,count], conf_file=FILENAME)
;   -OR- ss=struct_where(structures [,count], test_array=test_array)
;   -OR- ss=struct_where(structures [,count], search_array=search_array) 
;
;   Examples:
;      the contents of CONF_FILE or TEST_ARRAY or SEARCH_ARRAY are of the form:
;         <TAG> <OPERARTOR> <VALUE>
;      For example, a conf_file might contain:
;         --------------------------------------------
;         ; you can include free-form comments using ';' delimiter
;         NAXIS1 = 512,1024                ; Lists (comma delimited)
;         IMG_MIN > 1.                     ; Single value (boolean)
;         WAVE_LEN = 171,195,284           ;
;         XCEN=600.~800.                   ; Range (tilde separated)
;         IMG_AVG > 100 && IMG_MAX < 4096  ; Compound Boolean
;         -------------------------------------------
;     The function output would then contain the subscripts of STRUCTURES which
;     meet all the the criteria
;     See function <gt2exe.pro> for more details on the accepted strings.
;
;   History:
;       2-Feb-1998 - S.L.Freeland - wrote trace_where (adapt sxt_where to TRACE)
;	7-Sep-1998 - C.E. DeForest- adapt trace_where to the general case
;      24-Sep-9998 - S.L.Freeland - Documentation, some error checking
;      26-sep-2005 - S.L.Freeland - add _extra -> gt2exe.pro
;      28-sep-2006 - S.L.Freeland - add SEARCH_ARRAY synonym for TEST_ARRAY
;      30-aug-2007 - S.L.Freeland - added FOLD_CASE (-> gt2exe.pro)
;       4-oct-2007 - S.L.Freeland - oops; gt2exe2 -> gt2exe
; 
;   Calls:
;      gt2exe, gt_tagval, rd_tfile, data_chk
;-
loud=1-keyword_set(quiet)
debug=keyword_set(debug)

if not data_chk(structures,/struct) then begin 
      box_message,[ $
        'IDL> ss=struct_where(structures [,count], conf_file=FILENAME)', $
         '    -OR-', $
        'IDL> ss=struct_where(structures [,count], test_array=test_array)']
    return,-1
endif

index = structures

deffile=concat_dir(get_logenv('HOME'),'ss.config')   ; backward compatible

case 1 of 
   data_chk(test_array,/string): input=test_array
   data_chk(search_array,/string): input=search_array
   data_chk(conf_file,/scalar,/string): begin
      if file_exist(conf_file) then $
         input=rd_tfile(conf_file,/compress,nocomment=';') else begin 
            box_message,['Configuration file: ' + conf_file + ' not found']
            return,-1
         endelse
   endcase
   file_exist(deffile): begin
      input=rd_tfile(deffile,/compress,nocomment=';')
      box_message,['Using default config file: ' + deffile, '   ' + strupcase(input)]
   endcase
   else: begin
      box_message,'Must supply either CONF_FILE or TEST_ARRAY'
      return,-1
   endcase
endcase


sss=(where(strpos(input,'begin_ss') ne -1,s0cnt))(0)
if s0cnt eq 0 then sss=0 else sss=sss+1

sse=(where(strpos(input,'end_ss') ne -1, s1cnt))(0)
if s1cnt eq 0 then sse=n_elements(input) else sse=sse-1

gtarr=''
if sse gt sss then begin
   ss=lindgen(n_elements(index))
   ssn=sss
   repeat begin
      sscond=input(ssn)					; conditional string
      sscond=gt2exe(sscond,/addind,_extra=_extra,fold_case=fold_case)
      gtarr=[gtarr,sscond]
      extstr='ssnew=where(' + sscond + ',sscnt)'
      if loud then print,"FILTER>> " + extstr
      exestat=execute(extstr)
      if sscnt gt 0 then ss=ss(ssnew)
      ssn=ssn+1
      if debug then stop
    endrep until sscnt eq 0 or ssn ge sse
endif
count=0

if ssnew(0) ne -1 then count=n_elements(ssnew) else ss=-1

if debug then stop

return, ss

end

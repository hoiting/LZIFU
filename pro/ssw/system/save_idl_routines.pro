pro save_idl_routines, routines, pattern=pattern, loud=loud, $
       file=file, outdir=outdir, name_only=name_only, $
       date=date, nodate=nodate, $
       functions_only=functions_only, pros_only=pros_only
;+
;   Name: save_idl_routines
;
;   Purpose: save selected subset of IDL routines to binary file (pre-compiled)
;
;   Input Parameters:
;      routines - optional list of routines - default=ALL or via PATTERN match)
;
;   Output Parameters:
;      NONE:
;
;   Side Effects: writes a binary file containing desired IDL routines
;                 [restore via 'restore_idl_routines' with same settings
;                  of optional PATTERN='*xxx', /NODATE, and OUTDIR='dir' ]
;
;   Keyword Parameters:
;      pattern - string pattern to match (wild cards ok)
;      loud - if set, be more verbose
;      date - if (switch set) include todays date YYYYMMDD in default file name
;             if (otherwise defined), anytim.pro compat; use that YYYYMMDD
;             if (undefined or /NODATE) date not included in filename
;
;      file - save file name - 
;             Default: 'idl_routines_Rx[xx]_USER_[PATTERN][_YYYYMMDD].save'
;                                    |Release
;      outdir - output directory - Default> $HOME
;      name_only - if set, just form filname FILE and return 
;                  (for example, for use by restore_idl_routines.pro)
;      functions_only - if set and PATTERN set, just consider Functions
;      pros_only -      if set and PATTERN set, just consider Procedures
;
;   Calling Sequence:
;      IDL> save_idl_routines,pattern='xxx*'  ; save routines with prefix xxx
;      IDL> save_idl_routines,pattern='*xxx'  ;                                         
;
;   History:
;      18-October-1999 - S.L.Freeland; simplify/control call to save,/routine
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;   Restrictions:
;      Version > 4.
;
;   Notes:
;      If PATTERN includes wild cards (* or ?), the default file name
;      will include an escaped versions for valid file name construction
;      The original pattern used (inc wild cards) can be seen via 
;      ORIG=id_unesc(file)
;
;   Suggestions: suggest you take the default name for traceability 
;                and compatibility use with 'restore_idl_routines.pro'
;                (use /NODATE or /DATE and OUTDIR='xxx' for some flexibility)
;-

loud=keyword_set(loud)
nodate=keyword_set(nodate) or (1-keyword_set(date))      ; default=NODATE
name_only=keyword_set(name_only)

if not since_version(4) then begin 
   box_message,'Sorry,need newer IDL release...
   return
endif

if not data_chk(pattern,/scalar,/string) then begin
   pattern=''
   spat=''
endif else spat=id_esc(pattern)   ; escape any wild cards in PATTERN 

if not data_chk(outdir,/scalar,/string) then outdir=get_logenv('HOME')
if name_only then delvarx,file     

; ----------------- define the default save file name ------------
release=strcompress(str_replace(strtrim(!version.release,2),'.',' '),/rem)
defname='idl_routines_R' + '_' + release + '_' + $
         get_user() + (['_',''])(spat eq '') + spat 

case 1 of 
   data_chk(date,/type) ge 7: yymmdd='_'+time2file(anytim(date) ,/date_only)  
   n_elements(date) gt 0:     yymmdd='_'+time2file(reltime(/now),/date_only)
   else:                      yymmdd=''
endcase

defname=defname + yymmdd + '.save'
; ------------------------------------------------------------

if not data_chk(file,/scalar,/string) then file=(concat_dir(outdir,defname))(0)

if keyword_set(name_only) then begin 
   if loud then box_message,'/NAME_ONLY set; Just returning file name in FILE
   return
endif

if pattern ne '' then begin 
;  ------- save procedures, functions, or all --------
   help,/routine,output=output                     
   procs =(where(strpos(output,'Procedures:') ne -1, pcnt))(0)
   functs=(where(strpos(output,'Functions:')  ne -1, fcnt))(0)
   plist=strarrcompress(ssw_strsplit(output(procs+1:functs-1),' '))
   flist=strarrcompress(ssw_strsplit(output(functs+1:*),' '))
;  ----- above could use RSI <routine_info>  calls in versions >5.2 

   case 1 of 
      keyword_set(functions_only): rlist=flist
      keyword_set(pros_only):      rlist=plist
      else:                        rlist=[flist,plist]    ; default both
   endcase
 
   case 1 of
      total(strspecial(pattern)) gt 0: $
            ss=wc_where(rlist,pattern,/case_ignore,mcount)
      else: ss=where(strpos(strupcase(rlist),strupcase(pattern)) ne -1, mcount)
   endcase

   if mcount eq 0 then begin 
      box_message,'No complied routines matching pattern: <' + pattern + '>, re$
      return
   endif

   routines=rlist(ss)
endif 
   
savecmd="save, /routines, file='"+file+"'"
if data_chk(routines,/string) then $
   savecmd=(savecmd+','+arr2str("'"+routines+"'"))(0)
      
if loud then prstr,['------------ executing -----------', $
                    'IDL> '+ savecmd, $
                    '----------------------------------']
esat=execute(savecmd)
   
if not file_exist(file) then box_message,'Problem with save...'

return
end

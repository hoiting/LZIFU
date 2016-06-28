pro set_logenv, logenv, value, file=file, check_log=check_log, quiet=quiet, debug=debug, $
	nocomment=nocomment, keyword=keyword, node=node, $
        envlist=envlist
;
;+
;   Name: set_logenv
;
;   Purpose: set environmental variable (unix) and logicals (vms)
;            (allow dynamic updates of Yohkoh environment)
;
;   Input Paramters:
;      logenv - string or string vector - unix environ or vms logical names
;      value  - string or string vector - values to assign to logenv
;
;   Calling Examples:
;
;      set_logenv,'DIR_GEN_PNT',curdir()	  ; redefine PNT to current
;
;      set_logenv,file=concat_dir('$DIR_SITE_SETUP','setup_dirs')
;
;   Calls:
;      set_logvms, data_chk
;   Keyword Parameters:
;      file - string (scaler/vector) of file names to process
;             files are expected to be two or three column tables containing
;	      logical/environmental information - embedded comments are ok
;	      if # is used for unix and ! for vms (readable by rd_tfile.pro)
;	       NCOLS
;	         2: first column are logicals/environmentals
;		    second column are values to assign (ie, table)
;		 3: first column is ignored (example ('setenv' or 'define')
;		    second and third columns are interpreted as logs/envs
;		    and values to assign, respectively.
;		    (This option allows direct processing of Yohkoh
;		    (files like setup_dirs and setup_ysenv)
;	       When file is a vector, they are processed in order so
;	       logs/envs defined in multiple files get the final assignment
;	       from the last reference.
;      CHECK_LOG - If set, logicals are set only if they are undefined.
;      KEYWORD   - In array mode, a string array the same length as logenv
;                  with unique subtrings of the <setlog> keywords:
;                  'conc[ealed]','conf[ined]','no_a[lias]','te[rminal]'
;      NODE      - The decnet node number, e.g. '15886::' to add, default ''
;
;   History:
;      27-Apr-1993 (SLF) - For dynamic relocation/additon of pointers
;      30-Apr-1993 (SLF) - improved file option / parameter validation
;      16-May-1994 (SLF) - fixed type in vms code
;      20-jun-1996 (SLF) - permit multi-valued environmentals in file mode
;      08-jul-1996 (RAS) - handles vms through set_logvms
;      14-jul-1998 (SLF) - add /envlist (simulate search list under unix)
;                          allow nested environmentals (one level
;      28-May-1999 (RDB) - reordered code to case statement so could
;                          handle windows through set_logwindows
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;   Restrictions:
;      Can't specify both array and file
;      Not all VMS setlog options are available
;      Nesting environmentals only 1 level deep - should recurse till done
;-


case strlowcase(!version.os_family) of

'vms': $
   set_logvms, logenv, value, file=file, check_log=check_log, quiet=quiet, debug=debug, $
        nocomment=nocomment, keyword=keyword, node=node

'windows': $
   set_logwindows, logenv, value, file=file
;, check_log=check_log, quiet=quiet, debug=debug, $
;        nocomment=nocomment, keyword=keyword, node=node

else: begin
  if not keyword_set(nocomment) then nocomment=1
  debug=keyword_set(debug)
  fileing=keyword_set(file)
  if fileing then begin
     if n_params() ne 0 then begin
        message,/info,"Can't use both FILE keyword and array parameter, returning...
        return
     endif else begin                        ; convert files to (2xN) array format
        logenv=''
        value=''
        for i=0,n_elements(file)-1 do begin
           onef=rd_tfile(file(i),nocomment=nocomment,/compress)
           setenvs=where(strpos(strlowcase(onef),'setenv ') eq 0,ecnt)
           if ecnt gt 0 then begin
              sslog=setenvs(where(setenvs ne -1))
              onef(sslog)=strmid(onef(sslog),7,max(strlen(onef(sslog))))

              logf=ssw_strsplit(onef(sslog),tail=valuef)                ; split
              logenv=[logenv,logf]
              value =[value, valuef]
           endif
        endfor
        if n_elements(logenv) eq 1 then begin
           message,/info,'No valid files!!, returning...'
           return
        endif else begin
           logenv  =logenv(1:*)
           value   =value(1:*)

        endelse
     endelse
  endif
  ;
  ; check for valid input (or file derived) array)

   valid=data_chk(logenv,/string) and $
          data_chk(value,/string)
   qtemp=!quiet
   !quiet=keyword_set(quiet)

   if valid then begin
       if keyword_set(envlist) then begin
         sslist=where(strpos(value,',') ne -1,lcnt)              ; list??
         for i=0,lcnt-1 do begin
            list=strtrim(str2arr(value(sslist(i))))             ; break
            exist=where(file_exist(list),ecnt)                  ; search
            if ecnt gt 0 then value(sslist(i))=list(exist(0))   ; assign
        endfor
      endif
;   ----------------- script->idl strings ------------------
;   eliminate embedded string delimiters                    ;** Verify **
    special=(['"',"'"])
    for i=0,n_elements(special)-1 do begin
       sss=where(strpos(value,special(i)) ne -1, ssscnt)
       if ssscnt gt 0 then value(sss)=str_replace(value(sss),special(i))
    endfor

;   ------ translate environmentals in string ---------         ; recursive?
    ssenv=where(strpos(value,'$') ne -1, envcnt)
    for i=0,envcnt-1 do begin
       envarr=strtrim(str2arr(value(ssenv(i)),' '),2)
       if n_elements(envarr) eq 1 then $
           envarr=strtrim(str2arr(value(ssenv(i))))
       tenv=get_logenv(envarr)
       sstenv=where(tenv ne '',sscnt)
       if sscnt gt 0 then envarr(sstenv)=tenv(sstenv)
       value(ssenv(i))=arr2str(envarr,' ')
    endfor
;   -------------------------------------------------------------------


;   generate required setenv command vector
    setcmds=logenv + '=' + value
    for i=0,n_elements(setcmds)-1 do begin
       setenv,setcmds(i)
       message,/info,'setenv,' + setcmds(i)
    endfor

  endif else message,/info,'Input arrays/file must contain string vector or tables

  !quiet=qtemp

end

endcase

end

function resolve_variable,var

;   resolve variables used in filenames


val = var
;       quote marks seem to get in the way; replace with spaces and tidy
val = str_replace(val,'"',' ')
val = str_replace(val,"'",' ')
val = str2arr(strtrim(strcompress(val),2),"/")
;;val = str2arr(strcompress(var,/remove_all),"/")

m = where(strpos(val,"$") ne -1,cnt)
if cnt ne 0 then begin
   for i=0,cnt-1 do begin
      new_val = get_logenv(val(m(i)))
      if strpos(new_val,"$") eq -1 then begin
         if new_val ne '' then val(m(i)) = new_val
      endif else begin
         res = execute('val(m(i)) = resolve_variable(new_val)')
         if res ne 1 then box_message,'** Env. Var. problem: '+new_val
      endelse
   endfor
endif

v = arr2str(val,"/")

return,v
end

;;---------------------------------------------------------------------------------

pro set_logwindows, logenv, value, file=file, debug=debug
;
;+
;   Name: set_logwindows
;
;   Purpose: set logicals (windows)
;            (allow dynamic updates of Yohkoh environment)
;
;   Input Paramters:
;      logenv - string or string vector - windows, unix environ or vms logical names
;      value  - string or string vector - values to assign to logenv
;
;   Calling Examples:
;
;      set_logwindows,'DIR_GEN_PNT',curdir()          ; redefine PNT to current
;
;      set_logwindows,file=concat_dir('$DIR_SITE_SETUP','setup_dirs')
;
;   Calls:
;
;   Keyword Parameters:
;      file - string (scaler/vector) of file names to process
;             files are expected to be two or three column tables containing
;             logical/environmental information - embedded comments are ok
;             if # is used for unix and ! for vms (readable by rd_tfile.pro)
;              NCOLS
;                2: first column are logicals/environmentals
;                   second column are values to assign (ie, table)
;                3: first column is ignored (example ('setenv' or 'define')
;                   second and third columns are interpreted as logs/envs
;                   and values to assign, respectively.
;                   (This option allows direct processing of Yohkoh
;                   (files like setup_dirs and setup_ysenv)
;              When file is a vector, they are processed in order so
;              logs/envs defined in multiple files get the final assignment
;              from the last reference.
;      DEBUG     - If set, then information on the files used is displayed
;                  It may also be implemented by setting the symbol, debug to debug
;                  i.e. debug := debug
;   Restrictions:
;       WINDOWS only
;       Can't specify both array and file
;       ??
;   History:
;       30-May-1999 - R.D.Bentley - Adapted from code by H. Warren
;       18-Mar-2000 - R.D.Bentley - mod within resolve_vars in case not defined
;       27-Jul-2000 - R.D.Bentley - trap null env. var. definition files
;                                 - save defined vars. in common
;       28-Mar-2006 - Kim Tolbert - rd_tfile didn't handle columns correctly, use
;                                   str2cols to handle column-finding instead
;
;-

common logwin,setenv_str,ksetenv                ;used by pr_logwindows

if strlowcase(!version.os_family) ne 'windows' then begin
   message,/info,'Use for WINDOWS commands, only.'
   return
endif

if n_elements(setenv_str) eq 0 then begin
   setenv_str = strarr(2000)
   ksetenv = 0
endif

;       this may be a file containing many definitions
if keyword_set(file) then begin

;   print,file
   rqfile = resolve_variable(file)
   print,'Processing:   ',rqfile
   ;src     = rd_tfile(rqfile,/auto)
   src = str2cols (rd_tfile(rqfile, /nocomment, /compress), /unalign)


   if src(0) ne '' then begin
      n_items = n_elements(src(0,*))

      for n=0,n_items-1 do begin

         var = strcompress(src(1,n),/remove_all)
         val = arr2str(src(2:*,n),' ')     ;;;,/remove_all)
;       recursively resolve any $xxx variables...
         val = resolve_variable(val)

         str = var+"="+val
         setenv,str
         if keyword_set(debug) then print,"setenv,"+str
         setenv_str(ksetenv) = str & ksetenv=ksetenv+1

      endfor

   endif else print,"  *** Hmmm, this file doesn't have any records ***"

;       CASE of vectors???
;       otherwise, just set variable to supplied value
endif else begin

      var = strcompress(logenv,/remove_all)
      val = strcompress(value)    ;,/remove_all)
;       recursively resolve any $xxx variables...
      val = resolve_variable(val)

      str = var+"="+val
      setenv,str
      if keyword_set(debug) then print,"setenv,"+str
      setenv_str(ksetenv) = str & ksetenv=ksetenv+1

endelse

return
end

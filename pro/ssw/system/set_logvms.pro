pro set_logvms, logenv, value, file=file, check_log=check_log, quiet=quiet, debug=debug, $
	nocomment=nocomment, keyword=keyword, node=node
;
;+
;   Name: set_logvms
;
;   Purpose: set logicals (vms)
;            (allow dynamic updates of Yohkoh environment)
;
;   Input Paramters:
;      logenv - string or string vector - unix environ or vms logical names
;      value  - string or string vector - values to assign to logenv
;
;   Calling Examples:
;
;      set_logvms,'DIR_GEN_PNT',curdir()	  ; redefine PNT to current
;
;      set_logvms,file=concat_dir('$DIR_SITE_SETUP','setup_dirs')
;
;   Calls:
;      extract_vms_defs, data_chk
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
;                  'conc[ealed]','conf[ined]','no_a[lias]','term[inal]'
;      NODE      - The decnet node number, e.g. '15886::' to add, default ''
;      DEBUG     - If set, then information on the files used is displayed
;                  or written to the home directory in set_logvms.txt
;                  It may also be implemented by setting the symbol, debug to debug
;                  i.e. debug := debug
;   Restrictions:
;	VMS only
;   History:
;      08-jul-1996 (RAS) - Adapted from <set_logenv>
;	handles vms logical definitions, vms keywords to setlog
;                          multi-valued logicals
;      15-Aug-1996 (RAS) - debug keyword implemented
;      3-march-1996 ras, eliminate unix comment lines
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;   Restrictions:
;      Can't specify both array and file
;      Not all VMS setlog options are available
;
;-

if !version.os ne 'vms' then begin
	message,/info,'Use for VMS commands, only.'
	return
endif
if (size(node))(1) eq 0 then node = ''

if not keyword_set(nocomment) then nocomment=1
if n_elements(debug) eq 0 then debug =getenv('debug') eq 'DEBUG' 

filing=keyword_set(file) 
if filing then begin
   if keyword_set(value)  then begin
      message,/info,"Can't use both FILE keyword and array parameter, returning...
      return      
   endif else begin			   ; convert files to (2xN) array format
      file = file( uniqo(strupcase(file)))  ; multiple file names slip through?

      if debug then $
      if not keyword_set(quiet) then print,file,form='(a)' else begin
		openw,/varia,lun,/get,getenv('HOME')+'logvms_files.txt',/append
		printf,lun,!stime+'   '+file,form='(a)'
		free_lun,lun
      endelse
      logenv=''
      value=''
      keyword=''
      node = ''
      for i=0,n_elements(file)-1 do begin
         onef=rd_tfile(file(i),nocomment=nocomment,/compress)
;
;	Remove comment lines that start with #!
;
	 wuse = where(strpos(onef,'#') gt 0,nuse)
	 if nuse ge 1 then onef(wuse) = ssw_strsplit(onef(wuse),'#')
	 wuse = where(strmid(onef,0,1) ne '#',nuse)
	 if nuse ge 1 then begin
	 onef=onef(wuse)
	 
         extract_vms_defs, onef, logf1, valuef1, keywordf1, ndef=ndef1
	 if ndef1 ge 1 then begin
	    logenv=[logenv,logf1]
	    value =[value, valuef1]
	    keyword = [keyword, keywordf1]
	 endif
	endif
      endfor         
      if n_elements(logenv) eq 1 then begin
	 print, file
         message,/info,'No valid files!!, returning...'
         return
      endif else begin
         logenv  =logenv(1:*)
         value   =value(1:*)
         keyword =keyword(1:*)

      endelse
   endelse
endif
;
;
; check for valid input (or file derived) array)

if (size(keyword))(1) eq 0 then keyword=strarr(n_elements(logenv))

valid=data_chk(logenv,/string,/scaler,/vector) and $
	data_chk(value,/string,/scaler,/vector) and $
        data_chk(keyword ,/string,/scaler,/vector)

qtemp=!quiet
!quiet=keyword_set(quiet)

if valid then begin

   value = node + value                        
   for i=0,n_elements(logenv)-1 do begin       
;         
; Allow for multi-valued logicals
;         
   if not keyword_set(check_log) or not trnlog(logenv(i),logout) then begin                                 
      logvalue = strtrim( value(i),2)                                                                       
      if (strpos(logvalue,'"') * strpos(logvalue,"'")) ne 0 then logvalue=str_sep(logvalue,',')             
      setlog,logenv(i),logvalue,$                                                                           
      concealed = strpos(keyword(i),'conc') ne -1, confine=strpos(keyword(i),'conf') ne -1,$                      
      no_alias = strpos(keyword(i),'no_a') ne -1, terminal = strpos(keyword(i),'term') ne -1                  
     message,/info,'setlog,' + "'" + logenv(i) + "','"  + value(i) + "',/" + keyword(i)                       
   endif                                                                                                    
endfor                                                                                                      
          
endif else message,/info,'Input arrays/file must contain string vector or tables

!quiet=qtemp

end

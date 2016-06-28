;+
; Project     : SOHO - CDS     
;                   
; Name        : PURPOSE
;               
; Purpose     : List procedure/function names and purposes.
;               
; Explanation : Creates a list of all .PRO files and then searches them for
;               the standard CDS header and extracts the Name and Purpose 
;               fields.  The resultant one-line documentation is printed to
;               the screen or to the file "purpose.doc".
;               
; Use         : IDL> purpose [,file_spec, /hard, /path, list=list]
;               IDL> purpose, path='userlib
;    
; Inputs      : None
;               
; Opt. Inputs : file_spec   -  specification of the files to be searched.
;                              If omitted, the current directory is used.
;               
; Outputs     : The information can be printed to the screen or to the default
;               output file "purpose.doc" (or both).
;               
; Opt. Outputs: None
;               
; Keywords    : hard    -  specifies that output is to be stored in file
;                          purpose.doc
;               path    -  if present (/path or path=1) use current IDL path 
;                          (!path) as the search path but select only the cds
;                          /idl directories, otherwise use any directory whose
;                          name contains the string specified by path.
;
;               quiet   -  if specified, do not print to screen.
;
;               list    -  if present, the list of one-liners is returned
;                          in a string array.
;
; Calls       : None
;               
; Restrictions: When the /path option is requested, only directories containing
;               the letters "cds" will be used.  The VMS option is also very
;               fragile in using the path directories and is likely not
;               to work if the path contains symbols and libraries etc.
;               
; Side effects: None
;               
; Category    : Utilities, Documentation, Manual
;               
; Prev. Hist. : None
;
; Written     : C D Pike,  RAL,  23-Jun-1993
;               
; Modified    : To include output variable LIST and keyword QUIET.
;                                                        CDP, 12-Nov-93
;               To detect uppercase NAME and PURPOSE for compatibility with
;               IDL userlib routines.   CDP, 5-May-94
;            
;               Include more flexible path specification, CDP, 13-May-94
;
;               Make search for Name and Purpose more robust, CDP, 25-May-94
;               Back to only read 10 lines from ;+.  CDP, 17-Jun-94
;               Improve handling of no files/directory present when path
;               specified.  CDP, 21-Jun-94
;               
;               Changed /path to mean include all /idl directories.
;                           CDP, 26-Jul-96
;
; Version     : Version 8, 26-Jul-96
;-            

pro purpose,in_files,hard=hard,path=path,quiet=quiet,list=list

;
;  check search directory specification
;
  

if keyword_set(path) then begin   
   if datatype(path,1) eq 'Integer' then use_path = 'idl' else use_path = path
endif

;
;  default number of directories
;
nd = 1

;
;  if no file name parameter supplied then assume all current directory
;  is required.
;
if n_params() eq 0 then begin
   if !version.os eq 'vms' then begin
      spawn,'show def',in_files
      in_files = in_files + '*.pro'
   endif else begin
      spawn,'pwd',in_files
      in_files = in_files + '/*.pro'
   endelse

;
;  if filename supplied then check whether it had the .pro extension or not
;
endif else begin
   ok = where(strpos(in_files,'.pro') ge 0)
   if ok(0) eq -1 then in_files = in_files + '.pro'
   if !version.os eq 'vms' then begin
      if strpos(in_files,']') eq -1 then begin
         spawn,'show def',dir
         in_files = dir + in_files
      endif 
   endif else begin
      if strpos(in_files,'/') eq -1 then begin
         spawn,'pwd',dir
         in_files = dir + '/' + in_files
      endif
   endelse
endelse

;
;  if hard copy requested, open output file
;
if keyword_set(hard) then openw,lunout,'purpose.doc',/get_lun

;
;  check if !path to be used, if so use only cds directories
;  select the file name specification (*.pro or more specific) from what
;  has just been set up and put the path directories on the front
;
if keyword_set(path) then begin
   if !version.os eq 'vms' then begin
      lim1 = ',' 
      lim2 = ''
      lim3 = ']'
   endif else begin
      lim1 = ':'
      lim2 = '/'
      lim3 = '/'
   endelse
   dirs = str2arr(!path,delim=lim1)
   ok = where(strpos(dirs,use_path) ge 0)

   if ok(0) eq -1 then begin
      if not keyword_set(quiet) then begin
         print,'Directory name not in search path (possibly no files).'
      endif
      list = ''
      if keyword_set(hard) then free_lun,lunout
      return
   endif

   dirs = dirs(ok)
   nd = n_elements(dirs)
   if n_params() eq 0 then begin
      in_files = dirs + lim2 + '*.pro'
   endif else begin
      file_name = str2arr(in_files(0),delim=lim3)
      file_name = file_name(n_elements(file_name)-1)
      in_files = dirs + lim2 + file_name
   endelse
endif

;
; initialise variables
;
name = ''
purpose = ''
ok_name = 0
ok_purpose = 0
list = ' '

;
;  loop over directories required
;
for kk=0,nd-1 do begin

;
;  type or print directory name
;
   if file_exist(in_files(kk)) then begin
      break_file,in_files(kk),disk,dir
      if not keyword_set(quiet) then begin
         print,' '
         print,' '
         print,'Directory:  ',dir
         print,' '
      endif
      if keyword_set(hard) then begin
         printf,lunout,' '
         printf,lunout,'Directory:  ',dir
         printf,lunout,' '
      endif
   endif
;
;  get list of file names
;
   ff = findfile(in_files(kk))

;
;  any found? If so then read the file looking for the NAME and PURPOSE
;  keywords.  Note that the information is allowed to be on the same line as
;  the keyword, or on the next line but no further away.  They are both assumed
;  to be in the first 10 lines of the file.  ie assuming standard CDS header.
;
   if ff(0) ne '' then begin
      nf = n_elements(ff)
      for i=0,nf-1 do begin
         text = ' '
         name = ''
         purpose = ''
         ok_name = 0
         ok_purpose = 0
         on_ioerror, file_fail
         openr,lun,ff(i),/get_lun
;
;  skip to start of documentation
;
         text = '  '
         while not eof(lun) and (strmid(text,0,2) ne ';+') do readf,lun,text
         for j=0,19 do begin
            readf,lun,text
            temp = text
            remchar,temp,' '
            temp = strupcase(temp)
            if strpos(temp,';NAME:') ge 0 then begin 
               ok_name = 1
               col = strpos(text,':')
               name = strtrim(strmid(text,col+1,65),2)
               if name eq '' then begin
                  readf,lun,text
                  name = strtrim(strmid(text,1,80),2)
                  if name ne '' then ok_name = 1 else ok_name = 0
               endif
            endif else begin
               if strpos(temp,';PURPOSE:') ge 0 then begin
                  ok_purpose = 1
                  col = strpos(text,':')
                  purpose = strtrim(strmid(text,col+1,80),2)
                  if purpose eq '' then begin
                     readf,lun,text
                     purpose = strtrim(strmid(text,1,80),2)
                     if purpose ne '' then ok_purpose = 1 else ok_purpose = 0
                   endif
               endif
            endelse
         endfor
         if ok_name and ok_purpose then begin
            nl = strlen(name)
            if nl lt 17 then for k=1,17-nl do name = name + ' '
            if keyword_set(hard) then printf,lunout,name+' - '+purpose
            if not keyword_set(quiet) then print,name+' - '+purpose
            list = [list,name+' - '+purpose]
         endif else begin
file_fail:
            break_file,ff(i),disk,dir,fil,ext
            if not keyword_set(quiet) then begin
               print,fil+': ** Documentation incomplete/non-standard. **'
            endif
            if keyword_set(hard) then begin
             printf,lunout,fil+': ** Documentation incomplete/non-standard. **'
            endif
            list = [list,fil]
         endelse
         free_lun,lun
      endfor
   endif
endfor

;
;  trim leading blank from list
;
if n_elements(list) gt 1 then list = list(1:n_elements(list)-1)

;
;  if hard copy produced then remind user...
;
if keyword_set(hard) then begin
   free_lun,lunout
   print,'** Output in file:  purpose.doc'
endif

end

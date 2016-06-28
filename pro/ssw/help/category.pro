;+
; Project     : SOHO - CDS     
;                   
; Name        : CATEGORY
;               
; Purpose     : List procedure/function names and categories.
;               
; Explanation : Creates a list of all .PRO files and then searches them for
;               the standard CDS header and extracts the Name and Category 
;               fields.  The resultant one-line documentation is printed to
;               the screen or to the file "category.doc".
;               
; Use         : IDL> category [,file_spec, /hard, /path, list=list]
;               IDL> category, path='userlib
;    
; Inputs      : None
;               
; Opt. Inputs : file_spec   -  specification of the files to be searched.
;                              If omitted, the current directory is used.
;               
; Outputs     : The information can be printed to the screen or to the default
;               output file "category.doc" (or both).
;               
; Opt. Outputs: None
;               
; Keywords    : hard    -  specifies that output is to be stored in file
;                          category.doc
;               path    -  if present (/path or path=1) use current IDL path 
;                          (!path) as the search path but select only the "cds"
;                          directories, otherwise use any directory whose name
;                          contains the string specified by path.
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
; Written     : Based on PURPOSE, C D Pike,  RAL,  23-Jun-1993
;               
; Modified    : Fixed bug in finding Category line.  CDP, 1-Jun-95
;
; Version     : Version 2, 1-Jun-95
;-            

pro category,in_files,hard=hard,path=path,quiet=quiet,list=list

;
;  check search directory specification
;
;if not keyword_set(path) then begin
;   if !version.os eq 'vms' then spawn,'show def',path else spawn,'pwd',path
;   path = path(0)
;endif
  

if keyword_set(path) then begin   
   if datatype(path,1) eq 'Integer' then use_path = 'cds' else use_path = path
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
if keyword_set(hard) then openw,lunout,'category.doc',/get_lun

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
category = ''
ok_name = 0
ok_category = 0
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
;  any found? If so then read the file looking for the NAME and CATEGORY
;  keywords.  Note that the information is allowed to be on the same line as
;  the keyword, or on the next line but no further away.  They are both assumed
;  to be in the first 10 lines of the file.  ie assuming standard CDS header.
;
   if ff(0) ne '' then begin
      nf = n_elements(ff)
      for i=0,nf-1 do begin
         text = ' '
         name = ''
         category = ''
         ok_name = 0
         ok_category = 0
         on_ioerror, file_fail
         openr,lun,ff(i),/get_lun
;
;  skip to start of documentation
;
         text = '  '
         while not eof(lun) and (strmid(text,0,2) ne ';+') do readf,lun,text
         for j=0,1000 do begin
            readf,lun,text
            if strmid(text,0,2) eq ';-' then goto, file_fail
            temp = strupcase(strcompress(text,/rem))
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
               if strpos(temp,';CATEGORY:') ge 0 then begin
                  ok_category = 1
                  col = strpos(text,':')
                  category = strtrim(strmid(text,col+1,80),2)
                  if category eq '' then begin
                     readf,lun,text
                     category = strtrim(strmid(text,1,80),2)
                     if category ne '' then ok_category = 1 else ok_category = 0
                   endif
               endif
            endelse
            if (ok_name and ok_category) then j=2000
         endfor
         if ok_name and ok_category then begin
            nl = strlen(name)
            if nl lt 17 then for k=1,17-nl do name = name + ' '
            if keyword_set(hard) then printf,lunout,name+' - '+category
            if not keyword_set(quiet) then print,name+' - '+category
            list = [list,name+' - '+category]
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
   print,'** Output in file:  category.doc'
endif

end

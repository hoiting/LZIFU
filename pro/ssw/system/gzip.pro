;+
; Project     : HESSI
;
; Name        : gzip 
;
; Purpose     : gzip/gunzip files
;
; Category    : utility,i/o
;
; Syntax      : IDL> gzip,files,gfiles
;
; Inputs      : FILES = file names to gzip
;
; Outputs     : GFILES = zipped/unzipped file names
;
; Keywords    : UNZIP = unzip files
;
; Restrictions: Unix and probably Windows
;
; Side effects: Files are compressed and overwritten
;               .Z files are decompressed and then gzip'ed (Unix only)
;
; History     : Written 6 July 2000, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro gzip,files,gfiles,err=err,test=test,unzip=unzip,background=background

err=''
gfiles=''
unix=os_family(/lower) eq 'unix'
if not have_exe('gzip') then begin
 err='Could not locate "gzip.exe"'
 message,err,/cont
 return
endif

;-- check for non-blank strings

if not is_string(files,zfiles) then return

unzip=keyword_set(unzip)
found=0b

for i=0,n_elements(zfiles)-1 do begin
 
 chk=loc_file(zfiles(i),count=count)
 tfile=chk(0)

 if count gt 0 then begin
  found=1b
  compressed=is_compressed(tfile,type)

  case type of
    'Z': begin
          if unix then begin
           unzipped=str_replace(tfile,'.Z','')
           if unzip then gzip_cmd='uncompress -f '+tfile else begin
            gzip_file=unzipped+'.gz'
            gzip_cmd=['uncompress -f '+tfile,'gzip -f '+unzipped]
           endelse
          endif
         end

   'gz': begin
          if unzip then begin
           unzipped=str_replace(tfile,'.gz','')
           gzip_cmd='gunzip -f '+tfile
          endif else begin
           gzip_file=tfile
           gzip_cmd=''
          endelse
         end

   else: begin
          if unzip then begin
           unzipped=tfile
           gzip_cmd=''
          endif else begin
           gzip_file=tfile+'.gz'
           gzip_cmd='gzip -f '+tfile
          endelse
         end
  endcase 

  gzip_files=append_arr(gzip_files,gzip_file,/no_copy)
  gzip_cmds=append_arr(gzip_cmds,gzip_cmd,/no_copy)
  unzipped_files=append_arr(unzipped_files,unzipped,/no_copy)

 endif
endfor

if not found then begin
 message,'input file(s) not found',/cont
 return
endif

if exist(gzip_cmds) then begin
 gzip_cmds=rem_blanks(gzip_cmds)
 if is_string(gzip_cmds) then espawn,gzip_cmds,test=test,/noshell,$
                               background=background
endif                                     

if not is_string(gzip_cmds) then message,'input files already processed',/cont
if exist(gzip_files) then gfiles=rem_blanks(gzip_files)
if unzip and exist(unzipped_files) then gfiles=rem_blanks(unzipped_files)
if n_elements(gfiles) eq 1 then gfiles=gfiles[0]
   
return & end

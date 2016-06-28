;+
; Project     : SOHO-SUMER
;
; Name        : FIND_COMPRESSED
;
; Purpose     : find compressed version of a file
;
; Category    : utility,i/o
;
; Explanation : looks for an input file. If not found, looks for a 
;               compressed version (.Z, and .gz), decompresses it 
;               into a temporary directory and returns full path to it.
;
; Syntax      : dfile=find_compressed(file)
;
; Inputs      : FILE = file to locate
;
; Opt. Inputs : None
;
; Outputs     : DFILE = decompressed file (path+name)
;
; Keywords    : ERR = error message
;               STATUS = 1 if decompressed version returned
;               TEMP_DIR = name of temporary directory in which
;                         decompressed files are saved ($HOME/.decompressed)
;               USE_DIR = user specified directory for decompressed files
;               LOOK_ONLY = look only, but don't uncompress
;               LIMIT = number of decompressed files to keep in temporary
;                       directory
;
; Restrictions: Unix/Windows only
;
; Side effects: TEMP_DIR is created
;
; History     : Written 10 Jan 1999, D. Zarro (SMA/GSFC)
;               Modified 15 Feb 2000, Zarro (SM&A/GSFC) -- check
;                for directory creation 
;               Modified 15 April 2000, Zarro (SM&A/GSFC) -- made Windows
;                compatible
;               Modified 31 May 2002, Zarro (LAC/GSFC) - added check
;                for invalid USE_DIR
;               Modified 10 Feb 2004, Zarro (L-3Com/GSFC) - added LIMIT
;               Modified 17 Sep 2005, Zarro (L-3Com/GSFC) - replaced TEST_DIR
;                by WRITE_DIR.
;
; Contact     : dzarro@solar.stanford.edu
;-

function find_compressed,file,err=err,verbose=verbose,status=status,count=count,$
           temp_dir=temp_dir,use_dir=use_dir,look_only=look_only,_extra=extra,$
           limit=limit
                       
common find_compressed,cfiles

err=''
status=0b

if not is_number(limit) then limit=10

verbose=keyword_set(verbose)
if is_blank(file) then begin
 pr_syntax,'dfile=find_compressed(file)'
 return,''
endif

if n_elements(file) ne 1 then begin
 err='input filename must be scalar'
 message,err,/cont
 return,''
endif

;-- see if file is there in some form

catted=strpos(file,'.Z') gt -1
zipped=strpos(file,'.gz') gt -1
compressed=catted or zipped

dfile=loc_file(file,count=count,err=err)
if (count gt 0) and (not compressed) then return,dfile
                 
;-- check for temporary place to store decompressed files
;   ideally store in HOME directory

chk=write_dir('$HOME',out=temp,/quiet)
if not chk then temp=get_temp_dir()
temp_dir=concat_dir(temp,'.decompressed')

;-- override with user-specified location

if write_dir(use_dir,/quiet,out=temp) then temp_dir=temp
                    
;-- check if input file name has compressed extension 
;-- remove the extension and look for it again.
;-- also check if decompressed version exists in TEMP_DIR

err=''
zfile=file                 
if compressed then begin
 if zipped then zext='.gz' else zext='.Z'
 zfile=str_replace(file,zext,'')
endif 
cd,curr=curr
break_file,zfile,dsk,dir,dname,dext
zdir=trim(dsk+dir)
if zdir eq '' then zdir=curr
zname=trim(dname+dext)

dfile=loc_file(zname,count=count,path=[zdir,temp_dir],err=err)
if count gt 0 then begin
 if verbose then begin
  break_file,dfile[0],dsk,dir
  message,'retrieving from '+trim(dsk+dir),/cont
 endif
 status=grep(temp_dir,dfile) ne ''
 return,dfile[0]
endif

;-- still here, then look for a compressed version of file

err=''
if compressed then begin
 dfile=loc_file(file,count=count)
endif else begin
 dfile=loc_file(file+'.gz',count=count)
 if count eq 0 then dfile=loc_file(file+'.Z',count=count)
endelse

;-- couldn't find it, so bail out
  
if count eq 0 then begin
 err='could not locate '+file
 if verbose then message,err,/cont
 return,''
endif

;-- now decompress

if keyword_set(look_only) then return,zfile

uncompress,dfile,direc=temp_dir,out_file=zfile,_extra=extra,err=err

;-- delete decompressed files to conserve disk space

if limit gt 0 then begin
 if exist(cfiles) then begin
  chk=where(zfile eq cfiles,count)
  if count eq 0 then begin
   cfiles=[cfiles,zfile]
   nfiles=n_elements(cfiles)
   if (nfiles gt limit) then begin
    dprint,'% FIND_COMPRESSED: deleting '+cfiles[0]
    file_delete,cfiles[0],/quiet
    cfiles=cfiles[1:(nfiles-1)]
   endif
  endif
 endif else cfiles=zfile
endif

status=err ne ''


return,zfile & end

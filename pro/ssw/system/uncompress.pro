;+
; Project     : HESSI
;
; Name        : uncompress
;
; Purpose     : uncompress a file 
;
; Category    : system, utility,i/o
;
; Syntax      : uncompress,file,name
;
; Inputs      : FILE = file uncompress
; 
; Opt. Inputs : NAME = new name of uncompressed file 
;
; Keywords    : DIRECTORY = directory location of uncompressed file [def=current]
;             : OUT_FILE = uncompressed filename with path
;
; Restrictions: Unix/Windows only
;
; History     : Written 20 Apr 2000, D. Zarro (SMA/GSFC)
;               Modified 28  June 2000, Zarro (EIT/GSFC) - added WINNT check
;               Modified 23 April 2004, Zarro (L-3Com/GSFC) - added MKDIR
;
; Contact     : dzarro@solar.stanford.edu
;-

pro uncompress,file,name,directory=directory,err=err,out_file=out_file,$
               test=test,old=old

err=''
delvarx,out_file
new=1-keyword_set(old)


;-- start with input validation

os=os_family(/lower)
unix=os eq 'unix'
windows=(os eq 'windows') 
if windows then unix=0b
if (not unix) and (not windows) then begin
 err=os+' not currently supported'
 message,err,/cont
 return
endif

if is_blank(file) then begin
 err='missing input file name'
 pr_syntax,'uncompress,file,[name,direc=direct]'
 return
endif

out_dir=curdir()
if is_string(directory) then out_dir=trim(directory)

if out_dir eq '' then begin
 err='output directory must be non-blank'
 message,err,/cont
 return
endif

if not is_dir(out_dir) then begin
 mk_dir,out_dir,/a_read,/a_write
 if not is_dir(out_dir) then begin
  err='failed to create output directory "'+out_dir+'"'
  message,err,/cont
  return
 endif
endif

if not write_dir(out_dir) then begin
 err='no write access to "'+out_dir+'"'
 message,err,/cont
 return
endif

nfiles=n_elements(file)
rename=0b
if is_string(name) then begin
 if n_elements(name) ne nfiles then begin
  err='# of input files does not match # of output names'
  message,err,/cont
  return
 endif
 rename=1b
endif

;-- check extensions

catted=strpos(file,'.Z') gt -1
chk1=where(catted,count1)
zipped=strpos(file,'.gz') gt -1
chk2=where(zipped,count2)
gzip_cmd='gzip'
uncmp_cmd='uncompress'

;-- look for executables

if unix then begin
 if count2 gt 0 and (not have_exe(gzip_cmd)) then $
  err='cannot locate: '+gzip_cmd
 if count1 gt 0 and (not have_exe(uncmp_cmd)) then $
  err='cannot locate: '+uncmp_cmd
 if err ne '' then begin
  message,err,/cont
  return
 endif
endif else begin

;-- use GZIP for both .Z and .gz
                 
 lgzip=get_gzip(err=err)
 if err ne '' then return
 gzip_cmd=lgzip
 uncmp_cmd=lgzip 
endelse

curd=curdir()
for i=0,nfiles-1 do begin
 break_file,file[i],dsk,dir,dname,ext
 
 do_it=0
 if zipped[i] then begin
  dext=str_replace(ext,'.gz','')
  zcmd=gzip_cmd
  do_it=1b
 endif

 if catted[i] then begin
  dext=str_replace(ext,'.Z','')
  zcmd=uncmp_cmd
  do_it=1b
 endif

 chk=loc_file(file[i],count=count)
 do_it=count ne 0

 if do_it then begin

;-- input file

  cdir=trim(dsk+dir)
  if cdir eq '' then cdir=curd
  in_name=trim(dname+ext)
  in_file=concat_dir(cdir,in_name)

;-- output file

  if rename then out_name=name[i] else out_name=trim(dname+dext)
  ofile=concat_dir(out_dir,out_name)
  out_file=append_arr(out_file,ofile,/no_copy)      

  if unix then begin
   tcmd=zcmd+' -dcf '+in_file+' > '+out_file[i]
   cmd=append_arr(cmd,tcmd,/no_copy) 
  endif else begin
   if catted[i] then zip_ext='.Z' else zip_ext='.gz'   
   temp_name=mk_temp_file('t',/rand,direct='')
   ctemp_name=concat_dir(out_dir,temp_name+zip_ext)
   cmd0='copy '+in_file+' '+ctemp_name
   cmd1=zcmd+' -df '+temp_name+zip_ext
   cmd2='move '+temp_name+' '+out_name
   tcmd=[cmd0,cmd1,cmd2]
   cmd=append_arr(cmd,tcmd,/no_copy)
  endelse
 endif
endfor

;--  decompress

if not exist(cmd) then begin
 err='could not locate files to uncompress'
 message,err,/cont
 return
endif

cdir=curdir() & cd,out_dir
rm_file,out_file
espawn,cmd,out,test=test,/noerror,/noshell
cd,cdir

;-- look for decompressed files

for i=0,nfiles-1 do begin
 chk=loc_file(out_file[i],count=ocount)
 if ocount gt 0 then nfile=append_arr(nfile,chk[0],/no_copy)
endfor

if exist(nfile) then out_file=nfile else begin
 err='uncompress failed to complete'
 out_file=''
 message,err,/cont
endelse

;-- deprotect

chmod,out_file,/a_write,/a_read

if n_elements(out_file) eq 1 then out_file=out_file[0]
 
return & end

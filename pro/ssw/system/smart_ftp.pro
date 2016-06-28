;+
; Project     : SOHO-CDS
;
; Name        : SMART_FTP
;
; Purpose     : A wrapper around FTP
;
; Category    : planning
;
; Explanation :
;
; Syntax      : smart_ftp,server,get_file,get_dir
;
; Examples    :
;
; Inputs      : SERVER = server to retrieve from
;               GET_FILE = filenames to retrieve
;
; Opt. Inputs : GET_DIR = directory to retrieve from
;
; Outputs     : See keywords
;
; Keywords    : OUT_DIR = output directory for file [def = current]
;               FILES = found filenames
;               ERR = error string
;               COUNT = no of files copied
;               RETRY = # times to retry if server is down
;               KILL  = kill any zombie processes
;               QUIET = turn off output messages
;               USER  = usename (default is anonymous)
;               PASS  = password (default is user@hostname)
;               PORT  = port number
;               PING  = ping before copying
;               ASCII = ftp as ASCII (def is binary)
;               LIST_ONLY = just do remote LS
;                           
; History     : Written 14 May 1998 D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro smart_ftp,server,get_file,get_dir,out_dir=out_dir,count=count,err=err,$
    retry=retry,quiet=quiet,kill=kill,files=files,user=user,test=test,$
    pass=pass,ascii=ascii,port=port,ping=ping,list_only=list_only

on_error,1
err=''
count=0
delvarx,files
quiet=keyword_set(quiet)
loud=1-quiet
binary=1-keyword_set(ascii)
listing=keyword_set(list_only)

if listing then begin
 if datatype(get_file) ne 'STR' then get_file='.'
 if (datatype(server) ne 'STR') then begin
  pr_syntax,'smart_ftp,server,get_dir,/list'
  return
 endif
 get_dir=get_file
endif else begin

;-- check write access for output

 if datatype(out_dir) ne 'STR' then out_dir=curdir() 
 if not test_dir(out_dir,quiet=quiet,err=err) then return

 if (datatype(get_file) ne 'STR') or $
    (datatype(server) ne 'STR') then begin
  pr_syntax,'smart_ftp,server,get_file,get_dir'
  return
 endif

 get_files=get_file
 if datatype(get_dir) ne 'STR' then begin
  break_file,get_file,dsk,get_dir,names,ext
  if get_dir(0) ne '' then get_files=names+ext else get_dir='.'
 endif

endelse
 
;-- call FTP

alive=1
if keyword_set(ping) then if not is_alive(server,/loud) then return
if exist(port) then fport=port else fport=''
if datatype(fport) ne 'STR' then fport=trim(string(fport))
if not is_number(fport) then fport=''
if datatype(user) ne 'STR' then user='anonymous'
if datatype(pass) ne 'STR' then pass=get_user_id()
if not exist(retry) then retry=1 else retry=nint(retry) > 1
icount=0 & status=0
nfiles=n_elements(get_files)
repeat begin 
 if keyword_set(kill) then kill_job,server
 temp_ftp=mk_temp_file('ftp.inp',/random)
 openw,lun,temp_ftp,/get_lun
 cmds=['open '+server+' '+fport,$
       'user '+user+' '+pass]
 if not listing then begin
  cmds=[cmds,'lcd '+out_dir]
  if binary then cmds=[cmds,'binary']
  get_dirs=get_dir
  if n_elements(get_dirs) ne nfiles then get_dirs=replicate(get_dirs(0),nfiles)
  for i=0,nfiles-1 do cmds=[cmds,'cd '+get_dirs(i),'mget '+get_files(i)]
 endif else cmds=[cmds,'cd '+get_dir,'ls']
 cmds=[cmds,'bye']
 for k=0,n_elements(cmds)-1 do printf,lun,cmds(k)
 close,lun & free_lun,lun
 if keyword_set(test) then begin
  print,rd_ascii(temp_ftp)
  rm_file,temp_ftp
  return
 endif  

 espawn,'ftp -in < '+temp_ftp,files

 icount=icount+1

;-- any files copied?

 if not listing then begin
  files=loc_file(get_files,path=out_dir,count=count)
 endif else count=1

endrep until ((count gt 0) or (icount eq retry))

if listing then begin
 chk=grep('no such',files)
 if chk(0) eq '' then count=n_elements(files) else begin
  err=chk(0) & count=0
  if loud then message,err,/cont
 endelse
endif

if (datatype(files) eq 'STR') and  (err ne '') and loud then print,files
rm_file,temp_ftp

return & end


pro ftp_copy, ifiles, inode, iuser,  ipasswd, idir, get=get, outfil=outfil,    $
		outdir=outdir, ftp_results=ftp_results, ftp_log=ftp_log, $
		logappend=logappend, ftp_file=ftp_file, noftp=noftp,     $
		anonymous=anonymous, status=status, ascii=ascii, binary=binary, $
		list=list, dirname=dirname, subdir=subdir, dirlist=dirlist, $
		no_ping=no_ping, qnode=qnode, expect_sizes=expect_sizes, $
                rev_time_dir=rev_time_dir
;+
;NAME:
;	ftp_copy
;PURPOSE:
;	To build an FTP command and execute it from IDL (Default=PUT)
;
; CALLING SEQUENCE:
;       ftp_copy, files, node [,user,passwd,direct,/anon, /get]
;       ftp_copy, node, subdir='remote_sub', /anon, /list, dirlist=dirlist
;
; Calling Examples:
;       ftp_copy, node, 'pub/yohkoh', /list, dirlist=dirlist, /anon  
;         (return directory listing <dirlist> from <node>, anonymous ftp)
;       ftp_copy, files,  node, 'pub/yohkoh', /get, /anon  
;          (get <files> from <node> in subdirectory pub/yohkoh, anonmous ftp)
;
;INPUT:
;	files	- The file names to be copied.  For /GET they are the
;		  file names on the remote system
;	node	- The node name or number
;	user	- The user name	(will use 'ftp' if /anon is set)
;	passwd	- The password  (will use USER@LOCAL if /anon is set)
;OPTIONAL INPUT:
;	dir	- The remote directory
;OPTIONAL KEYWORD INPUT:
;	get	- If set, do a "get" instead of a "put"
;	outfil	- The file name can be changed by passing the output file
;		  name. The default is to make it the same as the input.
;		  This cannot be used with the OUTDIR option.
;	outdir	- The local directory (generally used with a "get"
;	ftp_log	- The name of the log file that the FTP results should be 
;		  written to
;	logappend - If set, then append the message to the "ftp_log" file
;       noftp   -  If set, generate ftp script but dont spawn it
;       ftp_file - Name of ftp script file (default is $HOME/ftp_copy.ftp)
;       anonymous - If set, use anon ftp protocal for user and password
;		    (in this case, third parameter is used for DIR if present)
;       ascii/binary - if set, specifies transfer mode (default is binary)
;       list -  switch, if set, do directory listing (return via DIRLIST keyword)
;       expect_sizes - vector of expected sizes for files
;                      (if set, status(i)=file_exist(i) AND ((file_size(i) eq  expect_sizes(i))
;       rev_time_dir - if set, causes the 'dir *' request (for file listing) from 
;                      ftp node to be 'dir -t'. Useful if directory is very large, and
;                      want most recent files: less chance of losing tail of dir 
;                      listing.  
;  
;OPTIONAL KEYWORD OUTPUTS:
;       dirlist - (OUTPUT) - return remoted directory listing if /LIST is set
;       status -  (OUTPUT) - boolean success vector, 1 element per file
;                           (currently, only for /get)
;	ftp_results - Any messages that the FTP commands produce (errors, ...)
;	qnode	    - 0 if ping fails, 1 if ping is successful.
;METHOD:
;	Binary is the default method of transfer (use /ascii to override)
;       DEFAULT is PUT (historical; GET is used much more frequently...)
;
;HISTORY:
;	Written 11-Oct-93 by M.Morrison
;	19-Oct-93 (MDM) - Added FTP_RESULTS keyword.  Changed things slightly
;        3-May-94 (SLF) - Major RE-write, add ANONYMOUS, FTP_FILE & NOFTP 
;			  keywords and function,use file_append, file_delete
;        5-May-94 (SLF) - dont LCD for /gets, Add STATUS output keyword
;       10-May-94 (SLF) - add ASCII and BINARY keywords and function
;        1-Mar-95 (SLF) - add LIST keyword and function
;       15-apr-95 (SLF) - fixed bug with LIST option
;       10-may-95 (SLF) - add ping check (default) and NOPING keyword
;			  avoid hung ftp jobs
;        2-aug-95 (SLF) - dont clobber input, change def. scriptdir(HOME), documentation
;	29-jan-96 (JRL) - Fixed status and added qnode keyword
;       13-may-97 (SLF) - Add EXPECT_SIZES keyword and function
;                         (protection against ftp connection dropouts, partially transmitted files)
;       14-may-98 (PGS) - added rev_time_dir.  Tail of directory listing of long 
;                         on ftp node was getting lost.  This places the most recent files
;                         first, -- ensures I get most recent files even if lose some older
;                         ones.
;	17-Feb-99 (MDM) - Code from "noping" to "no_ping" to enable that keyword option
;-

; protect input parameters 
params=['files','node','user','passwd','dir'] 
for i=0,n_params()-1 do exestat=execute(params(i)+'= i' + params(i))

pingit=1-keyword_set(no_ping)

ftp_results = ''
; -------- check input, setup user and password info  --------------------

list=keyword_set(list)

if n_params() eq 1 and keyword_set(list) then begin
   node=files
   files=''
endif

pass=''
anon=keyword_set(anonymous) or n_params() le 2

if anon then  begin
   if n_params() eq 3 then dir=user
   ouser='ftp'
   user=ouser
   pass=' ' + get_user() + "@" + get_host()
endif 

if keyword_set(user) then ouser=user else ouser=get_user()

if keyword_set(passwd) then pass=passwd
; -------------------------------------------------------

ftpit=1-keyword_set(noftp)
; ------ determine name and output for ftp script file ----------
ftps_dir=get_logenv('HOME')
if not keyword_set(ftp_file) then begin
   ftp_fil = 'ftp_copy.ftp'
endif else begin
   break_file,ftp_file,log,opath,ftp_fil,ext,ver
   ftp_fil=ftp_fil+ext+ver
   ftps_dir=([ftps_dir,opath])(opath(0) ne '')
endelse
ftp_fil=concat_dir(ftps_dir,ftp_fil)
; --------------------------------------------------------------
file_delete, ftp_fil			; delete old
;
; ------- open new file, insert ftp connection and setup commands ---------
transmode=['binary','ascii']
header=[			$
  'open ' + node,		$
  'user ' + ouser + ' ' +pass, 	$
  transmode(keyword_set(ascii))]				

if keyword_set(subdir) then dir=subdir

if (n_elements(dir) ne 0) then if (dir(0) ne '') then $
   header=[header,'cd ' + dir]

file_append,ftp_fil,header

if keyword_set(list) then begin
   dirname=concat_dir(get_logenv('$HOME'),'ftp_copy.list')
   IF (keyword_set(rev_time_dir)) THEN BEGIN ; ask for most recent files first.
      file_append,ftp_fil,['dir -t ' + dirname]
   ENDIF ELSE BEGIN
      file_append,ftp_fil,['dir * ' + dirname]
   ENDELSE 
   n=1
   file=dirname
   outfil=dirname
endif else begin
; --------------------------------------------------------------
;
cmds = ['put ','get ']
cmd=cmds(keyword_set(get))		; default is PUT
;					, historical(??) - generous but wrong

n = n_elements(files)
if (keyword_set(outdir)) then outfil = concat_dir(outdir, files)
if (n_elements(outfil) eq 0) then outfil = strarr(n)	;blanks
;
; --------- generate command list array (slf) remove for loop -------------
commands=strarr(n*2)
break_file,files,dsk_logs,ldirs,filnams,exts
filnams=filnams + exts
commands(indgen(n)*2)='lcd ' + dsk_logs + ldirs
commands((indgen(n)*2)+1)=cmd + filnams + ' ' +  outfil

wc=where(strpos(commands,'*') ne -1, wccnt)
if wccnt gt 0 then commands(wc) = 'mget ' + filnams(wc/2 + 1)

; *********** kludge ************ (dont lcd for /get)
if keyword_set(get) then commands=commands((indgen(n)*2)+1)
; ***********************************************

file_append,ftp_fil, commands
; -----------------------------------------------------------------------
endelse 

; termination commands
file_append,ftp_fil,'bye'
;
; ----------- spawn ftp if not told otherwise -------------
qnode = 0
if ftpit then begin 
;;   delstat=intarr(n)
   alive=is_alive(node)
   qnode = alive
   if (pingit and not alive) then begin
      message,/info,"NODE: " + node + " not responding"
   endif else begin
      spawn, 'ftp -in < ' + ftp_fil, ftp_results 
      if outfil(0) eq '' then outfil=filnams
      status=file_exist(outfil) 			   ;;and delstat
      if n_elements(expect_sizes) eq n_elements(outfil) then begin
	  sizes=file_size(outfil)
	  sizebad=where(sizes ne expect_sizes,bfcnt)
	  sizestat=(sizes eq expect_sizes)
          if bfcnt gt 0 then begin
	    prstr,strjustify(["File transferred size does not match expectations:", $
		   "   "+outfil(sizebad)],/box)
	    file_delete,outfil(sizebad)
            status=sizestat
          endif
      endif
      if keyword_set(list) then dirlist=rd_tfile(dirname)
   endelse
endif else begin
   message,/info,'FTP script written to: ' + ftp_fil
endelse
;
; --------------  log results if requested ----------------------------
if (keyword_set(ftp_log)) then file_append, ftp_log, ftp_results, $
   newfile=(1-keyword_set(logappend))
; -----------------------------------------------------------------------
;
return
end

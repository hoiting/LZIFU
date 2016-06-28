pro ftp_copy_new, ifiles, inode, iuser,  ipasswd, get=get, outfil=outfil,	$
		outdir=outdir, ftp_results=ftp_results, ftp_log=ftp_log, 	$
		logappend=logappend, ftp_file=ftp_file, noftp=noftp,     	$
		anonymous=anonymous, status=status, ascii=ascii, binary=binary, $
		dirname=dirname, subdir=subdir, dirlist=dirlist, 		$
		local_log_file=local_log_file,no_ping=no_ping, qnode=qnode, $
		check_size=check_size, expect_size=expect_size, $
                rev_time_dir=rev_time_dir 
;+
;NAME:
;	ftp_copy_new
;PURPOSE:
;	Wrapper to call ftp_copy.  Does a remote listing on the source
;	macine before deciding if the ftp is necessary or not.
;
; CALLING SEQUENCE:
;       ftp_copy_new, files, node, /anon
;       ftp_copy_new, files, node, subdir='remote_sub', /anon, /list, dirlist=dirlist
;       ftp_copy_new, files, node, user, passwd
;
;INPUT:
;	file		- The file names to be copied from the remote system.
;	node		- The node name or number
;OPTIONAL INPUT:
;	user		- The user name	(will use 'ftp' if /anon is set)
;	passwd		- The password  (will use USER@LOCAL if /anon is set)
;	
;OPTIONAL KEYWORD INPUT:
;	get		- Only works with get (default).
;	outdir		- The local directory (where ftp'ed files are written).
;	ftp_log		- The name of the log file that the FTP results are written.
;	logappend 	- If set, then append the message to the "ftp_log" file.
;       noftp   	- If set, generate ftp script but don't spawn it.
;       ftp_file 	- Name of ftp script file (default is $HOME/ftp_copy.ftp)
;       anonymous 	- If set, use anon ftp protocol for user and password
;		    	  (in this case, third parameter is used for DIR if present)
;       ascii/binary 	- If set, specifies transfer mode (default is binary).
;       list -  switch, if set, do directory listing (return via DIRLIST keyword)
;	local_log_file 	- Name of a local file which has the previous /list results.
;			  This file is read to see if a new ftp copy is necessary.
;			  If not present, will read all files specified in 1st arg.
;	no_ping   	- Ignored in ftp_comp_new.  Always do a ping.
;       rev_time_dir    - Causes first call to ftp_copy (to obtain directory list)
;                         to be for files ordered from youngest-to-oldest ('dir -t').
;OPTIONAL KEYWORD OUTPUTS:
;	dirname  	- Name of the remote directory list file.
;       dirlist 	- Return remote directory listing if /LIST is set
;       status  	- Different from ftp_copy.  0 means no files copied.
;			     If gt 0, is the number of files copied.  If -1,
;			     the node could not be accessed.
;	outfil		- This different from the ftp_copy keyword of the same name.
;		  	  In ftp_copy_new it is a listing of copied files.
;	ftp_results 	- Any messages that the FTP commands produce (errors, ...)
;	qnode		- 0 if ping fails, 1 if ping is successful.
;       check_size      - switch, if set, pass sizes->ftp_copy 
;       expect_size     - expected file size array (usually derived from
;                         remote directory list, but may be used for debugging  
;METHOD:
;	Binary is the default method of transfer (use /ascii to override)
;       DEFAULT is PUT (historical; GET is used much more frequently...)
;
;	Calls comp_fil_list and ftp_copy
;
;HISTORY:
;	 2-Feb-96, J. R. Lemen (LPARL), Written. 
;	28-Feb-96, JRL, Delete local list file before writing new version ==> correct owner.
;       24-jul-97, S.L.Freeland add /CHECK_SIZE and EXPECT_SIZE keyword/function
;       14-may-98, P. G. Shirts: added rev_time_dir keyword (to pass to /list call to 
;                                ftp_copy)
;-

delvarx, outfil, dirname, dirlist, ftp_results	; Make sure we give no false indications

; -----------------------------
; Set up the user/password
; -----------------------------
user='' & passwd = '' 
if not keyword_set(anonymous) then begin
  if n_elements(iuser)   ne 0 then user   = iuser
  if n_elements(ipasswd) ne 0 then passwd = ipasswd
endif
 
; ----------------------------------------------------
; Use the /list option to the remote directory listing
; ----------------------------------------------------
ftp_copy, ifiles, inode, user, passwd, subdir=subdir, /get,	$
		/list, ftp_log=ftp_log, ftp_file=ftp_file,	$
		ftp_results=ftp_results, logappend=logappend,	$
		noftp=noftp, anon=anonymous, status=fstatus,	$
		dirname=dirname, dirlist=dirlist, 		$
		ascii=ascii, binary=binary, 			$
		qnode=qnode, rev_time_dir=rev_time_dir

if not qnode then begin		; Check if the connect worked O.K.
  status = -1
  return
endif

if strlen(strtrim(dirlist(0),2)) eq 0 then begin
  message,'Warning:  Could not get a directory listing on remote machine',/info
  status = -1
  return
endif

; -----------------------------------------------------
; Read in the local copy of the ftp directory listing
; -----------------------------------------------------

ref_list = ''
if n_elements(local_log_file) ne 0 then 	$
   if file_exist(local_log_file)   then 	$
		ref_list = rd_tfile(local_log_file, nocomm=';')

; -----------------------------------------------------
; Now compare the lists
; -----------------------------------------------------

print,'Comparing the lists now ... '
  comp_fil_list, dirlist, ref_list=ref_list, files=ifiles, ofiles, status=status
  if status le 0 then return

; -----------------------------------------------------
; Spawn the ftp command 
; -----------------------------------------------------

prstr,strjustify(['Will copy the following files ('+ $
       strtrim(n_elements(ofiles),2) + '):','   ' + ofiles],/box)

if keyword_set(check_size) and (1-keyword_set(expect_size)) then begin
  expect_size=lonarr(status)
  table=str2cols(dirlist,/trim)   
  dfiles=reform(table(8,*)) & dsize=long(reform(table(4,*)))
  for i=0,status-1 do expect_size(i)=dsize(where(ofiles(i) eq dfiles))

  prstr,/nomore,$
     strjustify(['Size Checking On, Expected Sizes:', $
      '   ' + strjustify(ofiles) + ' ' +  string(expect_size)],/box)      
endif

; Always user /logappend, because log file created in first call:
ftp_copy, ofiles, inode, user, passwd, subdir=subdir, /get,	$
		ftp_log=ftp_log, ftp_file=ftp_file,		$
		ftp_results=ftp_results, /logappend,		$
		noftp=noftp, anon=anonymous, status=fstatus,	$
		ascii=ascii, binary=binary, outdir=outdir,	$
		qnode=qnode,expect_size=expect_size

ij = where(fstatus ne 1, nc)

; ------------------------------------------------------------
; Update/write the local copy of the remote directory listing
; ------------------------------------------------------------
if not qnode then begin
  str_st = 'Obtained listing, but node unaccessible for file transfer'
  status = -1
endif else if nc ne 0 then begin			; No files copied.
  str_st = string('Warning:  ftp status =',fstatus)
  str_st = [str_st,'          local log file NOT update']
  prstr,/nomore,str_st
endif else begin
  text = '; LOCAL FTP LIST FILE WRITTEN AT : '+fmt_tim(!stime)
  text = [text,'; This file is checked to decide if an ftp transfer is necessary.']
  text = [text,'; A full ftp transfer can be triggered by deleting this file.']
  text = [text,';']
  text = [text, dirlist]
  file_delete,local_log_file		; Delete file first
  prstr,text,file=local_log_file
  ij = where(fstatus eq 1)
  outfil = ofiles(ij)
  if n_elements(outdir) ne 0 then outfil = concat_dir(outdir, outfil)
  str_st = string('Files copied = ',ofiles)
endelse

; --------------  log results if requested ----------------------------
if (keyword_set(ftp_log)) then begin
  file_append, ftp_log, str_st
  file_append, ftp_log, ftp_results
endif
; -----------------------------------------------------------------------

end

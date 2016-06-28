function dir_since, indir, infage, sort=sort, subdir=subdir, except=except, $
		    nofollow=nofollow, pattern=pattern, verbose=verbose, $
		    files=files
;+
;   Name: dir_since
;
;   Purpose: directory listing for spcified age files
;
;   Input Parameters:
;      indir  - directory(ies) or files to search
;      infage - file age to consider  (days)
;               If positive, OLDER than this number of days
;               If negative, NEWER than this number of days
;
;   keyword Parameters:
;      PATTERN  - file pattern to include (def=all)
;      NOFOLLOW - if set, do not follow symbolic links (default=follow)
;      VERBOSE - if set, echo commands
;      FILES   - set this if 1st parameter is FILELIST (instead of directories)
;                (in this case, PATTERN is ignored)
;  
;   Calling Sequence:
;      Two modes of operation -
;      Default uses directory list and optional file PATTERN to search
;         IDL>oldfiles=dir_since(directories, days>0 [,pattern=pattern] )
;         IDL>newfiles=dir_since(directories, days<0 [,pattern=pattern] )
;      Use /FILES switch if input is explicit file list instead of directories
;         IDL>oldfiles=dir_since(filelist, days>0 , /files )
;         IDL>newfiles=dir_since(filelist, days<0 , /files )
;      This second mode can be used to 'weed out' old or new files from
;         and existing filelist vector  
;
;   History: 
;      2-Nov-1993 (SLF)
;     26-Feb-1999 (SLF) - follow symbolic links, add PATTERN keyword
;                         document, add /FILES (permit filtering filelist)  
;     26-aug-2005 (SLF) - fix prob when '//' present in file names
;
;   Restrictions:
;     UNIX only   
;-

case os_family() of
   'unix':                     ; OK to proceed
   else: begin
      box_message,'UNIX only for now. Returning....'
      return,''
   endcase
endcase     

verbose=keyword_set(verbose)
  
if n_elements(indir) eq 0 then begin
   message,/info,'No input directory, using current: ' + curdir()
   indir=curdir()
endif

dir=indir
dir=dir+'/'
dir=str_replace(dir,'//','/')

if n_elements(infage) eq 0 then infage=0

fage=strtrim(abs(infage),2)
message,/info,'Listing files '+ (["older","newer"])(infage lt 0) + ' than ' + fage + ' days old'

; ----------- determing file pattern needed for find command ---------
case 1 of
   1-data_chk(pattern,/string): fpat='\*'           ; none, look for ALL
   strpos(pattern,'\*') ne -1: fpat=pattern         ; OK, use verbatim
   strpos(pattern,'*') ne -1:  $                    ; prepend escape to '*'
	   fpat=str_replace(pattern,'*','\*') 
   else: fpat='\*'+pattern+'\*'                     ; all matching PATTERN 
endcase   

; ------ default find commands required (assume directory input) -------
mtime=" -mtime " + (['+','-'])(infage lt 0) + fage + $
                   ([" -follow ",""])(keyword_set(nofollow))
findcmd="find " + dir + mtime + " -name " + fpat+ " -print"

exe_spawn="spawn,findcmd(i),sfiles"          ; find - use execute (later)

; ------ if filelist input instead of directory list, update some stuff ---
if keyword_set(files) then begin
   break_file,indir,ll,pp,ff,ee,vv
   fnames=ff+ee+vv
   findcmd='find ' + pp + mtime + " -name " + fnames + " -print"
   exe_spawn="spawn,str2arr(findcmd(i),' ',/nomult),sfiles,/noshell" ; faster
endif

allfiles=''                                   ; initialize output vector
for i=0,n_elements(findcmd)-1 do begin 
   exestat=execute(exe_spawn)
   if not keyword_set(subdir) and not keyword_set(files) then begin		;eliminate subdirectories
      chkdbl=where(strpos(sfiles,'//') ne -1,dcnt)
      if dcnt gt 0 then sfiles(chkdbl)=str_replace(sfiles(chkdbl),'//','/')
      lpdelim=str_lastpos(sfiles,'/')
      which=where(lpdelim eq str_lastpos(dir,'/'),lpcnt)
      if lpcnt eq 0 then sfiles='' else sfiles=sfiles(which)
   endif

   if keyword_set(except) then begin
      remain=rem_elem(sfiles,except,sscnt)
      if sscnt eq 0 then sfiles='' else sfiles=sfiles(remain)
   endif
   if sfiles(0) ne '' then allfiles=[allfiles,sfiles]   
endfor


if keyword_set(sort) and n_elements(allfiles) gt 1 then begin
   break_file,allfiles,log,paths,files,exts,vers
   order=sort(files)
   sfiles=log(order) + paths(order) + files(order) + exts(order) + vers(order)
endif

if n_elements(allfiles) eq 1 then message,/info,'No files found' else $
			  allfiles=allfiles(1:*)
return,allfiles
end   
   

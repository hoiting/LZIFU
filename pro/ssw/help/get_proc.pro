;+
; Project     : SOHO - CDS
;
; Name        : 
;	GET_PROC()
; Purpose     : 
;	Extract procedure from a library or directory.  
; Explanation : 
;	This procedure is used by the SCANPATH routine to extract a procedure
;	from a VMS text library, or from a directory.
; Use         : 
;	Result = GET_PROC(LIB,NAME,TEXT=TEXT, 
;			/SEARCH,/LINOS,/BUFFER)
; Inputs      : 
;	LIB	= Library name.
;	NAME	= Procedure name.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	The output of the function is a string array with each element being a
;	line of code.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	TEXT 	= Search string.
;	SEARCH  = Logical switch to decide whether to search for string in
;       RELOAD  = do not recall procedure from memory, but reload it
;       KEEP    = number of files to keep in buffer [def=20]
; UNUSABLE KEYWORDS -- code is in place but modifications to DOC.PRO
;		       are needed to pass /LINOS or BUFFER=[n1,n2]
;       LINOS   = added line number option
;	BUFFER  = 2 element vector indicating display n1 lines before search 
;		  string and n2 lines after search string. Only valid if
;		  /SEARCH is set
; Calls       : 
;	LOC_FILE
; Common      : 
;	None.
; Restrictions: 
;	None.
; Side effects: 
;	None.
; Category    : 
;	Documentation, Online_help.
; Prev. Hist. : 
;       Written DMZ (ARC) May 1991.
;	Modified WTT (ARC) Dec 1991, to support UNIX.
;       Modified DMZ (ARC) Jul 1992, to speed reading and add extract keyword
;       Modified EEE (HSTX) Oct 1992, 1) to find all occurrences of ;+/;_
;       			      2) to search for input string
;       			      3) to allow BUFFER keyword 
; Written     : 
;	D. Zarro, GSFC/SDAC, May 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 16 June 1993.
;		Added IDL for Windows compatibility.
;		Modified to avoid conflict with SERTS function named FIND.
;       Version 3, Dominic Zarro, GSFC, 1 August 1994.
;               Corrected bug in reading from common block 
;       Version 3.1, Dominic Zarro (GSFC) 22 August 1994.
;               Removed spawning and replace by call to RD_ASCII
;       Version 4, Dominic Zarro (GSFC) 22 September 1994.
;               Removed lower/upper case forcing if filenames
;               (who put that there? - not me)
; Version     : 
;	Version 4, 22 September 1994.
;-

function get_proc,library,name,text=text,reload=reload, $
		  keep=keep,search=search,linos=linos, buffer=buffer
 
common procb,names,procs

;-- in case there was a crash earlier

n_names=n_elements(names)
n_procs=n_elements(procs)
sz=size(procs)
if sz(0) eq 0 then n_procs=0
if sz(0) eq 1 then n_procs=1
if sz(0) eq 2 then n_procs=sz(2)

if (n_procs ne n_names) then begin
 names='' & procs='' 
endif

if not exist(keep) then nbuff=20 else nbuff=keep


break_file,name,dsk,direc,tname,ext,ver

lib = strtrim(library,2) 
tlb=(strpos(strlowcase(lib),'.tlb') gt -1)
ats=(strpos(lib,'@') eq 0)
islib=(tlb or ats)
if islib then begin                        ;-- take off "@" sign and add .tlb
 if ats then begin
  lib = strmid(lib,1,strlen(lib)-1)
  lib_log=chklog(lib)
  if lib_log ne '' then lib=lib_log
  tlb=(strpos(strlowcase(lib),'.tlb') gt -1)
 endif
 if not tlb then lib=lib+'.tlb'
 fname=concat_dir(getenv('HOME'),tname+'_xdoc_proc.pro') 
endif else begin
 if ext eq '' then name=name+'.pro'
 fname=concat_dir(lib,name)
endelse

;-  if the name is '*info*', then get the file "aaareadme.txt", and get the
;  entire file.


if (strpos(name,'*info*') gt -1) then begin
 fname =concat_dir(lib,"aaareadme.txt")
endif

;-- in memory already?; if so, then retrieve it

vms=os_family() eq 'vms'
proc_in_memory=0
reload=keyword_set(reload)
if (not reload) and exist(names) then begin
 if vms then flook=where(strtrim(strupcase(fname),2) eq strtrim(strupcase(names),2),count) else $
  flook=where(strtrim(fname,2) eq strtrim(names,2),count)
 if count gt 0 then begin
  message,'recalling '+fname,/contin
  proc_in_memory=1 & proc=procs(*,flook(0))
 endif
endif

if not proc_in_memory then begin

;-- extract module from library or directory 
  
 if islib then begin                      ;--library case
  ifind=findfile(fname,count=fc)         ;-- modules already extracted?
  if fc eq 0 then begin
   statement='$libr/extract='+tname+' '+lib+' /out='+fname
   espawn,statement
  endif
 endif else begin                       ;--directory case
  found=loc_file(fname,count=nf)
  if nf eq 0 then begin
   return,fname+' not found'
  endif
 endelse

;-- now read procedure into memory 
;-- strip /tmp_mnt

 item='/tmp_mnt'
 if strpos(fname,item) eq 0 then rname=strmid(fname,strlen(item),100) else rname=fname
 proc=rd_ascii(rname)

;-- add line numbers

 if keyword_set(linos) then begin
  np=n_elements(proc) 
  lnums=(sindgen(np+1))(1:np)+': '
  proc=strtrim(lnums,1)+proc
 endif

;--now save procedure into common memory to avoid re-reading

 if n_procs eq 0 then begin
  names = fname
  procs = proc
 endif else begin
  flook=where(fname eq names,fcount)
  if fcount eq 0 then begin
   names = [names,fname]
   boost_array,procs,proc
  endif else begin
   lastf=flook(fcount-1)
   message,'reloading '+names(lastf),/cont
   keep=where(fname ne names,kcount)
   if kcount gt 0 then begin
    names=[names(keep),fname]
    procs=procs(*,keep)
    boost_array,procs,proc
   endif else begin
    names=fname
    procs=proc
   endelse
  endelse
  if n_elements(names) gt nbuff then begin		
   names = names(1:*)
   procs = procs(*,1:*)
  endif
 endelse
endif


; now have desired output in variable array proc so just do a search on that.
;  if search is set, then show the specified lines above and below the line
;  that contains the search string.


if keyword_set(search) then search=1 else search=0
if not keyword_set(buffer) then buffer = [2,2] $ ; 2 lines before and after
                           else buffer=buffer

if search then begin			; search file for the given string
 if text eq '' then return,'no search string entered'

 tproc='no match found for search string ' + text & np=n_elements(proc)-1
 textup = text			; find all occurrences

 case n_elements(buffer) of 		; is there a range to show above/below
   0 : begin above=0 & below=0   &  end 		; only 1 line
   1 : begin above=0 & below=buffer  &  end		; current down to input
   else : begin above=buffer(0) & below=buffer(1) & end	; expand both sides
 endcase

 i=-1  &   trail=-1
 repeat begin
   i=i+1 & line=proc(i)
   if strpos(line, textup) ge 0 then begin		; found a match
        lead = (i-above-1) > trail+1 > 0		; don't rewrite lines
        if lead-1 ne trail then tproc = [tproc, '---line ' + strtrim(lead,2) + $
					        '---']
        trail = (i+below) < np
	tproc=[tproc, proc(lead: trail) ]
	i = trail 				; already have these lines
   end
 endrep until (i ge np)		; search whole file

 if n_elements(tproc) gt 1 then tproc=tproc(1:*)
 proc=tproc
endif

;-- remove trailing blanks

if n_elements(proc) gt 1 then begin
 temp=reverse(proc)
 chk=where(temp ne '',cnt)
 if cnt gt 0 then proc=reverse(temp(chk(0):n_elements(temp)-1))
endif

;-- remove blank file names

if datatype(names) eq 'STR' then begin
 keep=where(trim2(names) ne '',count)
 if count gt 0 then begin
  names=names(keep) & procs=procs(*,keep)
 endif else begin
  names='' & proc=''
 endelse
endif

return,proc & end


;+
; Project     : SOHO - CDS
;
; Name        :
;	GET_MOD()
; Purpose     :
;	Extract list of procedure modules.
; Explanation :
;	Extract list of procedure modules from a library or directory.  Used by
;	SCANPATH.
; Use         :
;	Result = GET_MOD(LIB)
; Inputs      :
;	LIB  = Library or directory name.
; Opt. Inputs :
;
; Outputs     :
;	Result of function is a string array with each module name.
; Opt. Outputs:
;	None.
; Keywords    :
;	None.
; Calls       :
;	BREAK_FILE, LOC_FILE
; Common      :
;	None.
; Restrictions:
;	None.
; Side effects:
;	None.
; Category    :
;	Documentation, Online_help.
; Prev. Hist. :
;       Written DMZ (ARC) May 1991
;	William Thompson, Dec 1991, modified to be compatible with UNIX.
;       DMZ (DEC'92), fixed bug in FINDFILE with long argument lists.
; Written     :
;	D. Zarro, GSFC/SDAC, May 1991.
; Modified    :
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 16 June 1993.
;		Changed strategy used for text libraries--more robust.
;		Added IDL for Windows compatibility.
;       Version 3, Dominic Zarro, GSFC, 1 August 1994.
;               Changed something, but can't remember what it was
;       Version 3.1, Dominic Zarro, GSFC, 1 August 1994.
;               Replace spawning of 'ls' by call to LOC_FILE
;	Version 3.2, richard.schwartz@gsfc, 5 June 1998.
;		Sort modules explictly alphabetically to help windows.
; Version     :
;	Version 3.2, 5 June 1998.
;-
;
	function get_mod,library

	lib = strtrim(library,2)
;
;  is it a text library or a directory?  if the first character is a "@", then
;  it must be a library.
;

        tlb=(strpos(strlowcase(lib),'.tlb') gt -1)
        ats=(strpos(lib,'@') eq 0)
        if tlb or ats then begin                        ;-- take off "@" sign
         if ats then begin
          lib = strmid(lib,1,strlen(lib)-1)
          lib_log=chklog(lib)
          if lib_log ne '' then lib=lib_log
         endif
         break_file,lib,dsk,direc,name,ext
         if strlowcase(ext) eq 'tlb' then tlib=lib else $
           tlib=dsk+direc+name+'.tlb'
	 lname = concat_dir(getenv('HOME'),name+'._xdoc_mod')
         find= findfile(lname,count=fc)
	 if fc eq 0 then begin
	  statement = '$library/list=' + lname + ' ' + tlib
	  espawn,statement
	 endif
;
;  read lines from file created above.  start with the first line after an
;  empty line.
;

                on_ioerror,oops
		mods=''
		openr,lun,lname,/get_lun
		header = 1
		while not eof(lun) do begin
			line = ''
			readf,lun,line
			if not header then mods = [mods,strtrim(line,2)]
			if strlen(strtrim(line,2)) eq 0 then header = 0
		endwhile
		close,lun
		free_lun,lun
		mods=mods(1:*)
                on_ioerror,null
;
;  otherwise, it's just a directory.
;
	endif else begin

                pros=concat_dir(lib,'*.pro')
                mods = loc_file(pros,count=fcount,/recheck)

;  find any "aaareadme.txt" files.
;
		readme = loc_file(concat_dir(lib,'aaareadme.txt'),count=count)
		if count ne 0 then mods = [concat_dir(lib,'*info*'),mods]
;
;  strip off the directory part from the procedure names.
;

                break_file,mods,dsk,direc,name,ext

                mods=name+ext
        endelse
oops:   return,mods(sort(mods))
	end


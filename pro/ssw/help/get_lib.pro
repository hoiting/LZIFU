;+
; Project     : SOHO - CDS
;
; Name        : 
;	GET_LIB()
; Purpose     : 
;	Place elements of !PATH into a string array..
; Explanation : 
;	Place library and directory elements of !PATH into a string array.
;	Used by SCANPATH.
; Use         : 
;	Result = GET_LIB()
;	Result = GET_LIB( PATH )
; Inputs      : 
;	None required.
; Opt. Inputs : 
;       PATH = Path name (default is !path).
; Outputs     : 
;	Function result is a string array of path elements.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	NO_CURRENT - don't include current directory
; Calls       : 
;	PATH_EXPAND, GETTOK
; Common      : 
;	None.
; Restrictions: 
;	None.
; Side effects: 
;	None.
; Category    : 
;	Documentation, Online_help.
; Prev. Hist. : 
;       Written DMZ (ARC) April 1991
;	William Thompson, Dec 1991, modified to be compatible with UNIX, and
;				    with VMS logical names.  Also, to be
;				    compatible with changes in SCANPATH
; Written     : 
;	D. Zarro, GSFC/SDAC, April 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 7 May 1993.
;		Added IDL for Windows compatibility.
;	Version 3, William Thompson, GSFC, 24 September 1993.
;		Changed EXPAND_PATH to PATH_EXPAND.
;       Version 3.1, Dominic Zarro, GSFC, 1 August 1994.
;               Added check for current directory in path.
;	Version 4, 23-Oct-1997, William Thompson, GSFC
;		Use OS_FAMILY() instead of !VERSION.OS
; Version     : 
;	Version 4, 23-Oct-1997
;-
;
       function get_lib,path,no_current=no_current

       if n_elements(path) eq 0 then temp = !path else temp=path
       no_current=keyword_set(no_current)
;
;  expand any vms logical names.
;
	if os_family() eq 'vms' then temp = call_function('path_expand',temp)
;
;  get a listing of all the directories in the path.
;
	if os_family() eq "vms" then begin
        	sep = ','
		dirsep = ''
	end else if os_family() eq "Windows" then begin
		sep = ';'
		dirsep = '\'
	end else begin
        	sep = ':'
		dirsep = '/'
	endelse
        
        dirs=''
	while temp ne '' do begin
         temp2=gettok(temp,sep)
         if trim(temp2) ne '' then dirs = [dirs,temp2]
        endwhile
        ndirs=n_elements(dirs) 
        if ndirs gt 1 then dirs=dirs(1:ndirs-1)

;-- check if current directory is first in !path
;-- /no_current is set and curdir is first in !path then we remove it
;-- /no_current is not set, and curdir is not in !path then we add it

        ndirs=n_elements(dirs)
        chk=where(curdir() eq dirs,count)
        if no_current then begin
         if (chk(0) eq 0) and (ndirs gt 1)  then dirs=dirs[1:*]
        endif else begin
         if (chk(0) eq -1) then dirs=[curdir(),dirs]
        endelse
        

	return,dirs
	end


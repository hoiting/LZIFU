function spec_dir,filename,extension
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SPEC_DIR()
; Purpose     :	
;	Appends a default disk or directory to a filename.
; Explanation :	
;	Provide a complete file specification by appending a default disk
;	or directory if necessary.
;
;	For Unix, SPEC_DIR will simply append the default directory obtained
;	from the CD command (if necessary).   Under VMS one must also 
;	determine if the disk and/or directory is already specified.    Under 
;	VMS, SPEC_DIR will also try to translate disk and directory logical 
;	names.
;
; Use         :	
;	File_spec = SPEC_DIR(filename,[extension])
;
; Inputs      :	
;	filename - character string giving partial specification of a file
;		name.  VMS examples include 'UIT$USER2:TEST.DAT', or 
;		'[.SUB]TEST'.   Unix examples include 
;		'/home/idl/lib', or '$IDL_HOME/pro'.   
;
; Opt. Inputs :	
;	exten - string giving a default file name extension to be used if
;		filename does not contain one.  Do not include the period.
;
; Outputs     :	
;	File_spec - Complete file specification using default disk or 
;		directory when necessary.  If the default directory
;		is UIT$USER1:[IDL] then, for the above VMS examples, the
;		output would be 'UIT$USER2:[IDL]TEST.DAT'
;		'UIT$USER2:[IDL.SUB]TEST'. 
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	FDECOMP
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Operating_System
;
; Prev. Hist. :	
;	Written W. Landsman         STX         July, 1987
;	Revised for use on VAXes and on SUNs, W.  Landsman, STX   August 1991
;
; Written     :	W. Landsman, GSFC/UIT (STX), July 1987
;
; Modified    :	Version 1, William Thompson, GSFC, 29 March 1994
;			Incorporated into CDS library
;		Version 2, Wayne Landsman, GSFC, September 1995
;			Added Windows and Macintosh compatibility
;		Version 3, Wayne Landsman, GSFC, 31 May 1997
;			Work for relative Unix directory
;		Version 4, Wayne Landsman, GSFC, September 1997
;			Expand Unix tilde if necessary
;
; Version     :	Version 4, September 1997
;-
;
 On_error,2                                     ;Return to user

 unix = OS_FAMILY() EQ 'unix'
 filname = filename
 if unix then if strpos(filname,'~') GE 0 then filname = expand_tilde(filname) 
 fdecomp,filname,disk,dir,name,ext             ;Decompose filename

 if (ext EQ '') and ( N_params() GT 1) then $   ;Use supplied default extension?
                    ext = extension

 environ = (unix) and (strmid(dir,0,1) EQ '$')

 if not environ then begin
 if (unix) and (strmid(dir,0,1) NE '/')  then begin
     cd,current=curdir
     dir = curdir + '/' + dir
 endif

 if (dir EQ '') and (!VERSION.OS NE "vms") and (not environ) then begin

    cd,current=dir
    if name NE '' then begin
	case OS_FAMILY() of 
	'windows': dir = dir + '\'    ;Get current default directory
	'MacOS': 
	 else: dir = dir + '/'
	endcase
    endif
 
 endif else begin

   if ( disk EQ '' ) or ( dir EQ '' ) then begin
     cd,current=defdir                          ;Get current default directory
     fdecomp,defdir,curdisk,curdir
     if disk EQ '' then disk = curdisk else begin
       if !VERSION.OS EQ "vms" then begin
         logname = strmid(disk,0,strpos(disk,':'))
         test = trnlog(logname,fname)
         if test then begin
            if strmid(fname,strlen(fname)-1,1) EQ ']' then begin
               if strmid(fname,strlen(fname)-2,1) NE '.' then $
                                  return,spec_dir(fname+name,ext)
            endif else return,spec_dir(fname+':'+dir+name,ext)
         endif
       endif
     endelse

    if dir eq '' then dir = curdir else if !VERSION.OS EQ 'vms' then begin
        if strpos(dir,'.') eq 1 then dir = $
           strmid(curdir,0,strlen(curdir)-1) + strmid(dir,1,strlen(dir)-1)
     endif

 endif
 
 endelse
 endif

 if ext ne '' then ext = '.'+ext

 if !VERSION.OS ne "vms" then return,dir+name+ext else  $             ;Unix
                               return,strupcase(disk+dir+name+ext)   ;VMS

end

pro file_purge, infil, interactive=interactive, keep=keep, 		    $
			bydate=bydate, byname=byname, 			    $
                        path=path, directory=directory,  		    $
			pattern=pattern, filter=filter
;+
;  NAME:
;    file_purge
;  PURPOSE:
;    Purge files that have similar file names.  Purge is based on 
;    file name (alphabetical listing) or by reverse creation date.
;  CALLING SEQUENCE:
;    file_purge, infil [,/interactive,/bydate,keep=keep]
;    file_purge, infil [,/interactive,/byname,keep=keep]
;    file_purge, path=path [pattern='filepattern'] 		 
;							
;  INPUTS:
;    infil	= A file name or a vector of file names (wild cards O.K.)
;  OPTIONAL KEYWORD INPUTS:
;    interactive = If set, prompt the user before deleting.
;    keep        = The number to keep.  Values less than 1 will cause no
;		   action to be taken.  Default = 1.
;    bydate	 = Delete the oldest files.
;    byname	 = Delete the alphabetically. (file ab is deleted before ac).
;		   Specify /bydate or /byname but not both (/byname = default).
;    directory   = if set, do a directory listing (no infil passed)
;    path        = synonym for directory
;    pattern     = only used with DIR keyword - if set, only match this pattern
;    filter      = synonym for PATTERN
;
;  OUTPUTS:
;    None.
;  RESTRICTIONS:
;    For unix only.
;  MDDIFICATION HISTORY:
;    Written, 19-sep-92, J. R. Lemen, LPARL.
;	 7-Dec-92 (MDM) - Made the delete command use "-f" option
;	27-Apr-93 (MDM) - Modification to work even when the input list is
;			  a long list of filenames
;        7-Aug-93 (SLF) - use file_delete.pro (bypass shell speed/alias probs)
;			  add dir keyword
;        2-oct-95 (SLF) - add FILTER,PATTERN, and PATH keywords 
;			  
;-

bell = string(7b)
if strlowcase(!version.os) eq 'vms' then begin		; Make sure we unix
    print,' *** file_purge:  Not implemented for VMS ***',bell
    return
endif


if keyword_set(directory) then tempdir=directory else $
   if keyword_set(path) then tempdir=path
bydir=keyword_set(tempdir)
bydate=keyword_set(bydate)
byname=keyword_set(byname) or (1-bydate)

if keyword_set(filter) then patt=filter else $
   if keyword_set(pattern) then patt=pattern

nlist = n_elements(infil)
if nlist eq 0 and not bydir then begin
    print,' *** file_purge:  infil is not defined ***',bell
    return
endif

case 1 of
    bydate and byname: begin
       print,' *** file_purge:  You cannot specify both /bydate and /byname ***',bell
       return
    endcase
    bydate: cmd='ls -1tr' 
    else: cmd = 'ls -1'
endcase

if n_elements(keep) eq 0 then nkeep = 1 else nkeep = keep

if nkeep lt 1 then begin
    print,' *** file_purge:  keep must be at least 1 ***',tbeep
    return
endif

if bydir then begin
   if nlist gt 0 then begin
      message,/info,"Can't use infil and /DIR keyword"
      message,/info,"Use PATTERN or FILTER to use file filters with PATH/DIRECTORY"
      return
   endif else begin
      tenv=get_logenv(tempdir)
      if tenv ne '' then tempdir=tenv
      spawn,[str2arr(cmd,' '),tempdir],/noshell,result
      result=concat_dir(tempdir,result)
   endelse
endif else begin
   for i=0,nlist-1 do cmd = cmd + ' '+infil(i)
   cmd = 'unalias ls; ' + cmd		;MDM added 27-Apr-93
   spawn, cmd, result
endelse

if bydir and keyword_set(patt) then begin
   ss=wc_where(result,'*' + patt + '*',sscnt)
   if sscnt eq 0 then result='' else result=result(ss)
endif

ndel = n_elements(result)
if (ndel eq 1) and (strlen(strtrim(result(0),2)) eq 0) then return
if (ndel le nkeep) then begin
  print,'Less than ',strtrim(nkeep,2),' files:  No files deleted'
  return
endif

; 7-aug-1993 (SLF) - use file_delete to bypass shell speed and
;                    alias problems

if keyword_set(interactive) then begin
   prstr,result
   print,'----------------------------'
   for i=0,ndel-nkeep-1 do begin
      yesnox,'Delete file: ' + result(i),yn
      if yn(0) then file_delete,result(i)
   endfor
endif else    file_delete,result(0:ndel-nkeep-1)

return
end

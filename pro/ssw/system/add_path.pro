;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ADD_PATH
;
; PURPOSE:
;       Add directory (and optionally all its subdirs) into IDL path
;
; CALLING SEQUENCE:
;       ADD_PATH, path_name [,/append] [,index=index]
;
; INPUTS:
;       path_name -- A string scalar of a valid directory name.
;
; OPTIONAL INPUTS:
;       INDEX -- Position in the !path where the directory name is inserted;
;                ignored if the keyword APPEND is set.
;
; OUTPUTS:
;       None, but !path is changed.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       APPEND -- By default, the given directory name is added in the
;                 beginning of !path. Set this keyword will add the directory
;                 name in the end of !path.
;       EXPAND -- Set this keyword if the PATH_NAME needs to be expanded.
;
;       SORT_PATH   -- sort added path alphabetically
;
; CATEGORY:
;       Utilities, OS
;
; PREVIOUS HISTORY:
;       Written October 8, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, GSFC/ARC, October 17, 1994
;          Added EXPAND keyword
;	Version 3, William Thompson, GSFC, 29 August 1995
;		Modified to use OS_FAMILY
;	Version 4, Zarro (EITI/GSFC), 20 Jan 2002, added /QUIET
;       25-May-2002, Zarro (EITI/GSFC) - added /SORT_PATH and cleaned up
;       18-Feb-2004, Zarro (L-3Com/GSFC) - added calls to LOCAL_NAME and
;                                          GET_PATH_DELIM
;-

pro add_path, path_name, index=index, append=append, expand=expand, $
              quiet=quiet,sort_path=sort_path,_extra=extra

   verbose=1-keyword_set(quiet)

   if n_elements(path_name) eq 0 then begin
    message, 'Syntax: add_path, dir_name [,/append]',/cont
    return
   endif

   if is_blank(path_name) then begin
    message, 'input parameter must be of string type.',/cont
    return
   endif
  
   path_name=local_name(path_name)
   if not is_dir(path_name,out=full_name) then begin
    print, 'Sorry, but '+path_name+' is not a valid directory name, '+$
            'and cannot be'
    print, 'added into the IDL path.'
    return
   endif

   if n_elements(index) eq 0 then index = 0
   delimit=get_path_delim()

;   case os_family(/lower) of
;      'vms':  delimit = ','
;      'windows':  delimit = ';'
;      else: begin
;         delimit = ':'
;         home_dir = getenv('HOME')
;         if strmid(full_name,0,2) eq '~/' then $
;          full_name = concat_dir(home_dir,strmid(full_name,2,9999)) $
;         else begin ; if it is a subdirectory, attach the whole path to it
;          cd,current = curr_dir
;          full_path = concat_dir(curr_dir, full_name)
;          if is_dir(full_path,out=temp_name) then full_name = temp_name
;         endelse
;      end
;   endcase

   dir_names = str_sep(!path, delimit)
   nd = n_elements(dir_names)
   if index gt nd-1 then index = nd-1
   
   if keyword_set(expand) then begin
      names = strtrim(expand_path('+'+full_name,_extra=extra,/array),2)
      check=where(names ne '',count)
      if count eq 0 then begin
       print, 'Apparently there are no .pro or .sav files in '+path_name+$
               '...'
       print, 'No action is taken.'
       return
      endif
;      names = str_sep(p_name,delimit)

;-- sort expanded paths

      if n_elements(names) gt 1 then begin
       s=sort(names)
       names=names[s]
      endif

      for i = 0, n_elements(names)-1 do begin
       id = where(dir_names eq names[i])
       if id[0] ne -1 then begin 
        if verbose then print, names[i]+' already in the idl path.' 
       endif else begin
        if n_elements(idd) eq 0 then idd = i else idd = [idd,i]
       endelse
      endfor
      if n_elements(idd) eq 0 then return
      full_name = arr2str(names(idd),delimit)
   endif 

   if keyword_set(append) then begin
    !path = !path+delimit+full_name
   endif else begin
    if index eq 0 then $
     !path = full_name+delimit+!path $
    else $
     !path = arr2str(dir_names[0:index-1],delimit)+delimit+$
     full_name+delimit+$
     arr2str(dir_names[index:nd-1],delimit)
   endelse
   names = str_sep(full_name,delimit)
   n_path = n_elements(names)-1
   for i = 0, n_path $
    do if verbose then print, names[n_path-i]+' added to IDL path.'

   return & end


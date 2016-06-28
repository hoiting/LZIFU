function new_version, filename , move=move, copy=copy
;+
;   Name: new_version
; 
;   Purpose: construct new file name using VMS-like syntax 
;
;   Input Parameters:
;      filename - string containing current file name (may include path)
;
;   Optional Keyword Paramters:
;      move - if switch (=1) then change name (move) on same path
;	      if string pathname, copy new file to move with new name
;
;   Output Paramters:
;      function returns new file name (including path)
;
;   Side effects:
;      if move or copy keywords set, new file is written to specified path
;      (otherwise, filename is constructed but no file action is taken)
;
;  Restrictions: 
;	unix only for now?
;	assumes all charcters after the semicolon represent the integer
;	version number
;
;   History: 
;	slf, 1-Dec-1992		
;-
;
; get the input file name
break_file, filename, log, fpath, fname, fext, fvers
fname=fname + fext
if fname eq '' then message,'No valid input file'

; determine output file path 
if fpath eq '' then fpath = curdir()
smove=size(move)
case smove(1) of
   0: opath=fpath
   7: opath=move
   else: opath=fpath
endcase

; use the highest existing version in output directory, if others exist
exist_vers=file_list(opath,fname + '*')
if exist_vers(0) ne '' then begin
   exist_vers=reverse(exist_vers)	; last is first
   break_file, exist_vers(0), flog, fpath, fname, fext, fvers
   fname=fname + fext
   message,/info,'Current high version is: ' + exist_vers(0)
endif


; determine output file name
if fvers eq '' then oname = fname + ';1' else begin
   newvers=fix(strmid(fvers,1,1000)) + 1
   oname = fname + ';' + strtrim(newvers,2)
endelse

; construct output file name
newname=concat_dir(opath,oname)

; now make the move if requested
if keyword_set(move) then begin
   if strlowcase(!version.os) ne 'VMS' then begin
      mvcmd='mv -f "' + filename + '" "' + newname + '"'
   endif else begin
      mvcmd='copy ' + filename + ' ' + newname
   endelse
   message,/info, mvcmd
   spawn,mvcmd   
endif
;
return,newname
end


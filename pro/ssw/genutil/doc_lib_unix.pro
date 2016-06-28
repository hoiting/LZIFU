pro doc_lib_unix, name, print=printflg, directory = direct, multi = multi
;+NODOCUMENT
; NAME:
;	DOC_LIB_UNIX
; PURPOSE:
;	Extract the documentation template of one or more procedures.
; CATEGORY:
;	Help, documentation.
; CALLING SEQUENCE:
;	doc_lib_unix	;For prompting.
;	doc_lib_unix, Name ;Extract documentation for procedure Name using
;			the current !PATH.
; INPUTS:
;	Name = string containing the name of the procedure or "*" for all.
;	
; OPTIONAL INPUT PARAMETERS:
;	PRINT = keyword parameter which, if set to 1, sends output
;		of doc_lib_unix to lpr.  If PRINT is a string, it is a shell
;		command used for output with its standard input the
;		documentation.  I.e. PRINT="cat > junk"
;	DIRECTORY = directory to search.  If omitted, use  current directory
;		and !PATH.
;	MULTI = flag to allow printing of more than one file if the module
;		exists in more than one directory in the path + the current
;		directory.
; OUTPUTS:
;	No explicit outputs.  Documentation is piped through more unless
;	/PRINT is specified.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	output is produced on terminal or printer.
; RESTRICTIONS:
;	??
; PROCEDURE:
;	Straightforward.
; MODIFICATION HISTORY:
;	DMS, Feb, 1988.
;-

on_error,2              ;Return to caller if an error occurs
if n_elements(name) eq 0 then begin	;Interactive query?
	name = ''
	printflg = 0	
	read,'Name of procedure or * for all: ',name
	read,'Enter 1 for printer, 0 for terminal: ',printflg
	endif
name = strlowcase(name)		;make it always lower case

if n_elements(direct) eq 0 then path = ".:" + !path $	;Directories to search
	else path = direct
if n_elements(printflg) eq 0 then output = " more " $
else if strtrim(printflg,2) eq '1' then output = " lpr " $
else if strtrim(printflg,2) eq '0' then output = " more " $
else output = "'"+printflg+"' "

if n_elements(multi) le 0 then multi = 0	;Only print once
if strpos(name,"*") ge 0 then begin	;Wild card?
	multi = 1		;allow printing of multiple files
	endif

cmd = !dir + "/bin/doc_library "+output+strtrim(multi,2)+' ' ;Initial cmd
	
while strlen(path) gt 0 do begin ; Find it
	i = strpos(path,":")
	if i lt 0 then i = strlen(path)
	file = strmid(path,0,i)+ "/" + name + ".pro"
;	print,"File: ",file
	;; MDM Removed 13-Nov-91 path = strmid(path,i+1,1000)
	path = strmid(path,i+1,strlen(path))
	cmd = cmd + ' ' + file
	endwhile
;print,cmd
; JPW Mar-92 : force use of Bourne shell in spawn routine
oldshell = getenv('SHELL')                       ; save current value
setenv,'SHELL=/bin/sh'                           ; set Bourne shell
spawn,cmd+ output
if oldshell ne '' then setenv,'SHELL='+oldshell  ; restore old value
end

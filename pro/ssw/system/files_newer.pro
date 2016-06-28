function files_newer, directory, reference, count, loud=loud
;+
;   Name: files_since
;
;   Purpose: return files in <directory>  newer than <reference> file
;
;   Input Parameters:
;      directory - directory to start search (recursive if tree)
;      reference - reference file (ex: a dbase file)
;                  OR integer number of days old
;  
;   Output Parameters:
;      count - number files found newer than reference  
;
;   Calling Sequence:
;     IDL> newfiles=files_newer(directory, reference [,count])
;  
;   Calling Example:
;      IDL> nf=files_newer('$INPUT_DIRECTOR','$DBASE_FILE')
;           (returns files in $INPUT_DIRECTOR which have been updated
;            since last update to $DBASE_FILE_
;  
;   Usage: updating dbase files if any potential input files
;          have been updated since last dbase update
;  
;   History:
;      6-March-1998 - S.L.Freeland - various ssw/dbase management uses
;  
;   Restrictions:
;      UNIX only
;-
if os_family() ne 'unix' then begin
   box_message,'Sorry, UNIX systems only'
   return,''
endif   

if n_params() lt 2 then begin
   box_message,['Need two parameters...', $
		'IDL> newfiles=files_since(directory, reference [,count] )']
   return,''   
endif

loud=keyword_set(loud)

ddir=directory(0)
chkenv=get_logenv(ddir)     ; allow environmentals

case 1 of 
   chkenv ne '':ddir=chkenv
   else:
endcase

cmd='find '+ ddir + ' -type f '+ $
     ([' -mtime ',' -newer '])(data_chk(reference,/string)) + $
     strtrim(reference(0),2)  + ' -print'

spawn,str2arr(cmd,' ',/nomult),retval, /noshell
count=n_elements(retval) - (retval(0) eq '')       ; nfiles or zero

if keyword_set(loud) then begin
   box_message,['Number of files newer than reference: ' + strtrim(count,2), $
		retval]
endif

return,retval
end

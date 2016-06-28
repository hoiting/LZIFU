function set_fastpath,arr=arr
;
;+
;   Name: set_fastpath
;
;   Purpose: use ys environmentals and path file to do fast path setup
;
;   Output:
;      function returns string in !path format
;
;   Optional Keyword Parameters:
;      arr - switch, if set, return as array, not delimited string
;
;   Calling Examples:
;      !path=set_fastpath()		; update IDL !path
;      parr =set_fastpath(/arr)		; array version
;
;   History:
;      21-Apr-93 (SLF) - to hide temp variables during IDL_STARTUP
;      10-oct-93 (slf) - allow '/ys/' <==> getenv('ys') for uniq check
;      29-Jun-94 (SLF) - dont eliminate astronomy library during fast start
;      30-Jun-94 (SLF) - dont add non-existant paths
;
;   Restrictions:
;      This routine must be in path already!  UNIX only for today
;-   

; system dependent delimiters
os=strlowcase(!version.os) eq 'vms'	; 0=unix,1=vms	
pdelims=[':',',']			; path delimiter
pdelim=pdelims(os)
fdelims=['/',':']			; file delimiter
fdelim=fdelims(os)

retval=!path				; intialize return value

; ------- read the file containing path information --------
; path=get_string(/path) ; for speed, file access code is here instead
on_ioerror,ioerr
pfile='$DIR_SITE_SETUPD' + fdelim + 'path.strx'
path=''
openr,lun,/get_lun,/xdr,pfile
readu,lun,path
free_lun,lun
on_ioerror,null
; ---------------------------------------

path=strtrim(str2arr(path,pdelim),2)
path=path(rem_elem(path,getenv('IDL_DIR') + '/pro'))

personal=strtrim(str2arr(!path,pdelim),2)

; eliminate yohkoh related elements from personal part
noysp=where( strpos(personal,'/ys/') ne 0 and $
	     strpos(personal, getenv('ys')) ne 0 OR $ 
	     strpos(personal, 'libraries') ne -1, noyscnt)

if noyscnt gt 0 then personal=personal(noysp) else personal=''

; order of file/personal is determined by ys environmental: ys_ahead
if getenv('ys_ahead') ne '' then $
   retarr = [personal , path] else retarr = [path , personal]
;
nnull=where(retarr ne '')
retarr=retarr(nnull)
uarr=uniqo(retarr)		; eliminate duplicate entries, preserve order
retarr=retarr(uarr)		; using 'temp' (ys eliminated)

if keyword_set(arr) then retval=retarr else $
   retval=arr2str(retarr,pdelim)

return,retval		; normal exit

ioerr:
message,/info,'Error reading path file, returning !path
return, retval
end

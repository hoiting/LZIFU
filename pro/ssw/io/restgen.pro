pro restgen,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
	struct=struct, text=text, header=header, file=file, quiet=quiet, $
	inquire=inquire, nodata=nodata
;
;+ 
;   Name: restgen
;
;   Purpose:
;      read & restore parameters (idl variables) from a generic file
;      [front end to rd_genx - reads files written by savegen.pro]
;
;   Output Parameters
;      p0,p1,p2...p15 - variables to restore from file
;
;   Optional Keyword Parameters
;      file   - (Input) generic file name [default='save.genx']
;      struct - (Output) entire data structure from generic file
;      text   - (Output) optional text section from file (if it exists)
;      header - (Output) system imposed file header (added via wrt_genx)
;      quiet  - (input)  if set, inhibit some messages
;      inquire - (input) if set, display summary of generic file
;      nodata  - (input) if set, dont read data section (just header and text)
;      
;   Calling Sequence:
;      restgen,v1, [,v2...v15 , file=filename, text=text, header=header, /inq]
;                  [,struct=struct, /nodata]
;		    
;   Calling Examples:
;      restgen, a, b, c, text=text		; restore 'save.genx' 
;      restgen, file='newdat',/inquire,/nodata  ; show summary of 'newdat.genx'
;      restgen, struct=struct			; file contents as structure
;      restgen, head=head,text=text		; just header and text 
;      [see documentation for savegen.pro]

;   History: 
;      11-Jan-91 S.L. Freeland - written
;	8-Nov-91 MDM expanded from 10 to 15 parameters
;      29-jan-93 slf, added quiet keyword
;      24-mar-93 slf, documentation , protect file input from clobber
;		      added inquire and nodata keywords
;      30-Mar-94 slf, minor docmentation fixes
;      17-May-94 ras, fix double period bug in filename construction
;      24-May-96 SLF, work around bug in findfile (semicolon file names)
;-
qtemp=!quiet

on_error,2					; return to caller

if not keyword_set(file) then file='save' 	; default 
infile=file(0)

if not file_exist(infile) then begin
   length = strlen(infile) -1                                                 	;ras 17-May-94
   if strpos(infile,'.',length) eq length then infile = infile + 'genx' else $  ;ras 17-May-94
   infile=infile+ '.genx'
endif

if not file_exist(infile) then message,'No gen files with names: <' + file + $
	'> or <' + infile + '> found!'

!quiet=1					; suppress compilation
on_ioerror,err
rd_genx,infile,data,text=text,header=header, $  ; get super structure 
	inquire=inquire, nodata=nodata	
!quiet=qtemp					; restore quiet status
goto,okread
err:
message,/info,'Problem with file read - probably not genx format!!'
return
okread:
;						; slf, use temporary function
struct=temporary(data)				;copy to output key
;
!quiet=keyword_set(quiet)
n_return=n_tags(struct)			
if n_return lt n_params() then $
   message,/inform,'only '+ string(n_return) + $
      ' data structures in file'
params=strcompress('p' + sindgen(n_return),/remove_all)
for i=0, n_tags(struct)-1 do begin
   exestr=params(i) + '=struct.(i)'
   status=execute(exestr)
endfor
!quiet=qtemp
return
end

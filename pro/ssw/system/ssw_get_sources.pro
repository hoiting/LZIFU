pro ssw_get_sources, outdir=outdir, delete=delete, $
   tarit=tarit, tarfile=tarfile, status=status 
;+
;   Name: ssw_get_sources
;
;   Purpose: "get" and optionally tar currently compiled functions/procedures
;
;   Input Paramters:
;      none
;
;   Keyword Paramters:
;      outdir - directory for sources; default finds a temporary scratch area
;      tarit  - if set, tar the sources - tar file name is:       
;                  /OUTDIR/ssw_sources_YYYYMMDD_HHMM.tar
;      tarfile - (OUTPUT) - name of derived/written tar file
;      delete - delete sources after tar is made ( only if /TARIT set only ) 
;      status - boolean success 1=OK , 0 = Problem w/source and/or TAR

;
;   Calling Sequence:
;      IDL> ssw_get_sources [,outdir=outdir, /tarit, delete=delete]
;          
;   Calling Examples:
;      IDL> ssw_get_sources, outdir=curdir()  ; copy sources -> PWD
;      IDL> ssw_get_sources, /tarit, /delete  ; above + make tar+delete copies 
;
;   Calling Context:
;      IDL> [run some SSW stuff]
;      IDL> ssw_get_sources, /tarit, /delete, status=status, tarfile=tarfile
;      IDL> if status then ... (archive TARFILE for example)
;
;   History: 
;      19-December-2002 - S.L.Freeland 
;
;   Method:
;      call RSI routine_info, copy compliled $SSW sources -> temp and
;             optionally tar and delete
;
;   Restrictions: UNIX/Linux/MacX only
;-

tarit=keyword_set(tarit)
delete_sources=keyword_set(delete)

; setup temporary area for source copy if OUTDIR not supplied by user
if not file_exist(outdir) then begin   
    temptop=get_temp_dir()
    mk_temp_dir,temptop,outdir, err=err
    if err(0) ne '' then begin 
       box_message,'Error creating temporary directory'
       return
    endif  
endif

procs=routine_info(/source)             ; procedures
funcs=routine_info(/source,/functions)  ; functions

allpros=concat_struct(procs,funcs)
ss_source=where(allpros.path ne '',sscnt)  ; *.pros 

break_file,allpros(ss_source).path,ll,pp,ff,vv,ee
fnames=ff+vv+ee 
newnames=concat_dir(outdir,fnames)

newexist=file_exist(newnames)             ; check for exist
needss=where(1-newexist,ncnt)             ; needed

for i=0,ncnt-1 do $ 
   spawn,['cp','-p',allpros(ss_source(needss(i))).path,outdir(0)],/NOSHELL

newexist=file_exist(newnames)
okss=where(newexist,okcnt)
nsources=n_elements(newnames)
if okcnt ne nsources then box_message,'Not all source files copied..'
status=okcnt eq n_elements(newnames)
box_message,(['Not all source files copied to >> ', $
  'All ' + strtrim(nsources,2) + ' sources copied to >> '])(status) + outdir(0)

if tarit then begin
   tarfile=(concat_dir(outdir,'ssw_sources_'+ $         ; tarfile name
      time2file(reltime(/now))))(0) +'.tar'
   tarcmd=['tar','-cf',tarfile,fnames]                  ; implied tar command
   cdir=curdir()
   cd,outdir(0) 
   spawn,tarcmd,/NOSHELL                                ; sources -> tar
   cd,cdir                                              ; restore pwd
   status=status and (file_exist(tarfile))
   box_message, $
      (['Problem Writing> ','Wrote TAR> '])(file_exist(tarfile)) + tarfile(0) 
   if delete_sources then ssw_file_delete,newnames(needss)
endif

return
end








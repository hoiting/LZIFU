function check_compile, module_name, log=log, nodelete=nodelete, debug=debug
;
;+
;   Name: check_compile
;
;   Purpose: verify whether input module will compile (syntax checker)
;
;   Input Parameters:
;      module_name - name of idl procedure/function file to check
;
;   Keyword Parameters:
;      log - contents of output log file
;
;   Calling Sequence:
;      status=check_compile(module_name [,log=log])
;
;   History:
;      14-Apr-1994 (SLF) Written (to check submitted software)
;       5-May-1994 (SLF) Turn off batch monitoring for submitted job
;
;   Restrictions: 
;      UNIX only 
;-

if n_elements(module_name) eq 1 then module_name=module_name(0)
if not data_chk(module_name,/string,/scaler) then begin
   tbeep 
   message,/info,'Calling Sequence:   IDL> status=check_compile(module_name)
   return,0
endif

break_file,module_name, log, path, cmod_nopro, ext, ver
fidnow=ex2fid(anytim2ex(!stime))
logfile= concat_dir(getenv('HOME'), cmod_nopro + '_' + fidnow + '.log')
cmod_nopro = concat_dir(path,cmod_nopro)
cmod_pro = cmod_nopro + '.pro'

if not file_exist(cmod_pro) then begin
   tbeep
   message,/info,"Can't find file: " + cmod_pro + " ..., returning"
   if file_exist(cmod_nopro) then message,/info,"Input file must have .pro extension"
   return,-1
endif

;doc_summ,cmod_pro,doc_str=ds
main =0
code=rd_tfile(cmod_pro,/compress)
lowcode=strlowcase(code)
funcdef=where(strpos(lowcode,'function ') eq 0 ,fcnt)
prodef =where(strpos(lowcode,'pro ') eq 0, pcnt)
types=['FUNCTION','PROCEDURE']
case total([fcnt,pcnt]) of
   0: begin
         message,/info,'Might be a MAIN level routine(?)'
         cmod_prot = cmod_pro
         cmod_nopro = str_replace(logfile,'.log','')
         cmod_pro   = cmod_nopro + '.pro'
         file_append,cmod_pro,[rd_tfile(cmod_prot),'stop']
         main=1
   endcase
   1: message,/info, cmod_pro + ' is a ' + types(pcnt) ; function or procedure
   else: begin
      tbeep
      message,/info,'Multiple function/procedure definitions detected...'
      message,/info,'This routine cannot currently verify compilation, returning'
      return,-1
   endcase
endcase

bcommand="nohup /ys/gen/script/idl_batch /nomonitor " + cmod_nopro + " "  + logfile
if keyword_set(debug) then print,'Spawning: ' + bcommand
spawn, bcommand, outspawn
check_log,logfile,/nomail,status=status,/quiet	; use existing check_log.pro
log=rd_tfile(logfile)

main_mess=['MAIN routine Compile Problem','MAIN Routine Compiled OK']
if main then begin
   message,/info,'Trying to determine MAIN program compliation...'
   compmess=where(strpos(log,'% Compiled module: $MAIN$.') ne -1,cnt)
   status=cnt gt 0
   message,/info,main_mess(status)
endif else begin
   compmess=['Compilation Problem','Compilation OK']
   message,/info,compmess(status)
endelse

if not keyword_set(nodelete) then begin
   file_delete,logfile			; remove logfile
   if main then file_delete, cmod_pro	; remove test version MAIN.pro
endif

return,status
end

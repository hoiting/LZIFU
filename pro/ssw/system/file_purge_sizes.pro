pro file_purge_sizes, files, keep=keep, path=path, pattern=pattern, $
		      below_size=below_size, above_size=above_size, $
		      logs=logs, loud=loud, testing=testing
;+
;   Name: file_purge_sizes
;
;   Purpose: purge files > -OR- < some file size threshold
;
;   Input Parameters:
;      files - the file list to consider (may alternately use PATH and PATTERN)
;
;   Keyword Parameters:
;      PATH - path to 'look' in
;      PATTERN - file pattern to look for
;      KEEP - number of matching files to keep around
;      ABOVE_SIZE - only consider purging files > than this size
;      BELOW_SIZE - only consider purging files < than this size  
;      LOGS - if set, set PATH=>$SSW_SITE_LOGS
;      TESTING - show what it WOULD have purged without actually doing it
;  
;   Calling Sequence:
;      file_purge_sizes, files, keep=nn, below_size=XXX
;      file_purge_sizes, pattern=xxx, path=zzz, keep=nn, above_size=XXX
;  
;   History:
;      18-November-1998 - S.L.Freeland - initially for log file maint.
;                         Example - want to keep all "interesting" logs from
;                         a high cadence cron job where "interesting" is
;                         larger than some threshold size but limit
;                         accumulation of "uninteresting" logs 
;                    
;
;
;-
testing=keyword_set(testing)
loud=keyword_set(loud) or testing

if not keyword_set(keep) then keep=1
if not keyword_set(pattern) then pattern='*.log'        ; default log files
if keyword_set(logs) then path=get_logenv('SSW_SITE_LOGS')

case 1 of
   data_chk(files,/string): pfiles=files
   data_chk(path,/string):  pfiles=file_list(path,pattern,/cd)
   else: begin
      box_message,'Must specify FILES or PATH'
      return
   endcase
endcase   
   
sspf=where(pfiles ne '',pcnt)

if pcnt eq 0 then begin
   box_message,'No files match path and pattern'
endif  else pfiles=pfiles(sspf)

sizefiles=file_size(pfiles)

case 1 of
   keyword_set(below_size): ss=where(sizefiles le below_size,pcnt)
   keyword_set(above_size): ss=where(sizefiles gt above_size,pcnt)
   else: ss=lindgen(pcnt)
endcase  

if pcnt gt keep then begin
   npurge=pcnt-keep
   spurge=strtrim(npurge,2)
   mess=['Purging ' + spurge + ' files...']
   if testing then mess=['TESTING MODE, NOT REALLY PURGING']
   pwhich=pfiles(ss(0:npurge-1))
   if loud then mess=[mess,'   ' + pwhich]
   box_message,mess
   if not testing then file_delete,pwhich
endif else box_message,'Number files < KEEP, not purging'

return
end

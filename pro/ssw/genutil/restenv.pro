pro restenv, quiet=quiet
;+ 
;   Name: restenv
;
;   Purpose: restore environment (UNIX environmentals/VMS logicals)
;            (which were stored by previous call to saveenv)
;
;   History:
;      9-Jan-1994 (SLF)
;
;   Method:
;      calls set_logenv.pro to update envrionment
;
;   Common Blocks:
;      saveenv_blk (store environmentals and translation)
;
;-

common  saveenv_blk, environs, translations

loud=1-keyword_set(quiet)

if n_elements(environs) eq 0 then begin
   message,/info,"No previous call to saveenv - nothing changed..."
   return
endif

trans=get_logenv('*',env=env,count=count)	; get current environment

diffcnt=0
ss=where(translations ne trans,diffcnt)

if  diffcnt eq 0 then message,/info,"Nothing has changed - no action..." else begin
   if loud then message,/info, $
      "Restoring " + strtrim(diffcnt,2) + " environmentals to saved values..."
   for i=0,diffcnt-1 do $
      set_logenv,environs(ss(i)), translations(ss(i)), quiet=(1-loud)
endelse

return

end


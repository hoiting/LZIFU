pro saveenv, quiet=quiet
;+ 
;   Name: saveenv
;
;   Purpose: save current environment (UNIX environmentals/VMS logicals)
;            (for temporary change and later restoration via restenv.pro)
;
;   History:
;      9-Jan-1994 (SLF)
;
;   Method:
;      calls get_logenv.pro to return envrionment
;
;   Common Blocks:
;      saveenv_blk (store environmentals and translation)
;
;   Assumptions/Restrictions
;-

common  saveenv_blk, environs, translations

loud=1-keyword_set(quiet)

trans=get_logenv('*',env=env,count=count)	; get all environmentals

if n_elements(environs) eq 0 then begin
   if loud then message,/info,"Saving " + strtrim(count,2) + " environmentals..."
   environs=env
   translations=trans  
endif else begin
   etemp=environs
   ttemp=translations
   if count gt n_elements(environs) then begin
      etemp=strarr(count)
      ttemp=etemp
      etemp(*)=environs   
      ttemp(*)=translations
   endif
   ss=where(ttemp ne trans,diffcnt)
   environs=etemp
   translations=ttemp
   if loud and ss(0) ne -1 then message,/info, $
      strtrim(diffcnt,2) + " new or updated entries saved..."
stop
endelse

return

end


pro ucon_path, yohkoh=yohkoh, soho=soho, ssw=ssw, $
	add=add, remove=remove, quiet=quiet, prepend=prepend, $
        allucon=allucon, _extra=_extra
;+
;   Name: ucon_path
;
;   Purpose: manage ucon portions of SSW path
;
;   Calling Sequence:
;      ucon_path, [/XXX, /yohkoh, /soho, /ssw, /add, /remove, /quiet]
;
;   Input Paramters:
;      NONE:
;
;   Keyword Parameters:
;      yohkoh - switch , if set, yohkoh ucon path is target (default)
;      soho   - switch , if set, soho ucon path is target
;      sss    - switch , if set, ssw  ucon path is target
;      add    - switch , if set, add the associated ucon paths
;      remove - switch , if set, remove the associated ucon paths
;      XXX    - XXX = ucon (user) name - add/remove specific ucon areas
;      all    - if set, add or remove them all
;
;   Side Effects:
;      The IDL !path variable may be changed
;
;   Category:
;      system, environment, IDL
;
;   Method:
;      may call ssw_path and/or pathfix
;
;   History:
;      21-Feb-1996 S.L. Freeland
;      29-feb-1996 S.L. Freeland
;       9-oct-1996 S.L. Freeland - add hudson
;      14-oct-1996 S.L. Linford  - add linford
;      13-feb-1997 S.L. Freeland - sakao
;      28-feb-1997 S.L. Freeland - add ALL and _extra
;-

common ucon_path_blk,all     ; assume no new UCON directories created session

soho=keyword_set(soho)
ssw=keyword_set(ssw)
yohkoh=keyword_set(yohkoh) or (1-soho and 1-ssw)
quiet=keyword_set(quiet)

rempath=''
addpath=''
; SSW users who have ucon routines referenced by 'outside' routines 

ext_ucon=concat_dir(get_logenv('$SSW_SITE_SETUPD'),'ext_ucon')  ; file via ssw monitor job

if file_exist(ext_ucon) then begin
   ucon=rd_tfile(ext_ucon)
   yg=ucon(wc_where(ucon,'ys'))
endif else begin
   yg=['acton','bentley','freeland','hudson','labonte','lemen','linford','mcallister','sato']
   yg=[yg,'mctiernan','metcalf','morrison','sakao','schwartz','slater','wuelser','zarro']
endelse


root=concat_dir('ucon','idl')			; assumption for all 
topucon=concat_dir('$ys',root)

if keyword_set(allucon) or data_chk(_extra,/struct) then begin
   if n_elements(all) eq 0 then all=expand_path('+'+topucon,/array)
   break_file,all,ll,pp,yg
   if data_chk(_extra,/struct) then begin
       users=strlowcase(tag_names(_extra))
       which=where_arr(yg,users,count)      
       if count eq 0 then begin
          message,/info,"No UCON paths matching: " + arr2str(users, ' OR ' )
          return  ; *** early exit
       endif
       yg=yg(which)
   endif
endif

case 1 of 
   yohkoh: begin
      addpath=concat_dir(topucon,yg)
      rempath=addpath
   endcase
   soho: message,/info,"No SOHO ucon areas yet defined..."
   ssw:  message,/info,"No SSW ucon areas yet defined..."
   else:
endcase

remove=keyword_set(remove) and rempath(0) ne ''
add=keyword_set(add) or (addpath(0) ne '' and 1-remove)

nadd=n_elements(addpath)
nrem=n_elements(rempath)

case 1 of 
   add: ssw_path, addpath, quiet=quiet, prepend=prepend
   remove: pathfix,addpath,/remove,/quiet
   else: if not quiet then message,/info,"No changes to UCON areas"
endcase

return
end


pro rmosaic, _extra=_extra
;
;+
;   Name: rmosaic
;
;   Purpose: spawn background mosaic job, optional 'solar' hotlist lookup
;
;   Calling Sequence:
;      rmosaic				; url menu select
;      rmosaic [,/search_string]	; search string = url lookup
;
;   Calling Examples:
;      rmosiac,/trace			; TRACE home page
;      rmosaic,/yag			; Yohoh analysis guide
;      rmosaic,/soho			; SOHO home page
;
;   History:
;      26-Jan-95 (SLF) 
;       2-Feb-95 (SLF) - add keyword inheritence for search strings to allow
;                        automatic expansion
;
;   Restrictions:
;      if no local version, environmental <mosaic_host> should
;      point to remote host - in this case, must have RSH priviledge
;-

hotlist=rd_tfile(concat_dir('$DIR_GEN_DATA','url.solar')) ; 
remtab,hotlist,notablist
notabcol=str2cols(notablist,'#')

ss=-1
;
; use keyword inheritance to auto-expand url hotlist search
if keyword_set(_extra) then $
  ss=(where(strpos( reform(notabcol(1,*)),(tag_names(_extra))(0)) ne -1))(0)

if ss(0) eq -1 then begin
   if keyword_set(_extra) then $
      message,/info,"Pattern <" + (tag_names(_extra))(0) + "> not found..."
   ss=wmenu_sel(strjustify(notabcol(1,*)) + ' ' + strjustify(notabcol(0,*)),/one)
endif

if ss(0) eq -1 then pattern='' else $
   pattern=strtrim(notabcol(1,ss(0)))

; spawn the rmosaic job
rmos='csh $DIR_GEN_SCRIPT/rmosaic' + ' ' + pattern  
message,/info,"Calling: " + rmos
spawn,rmos
return
end

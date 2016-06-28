;+
; Project     : SOHO-CDS
;
; Name        : CLEAN_PATH
;
; Purpose     : clean up SSW path by reorganizing directories
;
; Category    : utility
;
; Explanation : use this to move SUMER and YOHKOH UCON libraries to
;               end of IDL path to avoid potential conflicts.
;
; Syntax      : clean_path,new_path
;
; Outputs     : NEW_PATH = rearranged IDL !path
;
; Keywords    : NOSITE = exclude site directories
;               RESET = reset back to original state
;               NOUCON = exclude Yohkoh UCONS
;               NOSDAC = exclude SDAC FUND_LIB
;               NONRL  = exclude NRL directories
;
; Side effects: If NEW_PATH not on command line, !path is reset automatically
;
; History     : Written 22 Oct 1997, D. Zarro, SAC/GSFC
;		Version 2, 11-Dec-2001, William Thompson, GSFC
;			Moved rsi to top, so $IDL_DIR/lib/obsolete is not
;			removed from the path.
;			Don't change case of directories.
;               12 Feb 02 - Zarro (EITI/GSFC) - made Windows compatible and
;                       added check for pre-version 4 directories in !path
;
; Contact     : dzarro@solar.stanford.edu
;-
;----------------------------------------------------------------------------

pro check_idl_path,dir,libs,dlibs,exclude=exclude

delvarx,dlibs
if (n_elements(dir) eq 0) or (n_elements(libs) eq 0) then return

clibs=strlowcase(libs)

find_dir=strpos(clibs,strlowcase(local_name(dir)))
if n_elements(exclude) gt 0 then begin
 ex_dir=strpos(clibs,strlowcase(local_name(exclude)))
 have_dir=where((find_dir gt -1) and (ex_dir eq -1),count)
 no_dir=where( (find_dir lt 0) or (ex_dir gt -1),ncount)
endif else begin
 have_dir=where(find_dir gt -1,count)
 no_dir=where(find_dir lt 0,ncount)
endelse

if count gt 0 then dlibs=libs(have_dir)
if ncount gt 0 then libs=libs(no_dir) else delvarx,libs
if ncount eq 1 then libs=libs[0]
if count eq 1 then dlibs=dlibs[0]

return & end

;----------------------------------------------------------------------------

pro clean_path,new_path,reset=reset,nosite=nosite,noucon=noucon,$
                        nosdac=nosdac,nonrl=nonrl

common clean_path,orig_path,sav_path

message,'...cleaning !path',/cont
ucon=1-keyword_set(noucon)

if keyword_set(reset) then begin
 if exist(orig_path) then !path=orig_path
 return
endif else begin
 if not exist(orig_path) then orig_path=!path
endelse

libs=get_lib()

;-- remove path elements

ssw=chklog('$SSW')
rsi=chklog('IDL_DIR')
libs=local_name(libs)
check_idl_path,'mjastereo/idl',mjastereo
check_idl_path,'packages/nrl',libs,nrl_pack
check_idl_path,'idl/nrlgen',libs,nrl_libs
check_idl_path,rsi,libs,rsi_libs
check_idl_path,'/site/idl',libs,site_libs
if since_version('4.0') then check_idl_path,'/gen/idl_fix',libs,fix_libs
check_idl_path,'/obsolete',libs,obs_libs
check_idl_path,'/spartan',libs,spart_libs
;check_idl_path,'/jhuapl',libs,jhu_libs
check_idl_path,'/sdac',libs,sdac_libs
check_idl_path,'/astron',libs,astro_libs
check_idl_path,'/soho/sumer',libs,sumer_libs
check_idl_path,'/soho/lasco',libs,lasco_libs
check_idl_path,'/ucon/idl',libs,ucon_libs
check_idl_path,'/packages',libs,pack_libs
check_idl_path,'/smm',libs,smm_libs,exclude='/smmdac'
check_idl_path,'/trace/ssw_contributed/',libs,trace_cont2
check_idl_path,'/trace/ssw_contributed',libs,trace_cont
check_idl_path,'/trace/idl',libs,trace_libs
check_idl_path,'/mdi/idl',libs,mdi_libs
check_idl_path,'yohkoh',libs,yohkoh_libs,exclude='/ucon/idl'
check_idl_path,'/hessi/release',libs,hessi_libs_r
check_idl_path,'/hessi/idl',libs,hessi_libs
check_idl_path,'/batse',libs,batse_libs
check_idl_path,'/gen/idl/fund_lib',libs,fund_libs
check_idl_path,'/optical',libs,opt_libs
check_idl_path,'/soho/gen/idl',libs,soho_libs
check_idl_path,'/gen/idl_libs',libs,idl_libs
check_idl_path,'/gen/idl',libs,gen_libs
check_idl_path,'/cds/idl',libs,cds_libs
check_idl_path,'/eit/idl',libs,eit_libs
check_idl_path,'/ssw_bypass',libs,bypass_libs
check_idl_path,'/radio/ethz',libs,ethz_libs
check_idl_path,'/zastron',libs,zastro_libs
check_idl_path,'/hxrs',libs,hxrs_libs
check_idl_path,'/eis/idl',libs,eis_libs
check_idl_path,'/sot/idl',libs,sot_libs
check_idl_path,'/xrt/idl',libs,xrt_libs
check_idl_path,'/sxig12/idl',libs,sxi_libs
check_idl_path,'/galileo',libs,gal_libs
check_idl_path,'/solarb',libs,solarb_libs
check_idl_path,'/stereo',libs,stereo_libs

;-- put path back together

if exist(rsi_libs) then begin
 rsi_lib=local_name('$IDL_DIR/lib')
 if is_dir(rsi_lib) then begin
  chk=where(trim2(rsi_libs) ne rsi_lib,count)
  if count gt 0 then rsi_libs=rsi_libs(chk)
 endif
endif

if exist(gen_libs) then begin
 gen_lib=local_name('$SSW/gen/lib')
 if is_dir(gen_lib) then begin
  chk=where(trim2(gen_libs) ne gen_lib,count)
  if count gt 0 then gen_libs=gen_libs(chk)
 endif
endif


if not exist(libs) then libs=''

dprint,'% CLEAN_PATH: ',libs

if is_dir(gen_lib) then libs=[libs,gen_lib]
if exist(gen_libs) then libs=[libs,gen_libs]
if exist(fund_libs) then libs=[libs,fund_libs]
if is_dir(rsi_lib) then libs=[libs,rsi_lib]
if exist(cds_libs) then libs=[libs,cds_libs]
if exist(eit_libs) then libs=[libs,eit_libs]
if exist(hessi_libs) then libs=[libs,hessi_libs]

if exist(soho_libs) then libs=[libs,soho_libs]
if exist(trace_libs) then libs=[libs,trace_libs]

if exist(eis_libs) then libs=[libs,eis_libs]
if exist(yohkoh_libs) then libs=[libs,yohkoh_libs]
if exist(pack_libs) then libs=[libs,pack_libs]
;if exist(jhu_libs) then libs=[libs,jhu_libs]

;-- special handling for Astronomy library

if not exist(idl_libs) then begin
 idl_libs=local_name('$SSW/gen/idl_libs')
 if is_dir(idl_libs,out=fname) then idl_libs=expand_path('+'+fname)
endif

if exist(idl_libs) then begin
 libs=[libs,idl_libs]
 delvarx,astro_libs,zastro_libs
endif

if exist(stereo_libs) then libs=[libs,stereo_libs]
if exist(xrt_libs) then libs=[libs,xrt_libs]
if exist(sot_libs) then libs=[libs,sot_libs]
if exist(sxi_libs) then libs=[libs,sxi_libs]
if exist(mjastereo) then libs=[libs,mjastereo]
if exist(mdi_libs) then libs=[libs,mdi_libs]
if exist(batse_libs) then libs=[libs,batse_libs]
if exist(rsi_libs) then libs=[libs,rsi_libs]
if exist(ethz_libs) then libs=[libs,ethz_libs]
if exist(opt_libs) then libs=[libs,opt_libs]
if exist(hxrs_libs) then libs=[libs,hxrs_libs]
if exist(sumer_libs) then libs=[libs,sumer_libs]
if exist(lasco_libs) then libs=[libs,lasco_libs]
if exist(smm_libs) then libs=[libs,smm_libs]
if (1-keyword_set(nonrl)) and exist(nrl_libs) then libs=[libs,nrl_libs]
if exist(astro_libs) then begin
 libs=[libs,astro_libs]
 delvarx,zastro_libs
endif
if exist(gal_libs) then libs=[libs,gal_libs]
if exist(zastro_libs) then libs=[libs,zastro_libs]
if (1-keyword_set(nosdac)) and exist(sdac_libs) then libs=[libs,sdac_libs]
if exist(bypass_libs) then libs=[libs,bypass_libs]
if ucon then if exist(ucon_libs) then libs=[libs,ucon_libs]
;if exist(spart_libs) then libs=[libs,spart_libs]
if exist(fix_libs) then libs=[libs,fix_libs]
if exist(trace_cont) then libs=[libs,trace_cont]
if (1-keyword_set(nosite)) and (exist(site_libs)) then libs=[libs,site_libs]
ok=where(trim2(libs) ne '',count)
if count gt 0 then libs=libs[ok]

delim=get_path_delim()
new_path=arr2str(libs,delim=delim)

if n_params() eq 0 then !path=new_path

sav_path=new_path
return & end









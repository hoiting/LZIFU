function path_data, module, count, nopath=nopath, bydir=bydir, $
				 multi=multi, exact=exact
;
;+
;   Name: path_data
;
;   Purpose: return the path to on-line reformatted data files 
;
;   Input Parmeters:
;      module 	- reformatted file name or pattern
;
;   Optional Keyword Parameters:
;      nopath - if set, only return the module names (no path info)
;      nopro  - if set, all file types in path matching module are returned
;      multi  - if set, all occurences are returned (default is first)
;      bydir  - if set, match is against pathname not module name
;
;   Output Parameters: function returns full path specification 
;      count - number of matches found
;	
;   Calling Sequence: 
;	refiles=path_data(module [,count , /nopath , /bydir 
;
;   Category:
;      system, swmaint, util, gen
;
;   Method - first call, reads generic file $DIR_GEN_SETUP/data/datamap.genx
;	     into a common block - once common is established, finding module
;	     is via. table lookup.  File is generated via mk_mapfile,/data.
;
;   History: slf, 8-Aug-92
;	     slf, 18-nov-92 - altered path_sw to path_data(force some keywords)
;			      (change common block name and map input file)
;	     slf, 22-sep-93 - read from site/setupd/datamap
;  
;   Restrictions: wild cards not yet handled properly
;-
common	path_data_blk, psw_paths, psw_modules, psw_map
;
nopro=1
; set up common on first call
if n_elements(psw_paths) eq 0  then begin	; 1st call, read generic file

   restgen,paths, modules, map, $		; 3 vectors in file
   file=concat_dir('$DIR_SITE_SETUPD','datamap')	; .genx
   psw_paths=paths				; assign common
   psw_modules=modules
   psw_map=map
endif

;
; Now do lookup
outarr=''
; make a couple of mods to the input argument
inmod=str_replace(module,'*','')		; in case wild card was passed
if keyword_set(exact) and $			; allow xxx.pro and xxx to 
   not keyword_set(nopro) then inmod= $		; both be exact matches
      str_replace(inmod,'.pro','') + '.pro'

inmod=strtrim(inmod,2)				; ignore blanks
;						; since we use substrings here
;						; (but we may eventually 
;						; want an exact match func)
;

if keyword_set(bydir) then begin		; addded afer the fact so
   dirmatch=strpos(psw_paths,inmod)		; this logic is sloppy
   success=where(dirmatch ne -1,count)
   smap=[0]					; initialize success vector
   for i=0,count-1 do $      
      smap=[smap,where(psw_map eq success(i))]
   if count gt 0 then begin
      success=smap(1:*)
      count=n_elements(success)
   endif
endif else begin   			; 'standard' logic (match modules)
   if keyword_set(exact) then $
      success=where(inmod eq psw_modules,count) $
   else success=where(strpos(psw_modules,inmod)ne -1,count)
endelse 

; filter out directories/scripts, etc unless otherwise requested
prosonly = not keyword_set(nopro)
if prosonly and count gt 0 then begin
   pros=where(strpos(psw_modules(success),'.pro') ne -1 ,count)
   if count gt 0 then success=success(pros)
endif   
   
;
; strip out duplicates unless specifically requested
if not keyword_set(multi) and count gt 0 then begin 
   outarr=psw_modules(success)				;subarray to uniqify
   success=success(uniq(outarr,sort(outarr)))		;update subscripts
   count=n_elements(success)				;update output count
endif
      

; success vector is fully established, now define the output format
if count gt 0 then begin				; I am asking this way
;					        	; way  too frequently
   outarr=psw_modules(success)				; module names
   if not keyword_set(nopath) then outarr= $		; default adds path
	concat_dir(psw_paths(psw_map(success)),outarr )   
endif

return,outarr
end

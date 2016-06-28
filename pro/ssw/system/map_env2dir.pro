pro map_env2dir, envs, dirs, filter=filter, $
	envfile=envfile, mapfile=mapfile, append=append
;+
;   Name: map_env2dir
;
;   Purpose: make file which maps between environmentals and local pathnames
;
;   Input Parameters:
;      NONE:
; 
;   Keyword Parameters:
;      filter  (in/out) - environmental filter to use (ex: 'SSW*')
;      envfile (in)     - name of environmental file 
;                         Enivironmental files may be in one of two forms:
;                         1) - simple list of environmentals 
;			       # commments ok
;                              DIR_GEN_SHOWPIX
;			       DIR_GEN_G71		# partial comments ok
;			      
;			  2) - #!/bin/csh -f 
;			       # script file (setenv or define)
;                              setenv DIR_GEN_SHOWPIX	/ydb/showpix
;			       setenv DIR_GEN_G71 	/yd2/g71	# partial comments ok
;
;      mapfile (out)   - optional output file name
;                        mapfile format (read with rd_tfile(mapfile,2,/nocomment)
;			 # [header section /system info]
;			 # ....
;			 Env1	Path1
;			 Env2   Path2
;                        EnvN	PathN
;
;   Calling Sequence:
;      map_env2dir, envs, dirs, filter='envfilter'
;      map_env2dir, outarr, envfile=envfile
;
;   USE:
;      On SW master     - map envs to master directory - (map files are distributed)
;      On local machine - map local env list to local pathnames
;      Together - generate auto-distribution mappings - for example,
;                 generate MIRROR packages to run on local machine.
;  
;   History:
;      18-march-1996 (S.L.Freeland)
;-


if not keyword_set(envs) then envs=''
if not keyword_set(dirs) then dirs=''

case 1 of
   keyword_set(filter) : dirs=get_logenv(filter,outenv=envs)
   keyword_set(envfile): begin
      if file_exist(envfile) then begin
         dat=rd_tfile(envfile)
         nocom=strnocomment(dat,/remove)
         dat2cols=strtrim(str2cols(nocom),2)
         case data_chk(dat2cols,/ndimen) of
            2: filter=reform(dat2cols(1,*))
            else: filter=reform(dat2cols(0,*))
         endcase
	 map_env2dir,envs,dirs,filter=filter,mapfile=mapfile	; ** recursive call **
         return
      endif else message,/info,"Cannot find environmental file: " + envfile
   endcase
endcase

; optionally write 'mapfile'
if data_chk(mapfile,/string) then begin
   comchar=(['#','!'])(strlowcase(!version.os) eq 'vms')+ ' ' 
   new=1-keyword_set(append)
   pr_status,header,caller='map_env2dir'	        ; get some system status info
   file_append,mapfile, comchar + header, new=new       ; write header
   dirs=str_replace(dirs,' ',',')			; comma delimit lists	
   file_append,mapfile,strjustify(envs) + ' ' + dirs	; write 2 column file
endif

return
end   

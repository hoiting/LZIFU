pro pathfix, filter, remove=remove, restore=restore, ucon=ucon, quiet=quiet
;+
;   Name: pathfix
;
;   Purpose: remove elements from !path or restore original !path
;   
;   History:
;      14-Apr-1994 (SLF) Written 
;       1-Feb-1995 (SLF) added quiet keyword and function
;      28-feb-1997 (SLF) pass QUIET through recursive call
;-
common pathfix_blk,path_orig

loud=1-keyword_set(quiet)

if n_elements(filter) gt 1 then for i=0,n_elements(filter)-1 do $ 
   pathfix,filter(i), quiet=quiet, remove=remove, restore=restore, ucon=ucon else begin
   if n_elements(path_orig) eq 0 then path_orig=!path	; save original
   if keyword_set(restore) then begin
      if loud then message,/info,'Restoring original !PATH'
      !path=path_orig 
   endif else begin
      delims=[[':','/'],[',','.']]
      whichdel=reform(delims(*,strlowcase(!version.os) eq 'vms'))
      p2arr=str2arr(!path,whichdel(0))
      case 1 of
         keyword_set(ucon): filt=arr2str(['ucon','soft'],whichdel(1))
         n_elements(filter) eq 1: filt=filter
         else: begin
            message,/info,'No filter or keyword, returning without change'
            return
         endcase
      endcase
      wherefilt=wc_where(p2arr,'*'+filt+'*',fcnt)
      if fcnt eq 0  then begin
         if loud then message,/info,'No path elements match requested filter: ' + arr2str(filt)
         if loud then message,/info,'!PATH not changed'
      endif else begin
         if loud then message,/info,'Removing ' + strtrim(fcnt,2) + ' elements from !PATH'
         !path=arr2str(p2arr(rem_elem(p2arr,p2arr(wherefilt))),whichdel(0))
      endelse
   endelse
endelse

return
end

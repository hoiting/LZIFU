function buildgen,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, names=names 
;+
;   Name: buildgen 
; 
;   Purpose: build 'super structure' for generic files 
;
;   Input Parameters:
;      p1, p2, p3... p10 - variables to save
;
;   Optional Keyword Parameters
;      names - user supplied variable names - strarry(n_params())
;   History: slf, 10/30/91
;	8-Nov-91 MDM expanded from 10 to 15 parameters
;	10-Feb-94 (SLF) - allow anonymous structures via call struct2ms
;
n2save=n_params()			; number user variables
if not keyword_set(names) then $
   names=strcompress('savegen' + sindgen(n2save),/remove_all)

;
; first, build structure to hold the input parameters
structure='{dummy'				; start super structure string
;
; loop for each tag (input parameter)
param=0
;
testpar=strcompress('p' + string(param),/remove_all)
exestr='exist=n_elements(' + testpar + ') ne 0'
status=execute(exestr)
;
while exist do begin			; for each param 
   exestr= strcompress( ('data=p' + string(param)) ,/remove_all)
   status=execute(exestr)				
   structure=structure + ',' + names(param) + ':'  	; assign tag names
;
;  size of parameter (now data) determines tag format
   psize=size(data)
   if psize(n_elements(psize)-2) ne 8 then $     	;not structure
      structure=structure + fmt_tag(psize) else begin	;append tagsize
;
;        build string tag name for structures
         sname=tag_names(data,/structure)
         if sname eq '' then begin
            data=struct2ms(data)
            sname=tag_names(data,/structure)
         endif
         structure=structure + 'replicate({'   +     $  ;structure, so
            sname + '},'  +     $	;append {name}
	    string(psize(n_elements(psize)-1)) + ')'    ;(w/repicate)
      endelse;
   param=param+1					; next tag
;
   testpar=strcompress('p' + string(param),/remove_all)
   exestr='exist=n_elements(' + testpar + ') ne 0'
   status=execute(exestr)
;
endwhile					; all tags(param) done
;
structure=structure + '}'			; close structure
;
;
super=make_str(structure)
;
; now, copy parameter contents->structure 
for i=0,param-1 do begin
   exestr= strcompress( ('data=p' + string(i)) ,/remove_all)
   status=execute(exestr)
   if data_chk(data,/struct) then $
      if tag_names(data,/struct) eq '' then data=struct2ms(data)
   super.(i)=data

endfor
;
return, super
end

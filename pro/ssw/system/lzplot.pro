;+
; NAME:
;        LZPLOT
; PURPOSE:
;        print a PostScript plot file
; CALLING SEQUENCE:
;        LZPLOT [,VERSION][DELETE=DELETE][,FILENAME=FILENAME]
;               [,queue=queue][,color=color]
; OPTIONAL INPUT PARAMETERS:
;        FILE -    Other than the default, IDL.PS
;        VERSION - An integer version number will cause the plotting of that
;        particular IDL.PS file.
; KEYWORD PARAMETERS:
;        DELETE   - delete the plot file after printing
;        QUEUE    - printer queue name
;        COLOR    - send to color printer
; PROCEDURE:
;	 Use GET_HOST to determine local node name
;        and then call the appropriate hard copy plotting routine
; HISTORY:
;        DMZ (ARC) Mar'93
;-

PRO LZPLOT,file,version,delete=delete,queue=queue,color=color,$
           eaf=eaf

on_error,1

;-- can .ps file be opened on this directory?

ok=test_open(/write)
if not ok then cd,getenv('HOME'),curr=curr

;-- device dependent stuff

iam=strupcase(get_host())
isas=(strpos(iam,'ISAS') gt -1)
gsfc=(strpos(iam,'GSFC') gt -1) or (strpos(iam,'NASCOM') gt -1) 
eaf=keyword_set(eaf)

if datatype(file) ne 'STR' then file='idl.ps'

if isas then pprint,file,delete=delete,dev_que=queue,color=color else begin
 if not gsfc then queue=''
 if eaf then begin queue='eaf-laser1' & qual='h' & endif
 psplot,version,delete=delete,filename=file, queue=queue,color=color,qual=qual
endelse

if not ok then cd,curr
return & end

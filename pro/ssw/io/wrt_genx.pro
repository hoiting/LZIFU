pro wrt_genx,filename,data, $
               xdr=xdr,success=success,text=text,replace=replace,header=header
;
;+
; NAME:
; 	WRT_GENX
;
; PURPOSE:
;	Write SXT generic file - XDR format - see savegen.pro front end
;
; CALLING SEQUENCE:
;	WRT_GEN, filename, data [,TEXT=TEXT, SUCCESS, /REPLACE] 
;
; INPUTS:
;	DATA - data to save (simple structure, n-dimen array, or scaler)
;	FILENAME - string containing generic file name
;
; OPTIONAL KEYWORD PARAMETERS:
; 	TEXT -    (Input) Generic file text description
;	REPLACE - (Input) If set , forces overwriting of existing file
;	XDR     - (Input) If set, file is XDR format
;	HEADER -  (Output) Returns ystem imposed header (version/creattion date)
;	SUCCESS - (Output) Returns success code
;
; FILE I/O:
;  	If succesful, named file is created or updated (overwritten) 
;
; COMMON BLOCKS;
;	NONE
;
; RESTRICTIONS:
;	Version 00 does not support nested structures for DATA
;
; MODIFICATION HISTORY:
;	Version 0 - SLF, 3/5/91
;	Version 1 - SLF, 10/29/91	; handle nested structures and
;					; XDR (simplifies string saves)
;		    slf, 21-dec-93	; force text to be scaler if array
;       Version 2 - slf, 28-jan-93	; call genx_head for header struct.
;					; include idl !version in genx head
;                   slf, 19-mar-93	; dont clobber input text
;                   rdb, 25-Apr-95      ; explicit write of !version fields (v4 compatibility)
;-
;
head_version=2				; slf, 28-jan

xdrs=['',',/xdr']			; options for open

xtype=keyword_set(xdr)			; 0=norm, 1=xdr
;
success=0			 	; assume the worst	
; on_error,2				; return to caller on error
;
; assign data to header structure
header=genx_head(head_version)		; slf, 28-jan
header.creation = systime() 		; file creation date
header.xdr=xtype			; xdr status
;
; version dependent assignments		; slf, 28-jan 


case 1 of 
   head_version ge 2: begin
;    !version changed to 4 fields on IDL v4, store only 3 for compatibilty
;    with older versions of IDL. IDL_VERSION structure defined in genx_head
     header.idl_version.arch    = !version.arch
     header.idl_version.os      = !version.os
     header.idl_version.release = !version.release
   endcase
   else:
endcase

;
;
if n_elements(text) eq 0 then text=''
textout=text
textout=arr2str(textout,'\\')			; slf, force to be scaler
;
file_check = findfile(filename,count=count) 
;
if (count eq 0 or keyword_set(replace)) then begin 	;ok to write 
   openw,unit,filename,/get_lun,xdr=xtype
   writeu,unit,header,textout		; write header / optional text
   wrt_str, data, unit			; wrt_str writes size info 
   writeu,unit,data			; write the data
   free_lun,unit
endif
;
;
return
end

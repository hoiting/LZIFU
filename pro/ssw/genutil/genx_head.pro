function genx_head, version
;
;+
;   Name: genx_head
;
;   Purpose: define version dependent genx file header structures
;
;   Input Parameters:
;      version - genx file version number
;
;   Output:
;      function returns version dependent gen-file header structure
;
; History:
;     ?? written
;	RDB  21-Apr-95  modified version=2 so specific to IDLV3 !version
;-
; define version dependent structure string
maxver=2
;
; check for non-existant or bad version number
if n_elements(version) eq 0 then version=1	; default
if (version gt maxver) or (version lt 0) then begin
   message,/info,'Bad version number, using returning version 1 header'
   version =1
endif

; define the version dependent header structure
case version of

   0: begin  
	head=					  $
	'version:0L,'				+ $
	'xdr:0L,'				+ $ 
	'creation:string(replicate(32b,24))'	
      endcase

   1: begin  
	head=					  $
	'version:0L,'				+ $
	'xdr:1L,'				+ $ ; force xdr
	'creation:string(replicate(32b,24))'	
      endcase

;           form of !version changes on version 4 of IDL ("os_family" added)
;           so explicit filling of fields necessary to keep files readable
;;        'idl_version:{idlv4_version,arch:"",os:"",os_family:"",release:""}'    ;idlv4 version
   2: begin  
	head=					  $
	'version:0L,'				+ $
	'xdr:1L,'				+ $ ; force xdr
	'creation:string(replicate(32b,24)),'	+ $
        'idl_version:{idlv3_version,arch:"",os:"",release:""}'    ; added idlv3 version
      endcase
      
endcase
;
; now create the header structure via make_str
head = '{dummy,' + head + '}'
header=make_str(head)   
header.version=version

return,header
end

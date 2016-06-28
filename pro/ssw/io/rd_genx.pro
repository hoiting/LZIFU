pro rd_genx,filename,data,header=header,text=text, $
	structure=structure, nodata=nodata, inquire=inquire, $
        fast=fast
;+
; NAME:
; 	RD_GENX
;
; PURPOSE:
;	Read SXT generic file and return contents in appropriate data
;	structure.  - XDR Format  - see restgen.pro front end routine
;
; CALLING SEQUENCE:
;	RD_GEN, filename, data [,TEXT=TEXT, HEADER=HEADER]
;
; INPUTS:
;	FILENAME - string containing generic file name
;
; OUTPUTS:
;	DATA - structure containing contents of file
;	       (one tag field per stored data structure)
;
; OPTIONAL KEYWORD PARAMETERS:
; 	TEXT - Generic file text description
;	HEADER - System imposed header (version/creattion date)
;       nodata - dont read data from file (return header,text,empty struct)
;
; COMMON BLOCKS;
;	NONE
;
; MODIFICATION HISTORY:
;	Version 1 - S.L.Freeland 
;		    slf, 21-dec-93	; return text as array if delimited
;					  by wrt_genx delimitor= '\\'
;       	    slf, 28-jan-93	; call genx_head.pro to return
;					; genx version dependent header
;					; added nodata switch 
;		    slf, 24-mar-93      ; made nodata and struct do same
;					; some documentation upgrades
;					; add inquire keyword
;      9-Sep-1998 - S.L.Freeland - add /FAST keyword (only returns first param)
;                   
; ---------- determine if it is an xdr file by reading xdr parameter ------
version=0L				; first two longwords are
xdr=0L             			; version and xdr flag
on_ioerror, ioerr
openr,unit,/get_lun,filename,/xdr	; ** needs check for file exist
readu, unit, version, xdr
point_lun, unit, 0			; rewind for later
if xdr ne 1 then begin			; not xdr, so reopen properly
   free_lun, unit
   openr,unit,/get_lun,filename	 	; needs check for file exist
endif
; 
; --------------- create file header structure and read it ----------
header=genx_head(version)		; slf, 28-jan-1992 - use genx_head
readu,unit,header
;
; --------------------  read optional text section ----------------------
text=''
readu,unit,text			
text=str2arr(text,'\\')				; in case text is array 
if n_elements(text) eq 1 then text=text(0)	; force scaler
;
; ----------------  define data structure (via build_str.pro) -------------
data=build_str(unit)			


; ----------------- read data (unless told otherwise) ---------------------
readdata=( 1-keyword_set(nodata) and 1-keyword_set(struct))

; now read from generic file -> data
if keyword_set(fast) then data=temporary(data.(0))

if readdata then readu,unit,data 	; otherwise, just return info stuff
;
;  -------- Print summary of file contents if inquire keyword set ------
if keyword_set(inquire) then begin		;display file info
   print
   print,'-- Contents Summary of Generic File: ' + filename + '--
   print
   print,'..... Header Section .....'
   help,header,/str      
   print
   print,'..... Text Section ......'  
   otext=text
   if text(0) eq '' then otext='----- No User Text -----'
   prstr,otext
   print
   print,'.....  Data Section .....'      
   help, data,/structure
   print,'-----------------------------------------------------------'
endif
;
free_lun,unit
return
ioerr:
message,/info,'Error opening/reading file: ' + filename + ', returning...'
return
end

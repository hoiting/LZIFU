pro inq_gen,filename,lun
;
;+
; NAME:
; 	INQ_GEN
;
; PURPOSE:
;	Provide summary of SXT generic file	
;
; CALLING SEQUENCE:
;	INQ_GEN, filename [,file_lun]
;
; INPUTS:
;	FILENAME - string containing generic file name
;	LUN      - logical unit, terminal if not present	
;
; COMMON BLOCKS;
;	NONE
;
; RESTRICTIONS - prliminary - just does a RD_GEN and idl help of 
;	data structures, final version should not have to read data
;
; MODIFICATION HISTORY:
;	Version 0 - SLF, 3/5/91
;-
;
if n_params() eq 1 then lun= -1 		; default to terminal
;
rd_gen,filename,data,text=text,header=header
;
printf,lun,'
printf,lun,'------------------------------------------------------------------' 
printf,lun,'         Summary of File Contents for : ', filename
printf,lun,'------------------------------------------------------------------' 
printf,lun,'
printf,lun,'                   *Header Section*'
printf,lun,'
printf,lun,format='(5x,a,i2.2,5x,a,a)', 'Version: ', $
   header.version, 'Created: ', header.creation
printf,lun,'
if n_elements(text) eq 0 then text='NO ENTRY'
printf,lun,'             *Optional Text Section Contents*'
printf,lun,'
print_text,text,lun
printf,lun,'
printf,lun,'                   *Data Structures*'
printf,lun,'
help,data,/str
printf,lun,'
printf,lun,'------------------------------------------------------------------' 
printf,lun,'
return
end

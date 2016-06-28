; Test procedure for multi_save, multi_restore routines.
pro MULTI_TEST,xdr=xdr
header={Comments:'STRING',DATA:bytarr(10),Pointer:ptr_new()}
N=3
print,'SAVE***************************'
for i=1, N do begin
 RECORD={data1:dindgen(2)*i+1,data2:i}
 help,record
 print,record
 MULTI_SAVE,lun,record,file='test.sav', header=header,new=(i eq 1),close=(i eq N),xdr=xdr
end
print,'RESTORE***************************'
i=0
repeat begin
 i+=1
 rec=MULTI_RESTORE(lun,file='test.sav', header=header,new=(i eq 1),/verb)
 help,rec
 print,rec
 end_of_file=size(rec,/tname) eq 'POINTER'
endrep until end_of_file
close,lun
print,'HEADER***************************'
help,header,/str
end

;+
; NAME:
;       MULTI_SAVE
; PURPOSE:
;       This procedure saves any number of IDL same length records
;       in a binary file having a self describing XDR header.
;
; CATEGORY:
;       Data writers
;
; CALLING SEQUENCE:
;       TO OPEN/REPLACE A FILE AND WRITE AN OPTIONAL HEADER AND THE FIRST RECORD:
;
;       MULTI_SAVE,lun,record,file=file,/new [,header=header][,/close]
;
;       the above calling sequence returns the LUN parameter
;		associated with the new open file, which is ready for appending.
;
;       TO WRITE A NEW RECORD TO A FILE OPEN AS INDICATED ABOVE,
;       AND TO OPTIONALLY CLOSE THE FILE:
;
;		MULTI_SAVE,lun,record,[,/close]
;
; INPUTS:
;       LUN		A name variable to hold	the logical file unit
;		RECORD	The template (first record) or the record to be appended
; OUTPUTS:
; KEYWORD PARAMETERS:
;       NEW     Set this keyword to create a new file
;       FILE	The name of the file to be created/replaced.
;               Must be present when creating/replacing a new file.
;               If the FILE already exists, the file is QUITELY replaced.
;				The FILE argument is quitely ignored if NEW=0
;       HEADER  Set this keyword to a named structure to be written as a file header
;       		The HEADER argument is quitely ignored if NEW=0
;       CLOSE   Use this keyword to force closing the file after the record is written
;       XDR     Set this keyword to append the extra records in portable XDR format
;
; REFERENCE:
;
; RESTRICTIONS:
;       		First call this routine with NEW keyword set.
;       		The template record CANNOT contain POINTERS or STRINGS.
;               However, the optional HEADER argument has no data type restriction.
;
; DISCLAIMER:	This routine is provided as is without any express or implied warranties whatsoever.
;
; COMMENTS:
;           ALL RECORDS MUST HAVE THE SAME LENGTH
;           The user is responsible for checking if an already existing file would be replaced.
;			The user is responsible for closing the file after all records are written.
;			Use MULTI_RESTORE to read all records saved by this routine
;           You may simply use RESTORE if you only want to restore the self describing header record.
;
; MODIFICATION HISTORY:
;       Written by:  Gelu M. Nita (gnita@njit.edu), October 27, 2006.
;-

PRO MULTI_SAVE,lun,record,file=file,header=header,new=new,close=close,xdr=xdr

 CATCH, Error_status
   IF Error_status NE 0 THEN BEGIN
      case !ERROR_STATE.MSG of
      else:begin
            PRINT,!ERROR_STATE.MSG
            RETURN
           end
      endcase
   ENDIF

 ;THINGS TO BE DONE WHEN THE FILE IS CREATED/REPLACED

 if KEYWORD_SET(new) then begin
  if not ARG_PRESENT(lun) then message, 'A named variable shoud be provided for the logical file unit'
  if SIZE(file,/tname) ne 'STRING' then message,'A file name must be provided when writing the first record'
  if N_ELEMENTS(xdr) eq 0 then xdr=0
  key=0l;reserve space to hold the self discribing IDL save/restore section length
  template=record						;define the template
  hint=['Although this file appear to be a valid IDL save/restore file,',$
        'more TEMPLATE like records may have been recorded after the position indicated by the KEY.' ]
  if N_ELEMENTS(header) eq 0 $			;save empty key, template, and header if any
  then SAVE,template,key,xdr,hint,file=file $
  else SAVE,header,template,key,xdr,hint,file=file
  stat=FILE_INFO(file)
  key  = stat.size + 4		;read the actual IDL save/restore section length and define the key
  if n_elements(header) eq 0 $  		;save the actual key, template, and header if any
  then SAVE,template,key,xdr,hint,file=file $
  else SAVE,header,template,hint,key,xdr,file=file
  ;make the file ready for data to be appended if /CLOSE is not set
  if not KEYWORD_SET(close) then OPENW, lun,/GET_LUN, file,/append,xdr=xdr
  RETURN
 end

 ;THINGS TO BE DONE WHEN A NEW RECORD IS APPENDED

   WRITEU,lun,record
   if KEYWORD_SET(close) then FREE_LUN,lun; close the file if explicitely requested
   RETURN
 END
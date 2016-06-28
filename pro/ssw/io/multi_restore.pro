;+
; NAME:
;       MULTI_RESTORE
; PURPOSE:
;       To read the file multiple records created by MULTI_SAVE
;
; CATEGORY:
;       Data readers
;
; CALLING SEQUENCE:
;       TO READ AN OPTIONAL HEADER AND THE FIRST RECORD:
;
;       record=(MULTI_RESTORE,lun,file=file,/new [,header=header][,/close])
;
;       the above calling sequence returns the LUN parameter
;		associated with the new open file, which is ready for reading more records.
;
;       TO READ THE NEXT RECORD FROM A FILE OPEN AS INDICATED ABOVE,
;       AND TO OPTIONALLY CLOSE THE FILE:
;
;		record=MULTI_RESTORE(lun,[,/close])
;
; INPUTS:
;       LUN			A named variable to hold	the logical file unit
; OUTPUTS: RECORD the current record
; KEYWORD PARAMETERS:
;       NEW     Set this keyword to read the optional header and the first record
;       FILE	The name of the file to be open for reading.
;               Must be present when a new file is open for reading.
;				It is quitely ignored if NEW=0
;       HEADER  Set this keyword to retrieve the optional header, if any.
;       		It is quitely ignored if NEW=0
;       CLOSE   Use this keyword to force closing the file after the record is retrieved.
;
; REFERENCE:
;
; RESTRICTIONS:
;       		First call this routine with NEW keyword set.
;
; DISCLAIMER:	This routine is provided as is without any express or implied warranties whatsoever.
;
; COMMENTS:
;           The user is responsible for closing the file after the records are restore.
;           You may simply use RESTORE if you only want to restore the self describing header record.
;
; MODIFICATION HISTORY:
;       Written by:  Gelu M. Nita (gnita@njit.edu), October 27, 2006.
;-
function multi_restore,lun,file=file,new=new,header=header,verbose=verbose,close=close
 common multi_restore_block,template
 ON_ERROR=2
 CATCH, Error_status
   IF Error_status NE 0 THEN BEGIN
      case !ERROR_STATE.MSG of
      else:begin
            PRINT,!ERROR_STATE.MSG
            RETURN,ptr_new()
           end
      endcase
   ENDIF
 if keyword_set(new) then begin
  RESTORE,file,verbose=verbose
  if not KEYWORD_SET(close) then begin
   OPENR,lun,file,/get_lun,xdr=xdr
   POINT_lun,lun,key
  end
  RETURN,template
 end
 if EOF(lun) eq 1 then RETURN,ptr_new()
 READU,lun,template
 if KEYWORD_SET(close) then FREE_LUN,lun; close the file if explicitely requested
 RETURN,template
end
function tfile_control
var = {tfile_control}
var.path = ptr_new('')
return, var
end

pro tfile_control__define

d = {tfile_control, $
	filename: '', $
	ncols: 0, $
	skip: 0, $
	delim: '',$
	nocomment: '',$
	compress: 0,$
	quiet: 0,$
	autocol: 0,$
	convert: 0,$
	hskip: 0, $
	first_char_comm: 0, $
	path: ptr_new() $
	}

end

pro tfile_info__define

d = {tfile_info, $
	header: ptr_new(0) $
	 }

end
;+
;   Name: tfile__define
;
;   Purpose: read/return contents of text file - optionally interpret
;	     and convert text table data
;
;   Input Control Paramters:
;      filename - string variable containing file name to read
;      ncols - (optional) #colunms (output will be matrix, strarr(NCOLSxN)
;      skip  - (optional) #lines to skip (header) for readfile compatibile
;	                  (if skip=-1, first non-numeric lines are skipped)
;

;
;
;      delim     - table column delimiter (default is blank/tab)
;      nocomment - if=1 (switch) , remove lines with (unix:#, vms:!)
;		   if string (scaler), remove lines with specified character
;      compress  - eliminate leading/trailing blanks and excess whitespace
;		   (for table data (ncols gt 1), compress is assumed)
;      quiet     - if set, suppress warning messages
;      autocol   - if set, derive column count from first non-comment line
;      convert   - if set, convert to numeric data type
;      hskip	 - header skip (sets skip to -1)
;      first_char_comm - if set, only apply "nocomment" flag when the
;		   comment character is the first character
;
;   Output Parameters:
;      getdata returns file contents (string array(list) or matrix)
;		if convert is set, auto-convert to numeric data type
; 	Info Parameters
;      header    - output string(array) containing header lines
;
;   Calling Sequence:
;	   tfile = obj_new('tfile')
;	   tfile->set,filename=filename, /nocomment, /autocolumn, /convert
;      text=rd_tfile(filename)                  ; orig. file-> string array
;      text=rd_tfile(filename,/nocomment)       ; same less comment lines
;      text=rd_tfile(filename,/compress)        ; same less excess blanks
;      data=rd_tfile('text.dat',3)              ; strarr(3,N) (table data)
;      data=rd_tfile('fdata.dat',/auto,/convert); determine n columns and
;                                               ; data type automatically
;      data=rd_tfile(filename,/hskip,head=head) ; return file header in head
;
;
;   History:
;      slf,  4-Jan-1992 - for yohkoh configuration files
;      slf,  6-Jan-1992 - remove partial comment lines
;      slf, 11-feb-1993 - added autocol keyword and function
;			  added convert keyword and function
;      slf, 28-Oct-1993 - temp fix for VMS variable length files
;      slf, 26-jan-94 fixed bug if /auto and user supplied comment char
;      dmz, 3-Mar-94 - changed type to type/nopage (for vms), otherwise
;                      it is really slow
;      slf, 21-May-94 - fix bug in /convert auto skip function (allow '-' !!)
;      mdm, 15-Mar-95 - Modified to not crash on reading a null file.
;      mdm, 12-Oct-95 - Modification to allow tab character to be the delimiter.
;      slf, 27-mar-96 - Put MDM oct change online
;      ras, 19-jun-96 - Use rd_ascii in vms
;      slf, 29-may-97 - force FILENAME -> scalar
;      slf, 16-sep-97 - allow ascii files with NO carraige returns
;      slf,  6-oct-97 - include last line which has NO carraige return
;      mdm, 25-Nov-97 - Made FOR loop long integer
;      mdm,  7-Apr-98 - Print the filename when NULL
;      slf, 19-aug-98 - per MDM report, free lun on read error
;      mdm, 11-Feb-99 - Added /first_char_comm
;
;   Category:
;      gen, setup, swmaint, file i/o, util
;
;   Method:
;      files are assumed to be ascii - file contents read into a variable
;      if ncols is greater than 1, then a table is assumed and a string
;      matrix is returned - table is null filled for non existant table
;      entries (ncols gt 1 forces white space removal for proper alignment)
;
;-



;--------------------------------------------------------------------

FUNCTION tfile::INIT, $
	;SOURCE = source, $
	_EXTRA=_extra




RET=self->Framework::INIT( CONTROL = tfile_control(), $
                           INFO={tfile_info}, $
                           ;SOURCE=source, $
                           _EXTRA=_extra )

RETURN, RET

END
;--------------------------------------------------------------------
function tfile::file_search, _extra=_extra

If keyword_set(_extra) then Self->Set, _extra=_extra
file = obj_new('file')
file->Set, path = self->Get(/path)
file->Set, file_mask=Self->Get(/filename)
filename = file->file_search()
obj_destroy, file
return, filename
end


;--------------------------------------------------------------------
PRO tfile::Process, $

	_EXTRA=_extra

c = self->Get(/control)

nocomment = strtrim(strcompress(c.nocomment),2)
if nocomment eq '0' or nocomment eq '1' then nocomment = fix(nocomment)


filename = Self->file_search(path=[c.path, curdir()], filename=filename  )
data = rd_tfile( filename, c.ncols, c.skip, hskip=c.hskip,$
		 delim=c.delim, nocomment=nocomment, compress=c.compress, 	$
		 quiet=c.quiet, autocol=c.autocol, convert=c.convert, header=header, $
		 first_char_comm=c.first_char_comm)
Self->Set,header=header




self->SetData, data


END
;--------------------------------------------------------------------


FUNCTION tfile::GetData, $

	                  _EXTRA=_extra

data=self->Framework::GetData( _EXTRA = _extra )



RETURN, data
;
END

;--------------------------------------------------------------------



;PRO tfile::Set, $
;       PARAMETER=parameter, $
;       _EXTRA=_extra
;
;
;
;IF Keyword_Set( PARAMETER ) THEN BEGIN
;
;    ; first set the parameter using the original Set
;    self->Framework::Set, PARAMETER = parameter
;
;    ; then take some action that depends on this parameter
;    Take_Some_Action, parameter
;
;ENDIF
;
;
;IF Keyword_Set( _EXTRA ) THEN BEGIN
;    self->Framework::Set, _EXTRA = _extra
;ENDIF
;
;END

;---------------------------------------------------------------------------

;(*
; This shows how to configure the Get function.
; The Get function needs to be modified only in very special cases,
; e.g. if you need to modify a value before passing in back to the
; user.  This is not recommended, however. In any case, you should add two
; keyword variables NOT_FOUND and FOUND that must be passed to the Get
; function in Framework. It is important that self->Framework::Get(...
; ) is called (see end of the routine) such that it can search for
; further parameters in other classes.
; *)

;FUNCTION tfile::Get, $
;                  NOT_FOUND=NOT_found, $
;                  FOUND=found, $
;                  PARAMETER=parameter, $
;                  _EXTRA=_extra
;
;;; not_found and found are needed by Framework::Get() to pass parameters
;;; back
;;
;;;(*
;;; you should change PARAMETER to whatever your paraneter name is
;;; *)
;;
;;IF Keyword_Set( PARAMETER ) THEN BEGIN
;;    parameter_local=self->Framework::Get( /PARAMETER )
;;    ; (*
;;    ; here do whatever needs to be done with parameter as a control
;;    ; *)
;;    Do_Something_With_Parameter, parameter_local
;;ENDIF
;;
;;; here pass the control back to the original Get function. Dont forget
;;; to have NOT_FOUND and FOUND passed to the Get function
;RETURN, self->Framework::Get( PARAMETER = parameter, $
;                              NOT_FOUND=not_found, $
;                              FOUND=found, _EXTRA=_extra )
;END

;---------------------------------------------------------------------------

PRO tfile__Define

self = {tfile, $

        INHERITS Framework }

END


;---------------------------------------------------------------------------
; End of 'tfile__define.pro'.
;---------------------------------------------------------------------------

;+
; Project      : HESSI
;
; Name         : del_blank_lines
;
; Purpose      : Read in a file, delete the blanklines, and write to an output file.
;
; Explanation  : This is a sub-routine for xdiff.pro. When comparing two files
;                sometimes you want to ignore blanklines.
;
; Use          : del_blank_lines,'<infile>', '<outfile>', '<error>'
;
; Inputs       : '<infile>'  : the name of the input file
;              : '<outfile>' : the name of the output file
;              : '<error>'   : error flag
;
; Opt. Inputs  : None
;
; Outputs      : None.
;
; Opt. Outputs : None.
;
; Keywords     : None.
;
; Calls        : BREAK_FILE, OS_FAMILY(), RD_ASCII()
;
; Common       : None.
;
; Restrictions : None.
;
; Side effects : Creates temporary files.
;
; Category     : Utility
;
; Written      : Xiaolin Li, 30 August 2002
;
; Version      : 1, 30 August 2002
;-

pro del_blank_lines, infile, outfile,  err

    err=0

	rdfile=rd_ascii(infile)

  	OPENW, unit, outfile, ERROR=err1, /get_lun
  	IF (err1 NE 0) THEN BEGIN
  		PRINT, !ERROR_STATE.MSG
  	  	err=1
  	  	RETURN
  	ENDIF

    wh_rand1= where(((rdfile) NE ''),count1)

  	IF count1 NE 0 THEN n_f=(rdfile)[where((strcompress(rdfile, /remove_all) NE ''))] ELSE n_f=(rdfile)

    FOR c1 = 0, n_elements(n_f)-1 DO  printf, unit, n_f[c1]

	free_lun, unit

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'del_blank_lines.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

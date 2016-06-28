;+
; Project      : HESSI
;
; Name         : del_comment_lines
;
; Purpose      : Read in a file, delete the lines that begin with a semicolon, and write to an output file.
;
; Explanation  : This is a sub-routine for xdiff.pro. When comparing two files
;               sometimes you want to ignore comment lines.
;
; Use          : del_comment_lines,'<infile>', '<outfile>',  '<error>'
;
; Inputs       : '<infile>'  : the name of the input file
;              : '<outfile>' : the name of the output file
;              : '<error>'      : error flag
;
; Opt. Inputs  : None
;
; Outputs      : None.
;
; Opt. Outputs : None.
;
; Keyword      : None.
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

pro del_comment_lines, infile, outfile,  err

	err=0

	rdfile=rd_ascii(infile)

  	OPENW, unit, outfile, ERROR=err1, /get_lun
  	IF (err1 NE 0) THEN BEGIN
  		PRINT, !ERROR_STATE.MSG
  	  	err=1
  	  	RETURN
  	ENDIF

	wh_rand1=where(strpos(strmid(strcompress(rdfile, /remove_all),0,1),';'), count1)

  	IF  count1 NE 0 THEN n_f=(rdfile)[where(strpos(strmid(strcompress(rdfile, /remove_all),0,1),';'), count1)] ELSE $
  		n_f=(rdfile)

    FOR c1 = 0, n_elements(n_f)-1 DO  printf, unit, n_f[c1]

    free_lun, unit

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'del_comment_lines.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

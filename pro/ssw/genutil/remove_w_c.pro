;+
; Project      : HESSI
;
; Name         : remove_w_c.pro
;
; Purpose      : Read in a file, change all characters to lower case, delete whitespaces, and write to an output file.
;
; Explanation  : This is a sub-routine for xdiff.pro. When comparing two files
;                sometimes you want to ignore whitespaces and case differences.
;
; Use          : del_blank_lines,'<infile>',  '<outfile>',  '<error>'
;
; Inputs       : '<infile>'     : the name of the input file
;              : '<outfile>' : the name of the output file
;              : '<error>'      : error flag
;
; Opt. Inputs  : None.
;
; Outputs      : None.
;
; Opt. Outputs : None.
;
; Keywords     : w : delete whitespaces
;              : c : change all characters to lower case
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

PRO remove_w_c, infile, outfile, c=c, w=w, err

	default,c,0
	default,w,0

	err=0

	rdfile=rd_ascii(infile)

	OPENW, unit, outfile, ERROR=err1, /get_lun
  	IF (err1 NE 0) THEN BEGIN
  		PRINT, !ERROR_STATE.MSG
        err=1
  	  	RETURN
  	ENDIF

	IF (KEYWORD_SET(w)) AND (KEYWORD_SET(c)) THEN BEGIN
		n_f=strlowcase(strcompress(rdfile, /remove_all))
	ENDIF ELSE IF KEYWORD_SET(c) THEN BEGIN
		n_f=strlowcase(rdfile)
	ENDIF ELSE IF KEYWORD_SET(w) THEN BEGIN
		n_f=strcompress(rdfile, /remove_all)
	ENDIF

  	FOR c1 = 0, n_elements(n_f)-1 DO  printf, unit, n_f[c1]

    free_lun, unit

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'remove_w_c.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

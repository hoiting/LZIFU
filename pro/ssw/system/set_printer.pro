pro set_printer, dummy, qdebug=qdebug, qstop=qstop
;
;+
;NAME:
;	set_printer
;PURPOSE:
;	To allow the user to set the printer queue where the output will 
;	come out
;HISTORY:
;	Written 25-Apr-94 by M.Morrison
;	27-Apr-94 (MDM) - Various changes
;	20-Jan-95 (MDM) - Changed "lp -dlaser" to "lp -c -dlaser"
;	28-Feb-95 (MDM) - Added option to send to QUAKE qms printer remotely
;	30-Nov-95 (MDM) - Changed "To redirect to LPARL lps20 from outside LPARL"
;			  option to point to umbra and que saglps20ps
;	30-Apr-96 (MDM) - Added option to print to SAG
;	27-Jan-97 (MDM) - Added option to print to DIAPASON
;	------------ Big variation ----------------
;	15-Apr-97 (MDM) - Modified to work with SPRINT instead of PPRINT
;			- Also modified to use a /ssw/site/setup/set_printer.tab
;			  file to define the options
;-
;
code = strarr(19)
code(0) = ' '
code(1) = 'RESET all printer definitions'
code(2) = ' '
code(3) = 'Redefine $SSW_QUE_PS        - the queue to print PostScript file
code(4) = 'Redefine $SSW_QUE_PS_COLOR  - the queue to print color PostScript
code(5) = 'Redefine $SSW_QUE_ASCII     - the queue to print ASCII
code(6) = 'Redefine $SSW_PR_PS         - the command to print PostScript file
code(7) = 'Redefine $SSW_PR_PS_COLOR   - the command to print color PostScript
code(8) = 'Redefine $SSW_PR_ASCII      - the command to print ASCII in portrait
code(9) = 'Redefine $SSW_PR_ASCII_LAND - the command to print ASCII landscape
code(10)= 'Redefine $SSW_FMT_ASCII     - the pre-formatting for ASCII in portrait
code(11)= 'Redefine $SSW_FMT_ASCII_LAND- the pre-formatting for ASCII landscape
code(12)= 'Redefine $SSW_PR_NODE       - the output node to print to
code(13)= ' '
code(14)= 'To use LPTOPS to default queue'
code(15)= ' '
code(16)= 'Copy SSW_QUE_PS to SSW_QUE_ASCII
code(17)= 'Copy SSW_PR_PS  to SSW_PR_ASCII and SSW_PR_ASCII_LAND
code(18)= ' '
;
n1 = n_elements(code)
infil = '$SSW/site/setup/set_printer.tab'
if (file_exist(infil)) then begin
    mat = rd_tfile(infil, nocomment='#')
    mat = strtrim(str2cols(mat, ncol=3), 2)
    nmat = n_elements(mat(0,*))
    ss_strip = where(mat(0,*) ne '', nss_strip)
    code = [code, reform(mat(0,ss_strip))]
end
;
qdone = 0
while (not qdone) do begin
    print, '------ Currently selected options --------------
    print, '$SSW_QUE_PS ========= ', getenv('SSW_QUE_PS')
    print, '$SSW_QUE_PS_COLOR === ', getenv('SSW_QUE_PS_COLOR')
    print, '$SSW_QUE_ASCII ====== ', getenv('SSW_QUE_ASCII')
    print, '$SSW_PR_PS ========== ', getenv('SSW_PR_PS')
    print, '$SSW_PR_PS_COLOR ==== ', getenv('SSW_PR_PS_COLOR')
    print, '$SSW_PR_ASCII ======= ', getenv('SSW_PR_ASCII')
    print, '$SSW_PR_ASCII_LAND == ', getenv('SSW_PR_ASCII_LAND')
    print, '$SSW_FMT_ASCII ====== ', getenv('SSW_FMT_ASCII')
    print, '$SSW_FMT_ASCII_LAND = ', getenv('SSW_FMT_ASCII_LAND')
    print, '$SSW_PR_NODE ======== ', getenv('SSW_PR_NODE')
    ;
    icode = wmenu_sel(code, /one)
    if (icode lt n1) then begin
      case icode of
	-1: qdone = 1
	0: qdone = 1
	1: begin			;reset all env vars
		setenv, 'SSW_QUE_PS='
		setenv, 'SSW_QUE_PS_COLOR='
		setenv, 'SSW_QUE_ASCII='
		setenv, 'SSW_PR_PS='
		setenv, 'SSW_PR_PS_COLOR='
		setenv, 'SSW_PR_ASCII='
		setenv, 'SSW_PR_ASCII_LAND='
		setenv, 'SSW_FMT_ASCII='
		setenv, 'SSW_FMT_ASCII_LAND='
		setenv, 'SSW_PR_NODE='
	   end

	3: begin ;SSW_QUE_PS
		print, 'Samples:
		print, '   lps20'
		print, '   qms'
		print, '   lp4'
	   end
	4: begin ;SSW_QUE_PS_COLOR
		print, 'Samples:
		print, '   kodak'
		print, '   lp4'
	   end
	5: begin ;SSW_QUE_ASCII
		print, 'Samples:
		print, '   lps20'
		print, '   qms'
		print, '   lp4'
	   end
	6: begin ;SSW_PR_PS
		print, 'Samples:
		print, '   lpr -P QUEUE_NAME FILENAME
		print, '   lp -c -dQUEUE_NAME FILENAME
	   end
	7: begin ;SSW_PR_PS_COLOR
		print, 'Samples:
		print, '   lpr -P QUEUE_NAME FILENAME
		print, '   lp -c -dQUEUE_NAME FILENAME
	   end
	8: begin ;SSW_PR_ASCII
		print, 'Samples:
		print, '   lpr -P QUEUE_NAME FILENAME
		print, '   lp -c -dQUEUE_NAME FILENAME
		print, '   lpr -P ascii_b252 FILENAME
	   end
	9: begin ;SSW_PR_ASCII_LAND
		print, 'Samples:
		print, '   lpr -P QUEUE_NAME FILENAME
		print, '   lp -c -dQUEUE_NAME FILENAME
		print, '   lpr -P ascii_b252 FILENAME
	   end
	10: begin ;SSW_FMT_ASCII
		print, 'Samples:
		print, '   /usr/lib/print/lptops -G -V -U -FCourier -P10pt FILENAME
	   end
	11: begin ;SSW_FMT_ASCII_LAND
		print, 'Samples:
		print, '   /usr/lib/print/lptops -G -H -U -FCourier -P8pt  FILENAME
	   end
	12: begin ;SSW_PR_NODE
		print, 'Samples:
		print, '  sag
		print, '  diapason.space.lockheed.com
	   end

	14: begin ;lptops 
		setenv, 'SSW_FMT_ASCII=/usr/lib/print/lptops -G -V -U -FCourier -P10pt FILENAME'
		setenv, 'SSW_FMT_ASCII_LAND=/usr/lib/print/lptops -G -H -U -FCourier -P8pt  FILENAME'
	   end

	16: begin ;CPQ2AQ
		setenv,'SSW_QUE_ASCII=' + getenv('SSW_QUE_PS')
	    end
	17: begin ;CPP2AP
		setenv,'SSW_PR_ASCII=' + getenv('SSW_PR_PS')
		setenv,'SSW_PR_ASCII_LAND=' + getenv('SSW_PR_PS')
	    end

	else:
      endcase
    end else begin	;it's site specific
	ii = icode-n1
	ist = ss_strip(ii)
	if (ii eq nss_strip-1) then ien=nmat-1 else ien=ss_strip(ii+1)-1
	for i=ist,ien do begin
	    cmd = mat(1,i)
	    opt = mat(2,i)
	    if (keyword_set(qdebug)) then print, 'CMD: ' + cmd
	    if (keyword_set(qdebug)) then print, 'OPT: ' + opt
	    stat = execute(cmd)
	    case opt of
		'CPQ2AQ': begin
				setenv,'SSW_QUE_ASCII=' + getenv('SSW_QUE_PS')
			  end
		'CPP2AP': begin
				setenv,'SSW_PR_ASCII=' + getenv('SSW_PR_PS')
				setenv,'SSW_PR_ASCII_LAND=' + getenv('SSW_PR_PS')
			  end
		else:
	    endcase
	end
    end

    if (icode ge 3) and (icode le 12) then begin
	lin = code(icode)
	p1 = strpos(lin, '$')+1
	p2 = strpos(lin, '-')
	envvar = strtrim(strmid( lin, p1, p2-p1), 2)
	input, 'Enter the new value for ' + envvar, item, getenv(envvar)
	setenv, envvar + '=' + item
    end

    if (keyword_set(qstop)) then stop
end
;
end

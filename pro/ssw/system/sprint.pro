pro sprint, file, queue=queue,  cmd=cmd_in, node=node, $
	ps=ps, ascii=ascii, land=land, color=color, $
	delete=delete, qdebug=qdebug, nospawn=nospawn, noprint=noprint
;+
; PROJECT:	SSW - GEN
;
; NAME:		sprint
;
; PURPOSE:	To spawn a print command
;
; CATEGORY:	PRINTER
;
; EXPLANATION:	The routine looks at the environment variables and the
;		switches set to figure out the print command.  The
;		environment variables checked are:
;                  o $SSW_QUE_PS        - the queue to print PostScript file
;                  o $SSW_QUE_ASCII     - the queue to print ASCII
;                  o $SSW_QUE_PS_COLOR  - the queue to print color PostScript
;                  o $SSW_PR_PS         - the command to print PostScript file
;                  o $SSW_PR_PS_COLOR   - the command to print color PostScript
;                  o $SSW_PR_ASCII      - the command to print ASCII in portrait
;                  o $SSW_PR_ASCII_LAND - the command to print ASCII landscape
;                  o $SSW_FMT_ASCII     - the pre-formatting for ASCII in portrait
;                  o $SSW_FMT_ASCII_LAND- the pre-formatting for ASCII landscape
;		   o $SSW_PR_NODE	- the output node to print to
;
;		The PR* commands can have the string FILENAME where the names
;		of the files need to be inserted, and QUEUE_NAME where the
;		name of the queue needs to be inserted.
;
;		The order for the logic for generating the print command is:
;			1) The print command is passed in (cmd=cmd)
;			2) The queue name is passed in (queue=queue)
;			3) Use the SSW_PR* command env variables
;			4) Use the SSW_QUE* command env vars.  These are ignored
;			   if the SSW_PR* command env var is defined, unless it
;			   is defined using QUEUE_NAME place holder.
;			5) Assume some defaults based on the operating system
;			6) Use the SSW_FMT* on ASCII to pre-process the file
;			   and to pipe it into the print command
;			7) Check if the SSW_PR_NODE option is used and
;			   format the command accordingly
;
;		Defaults:
;			o Assumes it should go to the PostScript queue
;			o For ASCII data, it assumes portrait
;
;		Samples:
;		    setenv SSW_QUE_PS	     lps20
;		    setenv SSW_QUE_PS_COLOR  kodak
;		    setenv SSW_QUE_ASCII     lps20
;		    setenv SSW_PR_PS	     "lpr -P QUEUE_NAME FILENAME"
;		    setenv SSW_PR_ASCII	     "lpr -P QUEUE_NAME FILENAME"
;		    setenv SSW_PR_ASCII_LAND "lpr -P QUEUE_NAME FILENAME"
;		    setenv SSW_FMT_ASCII     "/usr/lib/print/lptops -G -V -U -FCourier -P10pt FILENAME"
;		    setenv SSW_FMT_ASCII_LAND "/usr/lib/print/lptops -G -H -U -FCourier -P8pt  FILENAME"
;
;		    setenv SSW_PR_NODE       "diapason"
;		    setenv SSW_PR_ASCII	     "/pslaser FILENAME type10 lm=1"
;		    setenv SSW_PR_PS	     "cat FILENAME | rsh sxt3 lpr"
;
;		NOTE: If you specify QUEUE_NAME in the command then the queue
;		      MUST be define (by QUE* env var or passed in)
;
; SYNTAX:	sprint, 'idl.ps'
;
; INPUTS:	file	- The name of the file to be printed.
;		cmd	- [KEYWORD] The print command to use
;		queue	- [KEYWORD] The queue name to print to
;		ps	- [KEYWORD] If set, use the PS command or queue
;		ascii	- [KEYWORD] If set, use the ASCII command or queue
;		land	- [KEYWORD] If set, use the ASCII_LAND command
;		color	- [KEYWORD] If set, use the PS_COLOR command or queue
;		delete	- [KEYWORD] If set, then delete the file afterwards
;		nospawn	- [KEYWORD] If set, then simply display the print
;			  command, but do not spawn the command
;		noprint	- [KEYWORD] same as /NOSPAWN
;		node	- [KEYWORD] If set, then format the statement to
;			  do a "cat FILENAME | rsh node " and then the
;			  print statement.  BE AWARE: The print command
;			  must allow inputs to be piped into it.
;
; HISTORY:	Ver 1.00	27-Jun-95	M.Morrison	Written
;		Ver 1.01	28-Jun-95	M.Morrison
;				- Added /NOPRINT option
;		Ver 1.02	29-Jun-95	M.Morrison
;				- Renamed all env vars to have SSW_ preceding
;		Ver 1.03	14-Apr-97	M.Morrison
;				- Modified header slightly
;				- Added "IS_PS" call
;				- Removed MESSAGE calls, added PRINT
;		Ver 1.04	14-Apr-97 	M.Morrison
;				- Added SSW_FMT_ASCII* capability
;-
;
if (n_elements(file) eq 0) then begin
    print, 'SPRINT: File name is required as first parameter'
    return
end
;
qexist = file_exist(file)
if (min(qexist) eq 0) then begin
    print, 'SPRINT: One or more of the following files does not exist'
    print, '        Correct and re-submit the print command
    prstr, /nomore, '             ' + file
    return
end
;
;---- Setup flags to say what is to be done and the defaults
;
qdebug=keyword_set(qdebug) or keyword_set(nospawn)
qnospawn = keyword_set(nospawn) or keyword_set(noprint)
qps = is_ps(file(0))		;only check the first file - somewhat dangerous
qcolor = keyword_set(color)
if (keyword_set(ascii) or keyword_set(land)) then qps = 0
qland = keyword_set(land)
;
cmd = ''
queue_name = ''
case strupcase(!version.os) of
    'VMS':	begin & dcmd = 'print '	 & queopt = '/queue=QUEUE_NAME '& delopt = '/delete '	& end
    'ULTRIX':	begin & dcmd = 'lpr -h ' & queopt = '-P QUEUE_NAME '	& delopt = ''		& end
    'IRIX':	begin & dcmd = 'lp -h '	 & queopt = '-d QUEUE_NAME '	& delopt = ''		& end
    else:	begin & dcmd = 'lpr -h ' & queopt = '-P QUEUE_NAME '	& delopt = ''		& end
endcase
;
;------------- #1 Look for CMD being passed in
;
if (keyword_set(cmd_in)) then cmd = cmd_in
;
;------------- #2 Look for the QUEUE name being passed in
;
if (keyword_set(queue)) then queue_name = queue
;
;------------- #3 Look for the PR* environment variable
;
if (cmd eq '') then begin
    cmd0 = getenv('SSW_PR_PS')		& if (qps and                   (cmd0 ne '')) then cmd = cmd0
    cmd0 = getenv('SSW_PR_PS_COLOR')	& if (qps and qcolor and        (cmd0 ne '')) then cmd = cmd0
    cmd0 = getenv('SSW_PR_ASCII')	& if ((not qps) and             (cmd0 ne '')) then cmd = cmd0
    cmd0 = getenv('SSW_PR_ASCII_LAND')	& if ((not qps) and (qland) and (cmd0 ne '')) then cmd = cmd0
end
;
;------------- #4 Look for the QUE* environment variable
;
if (queue_name eq '') then begin
    que0 = getenv('SSW_QUE_PS')		& if (qps and                   (que0 ne '')) then queue_name = que0
    que0 = getenv('SSW_QUE_PS_COLOR')	& if (qps and qcolor and        (que0 ne '')) then queue_name = que0
    que0 = getenv('SSW_QUE_ASCII')	& if ((not qps) and             (que0 ne '')) then queue_name = que0
end
;
;------------- #5 Best guess default
;
if (cmd eq '') then begin
    cmd = dcmd	;default command from above
    if (queue_name ne '') then cmd = cmd + queopt
end
;
;------------- #6 Prepend the ASCII format statement
;
cmd_save = cmd
if (not qps) then begin
    fmt0 = getenv('SSW_FMT_ASCII')
    if ((not qland) and (fmt0 ne '')) then begin
	cmd_save2 = str_replace(cmd, 'FILENAME', '')		;remove the FILENAME portion
	cmd = fmt0 + ' | ' + cmd_save2
    end
    ;
    fmt0 = getenv('SSW_FMT_ASCII_LAND')
    if (qland and (fmt0 ne '')) then begin
	cmd_save2 = str_replace(cmd, 'FILENAME', '')		;remove the FILENAME portion
	cmd = fmt0 + ' | ' + cmd_save2
    end
end
;
;------------- #7 Adjust command for NODE option
;
if (n_elements(node) eq 0) then node0 = getenv('SSW_PR_NODE') else node0=node
if (keyword_set(node0)) then begin
    if (cmd ne cmd_save) then begin
	cmd = fmt0 + ' | rsh ' + node0 + ' ' + cmd_save2
    end else begin
	cmd = str_replace(cmd, 'FILENAME', '')		;remove the FILENAME portion
	cmd = 'cat FILENAME | rsh ' + node0 + ' ' + cmd
    end
end
;
;------------------------------------- final building of the command making substitutions
;
if (qdebug) then begin
    print, 'QPS=', qps
    print, 'QLAND=', qland
    print, 'CMD=' + cmd
    print, 'QUEUE_NAME=' + queue_name
end
;
files = arr2str(file, delim=' ')
p = strpos(cmd, 'FILENAME')
if (p ne -1) then cmd = str_replace(cmd, 'FILENAME', files) $
		else cmd = cmd + ' ' + files		;simply append it
;
p = strpos(cmd, 'QUEUE_NAME')
if (p ne -1) then cmd = str_replace(cmd, 'QUEUE_NAME', queue_name)
;
print, 'SPRINT: Print command: ' + cmd
if (qnospawn) then begin
    Print, 'SPRINT: Exiting without spawning command
    return
end
;
spawn,cmd
;
if keyword_set(delete) then file_delete,file
end

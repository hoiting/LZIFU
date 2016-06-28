pro pprint, file, dev_que=dev_que,  delete=delete, reset=reset, $
	color=color, banner=banner, force_print=force_print, node=node, $
	qdebug=qdebug, nospawn=nospawn
;+
;NAME:
;	pprint (OBSOLETE -- See SPRINT.PRO)
;PURPOSE:
;       Closes currently open hardcopy plot device (if necessary) and 
;	sends the plot file to the appropriate device.
;	This is the Unix Version of the routine.
;CALLING SEQUENCE:
;	pprint
;	pprint, 'idl_save.ps'
;OPTIONAL INPUTS:
;	file	- if present, filename to print (default=idl.ps)
;KEYWORD INPUTS:
;       dev_que	- if set, device name or number (default=lp0)
;	delete	- if set, delete file after spooling
;	reset	- if set, sets plot to X before exit 
;	color 	- if set, use color (device = lp1)
;	banner	- if set, print banner page (default is no banner page)
;			------ OBSOLETE - NOT USED BY SPRINT ------
;	force_print - If set, then issue the print command even if the
;		  plot device is not PS.
;	node	- If set, the use an "rsh" and "cat" command to send 
;		  the print command to the remote machine.
;	qdebug	- If set, then print the spawn command
;HISTORY:
;	Starting point was "lprint.pro"	slf, 12/5/91
;		slf, 1/22/92 - isass mods  
;		mdm, 3/3/92 - Do not print anything if device is not PS
;	12-Mar-92 (MDM) - Renamed to pprint
;	21-aug-92 JRL, Fixed dev_que option.
;	 6-feb-93 JRL, Fixed for use at LPARL
;	 6-Oct-93 MDM,  Expanded to use "lp" queue if on flare machine
;			Added /FORCE_PRINT
;	 7-Oct-93 MDM,  Minor changes in the organization
;			Added /QDEBUG option
;	 9-Oct-93 MDM,  Removed ban option for printing to SGI
;	28-Jan-94 MDM,  Added check for PRINTER enviroment variable
;	15-Mar-94 MDM,  Added check for PRINTER_CMD environment variable
;       28-Mar-94 SLF,  Change print command on SGI to:/usr/local/bin/lps20ps
;	15-Apr-94 MDM,  Added check for PPRINT_NODE environment variable
;	 3-May-94 MDM,  Added "-c" option for lp command to kodak from SXT
;			so that the file is copied (spooled)
;       16-feb-95 SLF,  fix lparl color queue name (and force_print)
;       17-Feb-95 SLF,  ignore PRINTER if /color set
;	27-Feb-95 MDM,  Removed "force_print=1"
;	19-Sep-95 MDM,  Made it work with remote NODE and PRINTER_CMD together
;	 4-Apr-96 MDM,  Added PRINTER_COLOR option and changed default printer
;			to kodak for color
;	15-Apr-97 MDM,  Gutted and modified to call SPRINT (SSW routine)
;-
;
if ((!d.name ne 'PS') and (not keyword_set(force_print))) then return		; MDM added 3-Mar-92
if (!d.name eq 'PS') then device,/close			;MDM added 6-Oct-93
;
if (n_elements(file) eq 0) then file='idl.ps'	; default file name

sprint, file, queue=dev_que, delete=delete, color=color, $
		qdebug=qdebug, nospawn=nospawn, node=node

if keyword_set(reset) then set_plot,'x'
;
return
end



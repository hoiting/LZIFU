;+
; Project     : SDAC
;
; Name        : 
;	XDOC
; Purpose     : 
;	Front end to online documentation software.
; Explanation : 
;	Provides online documentation for IDL procedures found in the IDL
;	search path.  This procedure decides whether the graphics device
;	supports widgets, in which case it calls SCANPATH; otherwise it calls
;	DOC_MENU.
; Use         : 
;	XDOC		;For prompting.
;	XDOC, NAME	;Extract documentation for procedure NAME.
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	NAME = String containing the name of the procedure.
; Outputs     : 
;	PROC = string array with latest selected procedure text.
; Opt. Outputs: 
;	None.
; Keywords    : 
;       See SCANPATH
; Calls       : 
;	DOC_MENU, SCANPATH, HAVE_WIDGETS, SELECT_WINDOWS
; Common      : 
;	None.
; Restrictions: 
;	None.
; Side effects: 
;	None.
; Category    : 
;	Documentation, Online_help.
; Written     : 
;	Dominic Zarro, (ARC/GSFC), 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Changed test for widgets and incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 24 June 1993.
;		Added ON_ERROR statement to correct problem on VMS machines.
;       Version 3, Dominic Zarro, (ARC/GSFC), 1 August 1994.
;               Changed name from DOC to XDOC and added keyword-inheritance
;               to inherit keywords from SCANPATH.
;       Version 3.1, Dominic Zarro (ARC/GSFC), 18 September 1994.
;               Added PROC argument to return text of last selected procedure.
;       Version 3.2, Dominic Zarro (ARC/GSFC), 12 December 1994.
;               Added check for IDL release version.
;       Version 4, Zarro, GSFC, 2 September 1996.
;               Incorporated new SCANPATH
;	Version 5, 23-Oct-1997, William Thompson, GSFC,
;		Only select X device if on Unix or VMS.
;		Use SELECT_WINDOWS
; Version     : 
;	Version 5, 23-Oct-1997
;-
;
	pro xdoc, name,proc,group=group,_extra=extra,reset=reset
        if keyword_set(reset) then xkill,/all
        on_error,1
        if datatype(name) eq 'STR' then input=1 else input=0
        version=float(strmid(strtrim(!version.release,2),0,3))
        dsave=!d.name
	select_windows
        if have_widgets() then begin
         caller=get_caller(status)
         nokill=xalive(group) or (1-status)
         if version ge 3.5 then $
          scanpath,name,proc,group=group,_extra=extra,reset=reset,nokill=nokill else $
           scanpath,name,proc,group=group,nokill=nokill,reset=reset
        endif else if input then doc_menu,name else doc_menu
        if !d.name ne dsave then setplot,dsave
	return
	end

;+
; Project     : SDAC
;
; Name        : SCANPATH
;
; Purpose     : Widget prog. for reading documentation within IDL procedures
;
; Explanation :
;	Widget-based routine to read in the documentation from IDL procedures
;	in the search path.  Optionally, reads in the entire procedure.
; Use         :
;	SCANPATH  [, NAME ]
;
; Inputs      : None required.
;
; Opt. Inputs : NAME - Name of procedure to search and document
;
; Outputs     :
;	None.
; Opt. Outputs:
;       PROC:           String array with the text of the latest saved procedure
; Keywords    :
;       RESET:          Clear out previous procedures from memory
;       PC:             If set, then put directory list widget in separate column
;       LAST:           Restore last procedure in memory
;       NOKILL:         Set to not do a global widget reset
;       FONT  :         Set personal FONT
;
; Common      :
;	Uses the common blocks defined in SCANPATH_COM.
; Restrictions:
;	Needs X-windows and widgets support (MOTIF or OPENLOOK).
; Side effects:
;	If "ALL" is selected to read in the entire file, then memory problems
;	may arise when reading very large procedure files.
; Category    :
;	Documentation, Online_help.
; Prev. Hist. :
;	Written May'91 by DMZ (ARC).
;	Modified Dec 91 by WTT (ARC) to support UNIX, and add the following
;		features:
;			- Search current directory, as well as !PATH
;			- Allow for files "aaareadme.txt" containing more
;			  general information to also be searched.
;			- Only save last five procedures in memory.
;			- Add "documentation only" button.
;			- Use environment variable IDL_PRINT_TEXT
;			- Change extensions ".SCL", ".MOD" to "._SCL", "._MOD".
;       Modified Jan'92 by DMZ (ARC) to sense screen size and autosize widgets
;	Modified Feb'92 by WTT (ARC) to use SCANPATH_FONT environment variable.
;	Modified Feb'92 by DMZ (ARC) to include a message window
;	Modified Mar'92 by DMZ (ARC) to enable remote printing of files
;       Modified Jul'92 by DMZ (ARC) to improve DOC_ONLY switch and add EXTRACT button
;       Modified Oct'92 by DMZ (ARC) to accept procedure name as input
;       Modified Dec'92 by EEE (HSTX) to accept search strings
;       Modified Mar'93 by DMZ (ARC) to handle "~" in UNIX directory names
;                                    and print modules from VMS text libraries
; Written     :
;	D. Zarro, GSFC/SDAC, May 1991.
; Modified    :
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Renamed SCANPATH_COM to SCANPATH_COM for DOS compatibility,
;		changed line defining YSZ, and incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 18 June 1993.
;		Added IDL for Windows compatibility.
;		Changed size of widgets to better fit in IDL for Windows.
;		Split columns into two widget windows to make better use of
;               space.
;	Version 2.1 Dominic Zarro, GSFC, 21 July 1993.
;		Made procedure and search text widgets independent bases.
;       Version 3, Dominic Zarro, GSFC, 1 August 1994.
;               Cleaned up and added check for XDOC_ONLY environment variable.
;               Changed SCANPATH_FONT to XDOC_FONT for procedure text widget
;       Version 3.1, Dominic Zarro, GSFC, 16 August 1994.
;               Added /NOSPLIT keyword.
;               Fixed /FONT so that original font is restored on exit.
;               (This keyword overrides the value of XDOC_FONT)
;       Version 3.2, Zarro, GSFC, 24 August 1994.
;               Fixed bug where XMANAGER was being called twice.
;               Excised PC keyword
;       Version 3.3, Zarro, GSFC, 3 September 1994.
;               Fixed another potential bug when XMANAGER was being
;               called twice during search.
;       Version 4, Zarro, GSFC, 18 September 1994.
;               Put back /PC. If set, then the directory list widget appears
;               in a second column (rather than in a third row, where
;               it usually falls off the screen).
;       Version 4.1, Zarro, GSFC, 19 September 1994.
;               Removed forcing of procedure names to lowercase.
;               Converted PROC keyword to argument to enable transfer
;               back to XDOC
;       Version 5, Zarro, GSFC, 10 October 1994.
;               Changed search text function to search file function.
;               Added STRIP_DOC function.
;       Version 5.1, Zarro, GSFC, 22 October 1994.
;               Added LAST keyword to restore last save procedure
;       Version 5.2, Zarro, GSFC, 12 December 1994.
;               Fixed potential bug in FIND logic -- should only arise
;               in 1 in 22 million cases.
;       Version 6.0, Zarro, GSFC, 1 September 1996.
;               Optimized with new widget routines
;       Version 7.0, Zarro, GSFC, 1 December 1996.
;               Optimized with better search routines
;       Version 8.0, Zarro, GSFC, 1 August 1997.
;               Added history option
;       Version 9.0, Zarro, GSFC, 1 December 1997.
;               Added detach option
;       Version 10.0, Zarro, GSFC, 1 March 1998
;               Added /NO_BLOCK (IDL version 5 only)
;       Version 11.0, Zarro, GSFC, 20 May 1998
;               Added more control for FONT and TEXT size
;       Version 12.0, Kim. GSFC, 6 June 2005
;               If dfont is a blank string, set to (get_dfont())(0)
;       Modified 23-Aug-05, Zarro (L-3Com/GSFC) - added XHOUR
;       Modified, 2-Mar-07, Zarro (ADNET) - removed EXECUTE
;-
;
;============================================================================

pro scanpath_event, event                         ;event driver routine

common scanpath_com,base,tlist,mlist,keepb,histb,dfont,mhist,tsize,$
       comment,base2,docb,stext,doc_only,multb,sbutt,rbutt,detached,$
       mtitle,lname,fname,tproc,mods,lnames,last_name,vms,hidden

common procb,names,procs


;-- take care of different event names

widget_control, event.id, get_uvalue = uservalue
if not exist(uservalue) then uservalue=''

;-- do an initial search

if (strmid(uservalue(0),0,4) eq 'find') then begin
 scanpath_proc,strmid(uservalue,5,100)
 return
endif

;-- update clock

if (uservalue(0) eq 'update') or (not timer_version()) then begin
 widget_control,event.top,tlb_set_title=mtitle+'  Current time: '+!stime
 widget_control,multb,sensitive=xregistered('xtext',/noshow) gt 0
 widget_control, stext, get_value=value
 name = trim(value(0))
 widget_control,sbutt,sensitive=name ne ''
 widget_control,rbutt,sensitive=name ne ''
; scanpath_history
 if timer_version() then begin
  widget_control,event.id,timer=1
  return
 endif
endif
reload=0

;-- take care of button widgets

wtype=widget_info(event.id,/type)

if wtype eq  1 then begin
 bname=strtrim(uservalue(0),2)


;-- extract last proc in XTEXT

 if (bname eq 'print') or (bname eq 'extract') or (bname eq 'reload') or (bname eq 'quit') then begin
  if (fname eq '') and (bname ne 'quit') then begin
   xack,'Please select a file',group=event.top
   return
  endif
;  scanpath_recover
 endif

 case bname of

  'quit'   :         begin
                      if vms then begin
                       rm_file,concat_dir(getenv('HOME'),'*._xdoc_mod')
                       rm_file,concat_dir(getenv('HOME'),'*_xdoc_proc.pro')
                       if exist(names) then begin
                        lpos=strpos(strlowcase(names),'_xdoc_proc.pro')
                        keep=where(lpos eq -1,count)
                        if count gt 0 then begin
                         names=names(keep)
                         procs=procs(*,keep)
                        endif else begin
                         names='' & procs=''
                        endelse
                       endif
                      endif
                      if xalive(base2) then begin
                       wtext=widget_info(base2,/child)
                       xtext_reset,wtext
                      endif
                      xtext_reset,stext
                      xkill,base,base2
                      if (event.id eq keepb) and (fname ne '') then begin
                       scanpath_txt,/just_reg
                      endif
                     end

  'reset'  :         widget_control,stext,set_value=''

  'print'  :         begin                         ;-- print file
                      widget_control,comment,set_value='Printing '+fname
                      xprint,array=tproc,group=event.top,/delete
                      widget_control,comment,set_value='Ready for another selection'
                     end

  'extract':         begin                        ;-- extract file
                      cd,cur=def
                      m='Extracting "'+fname+'" into: '
                      if fname eq '*info*' then tname='aaareadme' else begin
                       break_file,fname,dsk,dir,tname
                      endelse
                      target=concat_dir(def,tname+'.txt')
                      xinput,target,m,status=status,group=event.top
                      if status then begin
                       str2file,tproc,target,err=err
                       if err ne '' then xack,err,group=event.top
                      endif
                     end

  'doc_only':        begin
                      doc_only=event.select
                      if fname ne '' then begin
                       prefix='m_' & suffix=fname & goto,again
                      endif
                     end

  'multiple':        scanpath_txt,group=base,/new

  'reload':          begin
                      if fname ne '' then begin
                       prefix='m_' & suffix=fname & reload=1 & goto,again
                      endif
                     end

  else:              do_nothing=1
 endcase

;-- check if history button pressed

 hpos=strpos(bname,'h_')
 if hpos gt -1 then begin
  hfile=strmid(bname,2,strlen(bname))
  scanpath_proc,hfile
 endif

endif

;-- list events

if wtype eq 6 then begin
 ename=uservalue(event.index)
 prefix=strmid(ename,0,2) & len=strlen(ename)
 suffix=strmid(ename,2,len)
again:
 case prefix of

  'l_':    begin                    ;--  determine module names
            widget_control,stext,set_value=''
            lname=suffix & fname=''
            widget_control,comment,set_value='Getting file names, standby...'
            xhour
	    mods=get_mod(lname(0))
            widget_control,base,/show
            if n_elements(mods) eq 0 then mods=''
            if (n_elements(mods) eq 1) and (strtrim(mods(0),2) eq '') then begin
             widget_control,mlist,set_value=mods
             widget_control,mlist,sensitive=0,/show
             widget_control,comment,set_value='No program files found'
            endif else begin
             widget_control,mlist,/sensitive,/show
             widget_control,mlist,set_value=mods,set_uvalue='m_'+mods
             widget_control,comment,set_value='Please select a file'
            endelse
           end

   'm_':  begin
            fname=suffix
            widget_control,comment,$
             set_value='Reading '+fname+', standby...'
            xhour
	    proc=get_proc(lname(0),fname,reload=reload)
            readme=(strpos(strlowcase(fname),'*info*') gt -1)
            err=''
            if doc_only and not readme then tproc=strip_doc(proc,err=err) else tproc=proc
            last_name=fname
            widget_control,base,/show
            widget_control,comment,set_value='Ready for another selection'
            if n_elements(proc) ne 0 then begin
             widget_control,keepb,sensitive=(fname ne '')
             if err ne '' then xack,err,group=event.top else scanpath_txt,group=base
            endif
            scanpath_history
           end

   else:   do_nothing=1
 endcase
endif

;-- search text event

if (event.id eq stext) or (uservalue(0) eq 'search') then begin
 widget_control, stext, get_value=value
 name = trim(value(0))
 widget_control,stext, set_value=name
 if name ne '' then scanpath_proc,name
endif

return & end

;============================================================================

pro scanpath_clean,dummy             ;-- garbage-collect orphaned pointers

common scanpath_com
dprint,'% XDOC cleaning up...'
xtext_reset,comment
xtext_reset,stext
free_pointer,hidden
return & end

;============================================================================

pro scanpath_history            ;-- update history button

common scanpath_com
common procb

if datatype(names) eq 'STR' then begin
 np=n_elements(names)
 widget_control,histb,update=0

 for i=np-1,0,-1 do begin
  hname=names(np-i-1)
  if trim(hname) ne '' then begin
   if vms and (strpos(hname,'_xdoc_proc') gt -1) then begin
    break_file,hname,hdsk,hdir,thname
    tpos=strpos(thname,'_xdoc_proc')
    thname=strupcase(strmid(thname,0,tpos))+'.PRO'
;    if exist(lname) then thname=lname(0)+'/'+thname
   endif else begin
;    thname=hname
    break_file,hname,hdsk,hdir,thname,ext
   endelse
   if i lt n_elements(mhist) then begin
    widget_control,mhist(i),set_value=thname+ext,set_uvalue='h_'+hname
   endif
  endif
 endfor
endif

sens=datatype(names) eq 'STR'
if sens then sens=trim(names(0)) ne ''
widget_control,histb,sensitive=sens
widget_control,histb,update=1

return & end

;============================================================================

pro scanpath_proc,name,found=found       ;-- find files in !path

common scanpath_com
common procb
vms=os_family() eq 'vms'
found=0
if trim(name) eq '' then return
widget_control,comment,set_value='Searching for file, standby...'
xhour
widget_control,base,sensitive=0
chkarg,name,proc,tname,found=found,/prog
break_file,name,dsk,dname,pname,ext,vers
widget_control,base,sensitive=1

;-- if found then list it (prepend "@" back onto library name).

if found then begin
 lname=tname
 fname=strtrim(pname+ext+vers,2)
 last_name=fname
 tlb=strpos(strlowcase(tname),'.tlb') gt -1
 mods=get_mod(lname)
 readme=(strpos(strlowcase(fname),'aaareadme.txt') gt -1)
 widget_control,mlist,set_value=mods,set_uvalue='m_'+mods
 err=''
 if doc_only and not readme then tproc=strip_doc(proc,err=err) else tproc=proc
 widget_control,stext,set_value=name
 widget_control,comment,set_value='Found in: '+lname

;-- highlight list widgets

 lrev=string(reverse(byte(lname)))
 chk=strpos(lrev,'/')
 tname=lname
 if chk eq 0 then tname=string(reverse(byte(strmid(lrev,1,strlen(lrev)))))
 if vms then clook=where(strupcase(tname) eq strupcase(lnames),cnt) else $
  clook=where(tname eq lnames,cnt)
 if cnt gt 0 then widget_control,tlist,set_list_select=clook(0)

 break_file,name,dsk,hname,tname,ext

 if (not tlb) then begin
  if (ext eq '') then tname=tname+'.pro' else tname=tname+ext
 endif
 if vms then clook=where(strupcase(tname) eq strupcase(mods),cnt) else $
  clook=where(tname eq mods,cnt)
 if cnt gt 0 then widget_control,mlist,set_list_select=clook(0)
 widget_control,keepb,sensitive=(fname ne '')
 if err then xack,err,group=base else scanpath_txt,group=base
endif else widget_control,comment,set_value=name+' not found'

return & end

;============================================================================

pro scanpath_txt,just_reg=just_reg,group=group,new=new

common scanpath_com

if keyword_set(new) then delvarx,base2 else $
 if not xalive(base2) then base2=get_handler_id('xtext')

if xalive(stext) then widget_control,stext,set_value=fname
nwin=xregistered('xtext',/noshow) > 1
if keyword_set(new) then nwin=nwin+1
if nwin gt 1 then begin
 frame=' -- window: '+trim(string(nwin))
 title=fname+frame
endif else title=fname

if not exist(tsize) then tsize=30
xtext,wbase=base2,tproc,space=0,title=title,detach=detached,$
ysize=tsize,/scroll,xsize=80,font=dfont,unseen=unseen,$
 /no_print,/no_save,group=group,just_reg=just_reg,/no_block
if exist(unseen) then begin
 if not exist(hidden) then hidden=unseen else hidden=[hidden,unseen]
endif

return & end

;============================================================================

pro scanpath_recover

common scanpath_com

base2=get_handler_id('xtext')
if xalive(base2) then begin
 wtext=widget_info(base2,/child)
 if xalive(wtext) then begin
  widget_control,wtext,get_value=tproc
  sibling=widget_info(wtext,/sib)
  if xalive(sibling) then begin
   widget_control,sibling,get_uvalue=wname
   wpos=strpos(wname,'(window')
   if wpos gt -1 then begin
    fname=trim(strmid(wname,0,wpos))
    dprint,'recovered '+fname
   endif
  endif
 endif
endif

return & end

;============================================================================

pro scanpath,name,proc,reset=reset,last=last,_extra=extra,ysize=ysize,$
             group=group,pc=pc,nokill=nokill,font=font,detach=detach,$
             modal=modal

common scanpath_com
common procb

kill=1-keyword_set(nokill)
if not have_widgets() then message,'widgets are unavailable'
if n_elements(procs) eq 0 then procs=''
if n_elements(names) eq 0 then names=''
if keyword_set(pc) then pc=1 else pc=0
vms=os_family() eq 'vms'
detached=keyword_set(detach)

;-- wipe memory clean

fname=''
if n_elements(last_name) eq 0 then last_name=''
if keyword_set(reset) then begin
 names='' & procs='' & last_name=''
endif

xkill,'scanpath'
xkill,base,base2
mtitle='XDOC Version: 11 '
base = widget_mbase(title =mtitle+'  Current time: '+!stime,/column,$
                    group=group,modal=modal)

;-- check user FONT/SIZE requirements

dfont=''
mk_dfont,bfont=bfont
xdoc_font=getenv('XDOC_FONT')
if datatype(font) eq 'STR' then xdoc_font=font
if trim(xdoc_font) ne '' then dfont=(get_dfont(xdoc_font))(0)
if trim(dfont) eq '' then dfont = (get_dfont())(0)

tsize=30
xdoc_size=fix(getenv('XDOC_SIZE'))
if exist(ysize) then xdoc_size=fix(ysize)
if xdoc_size gt 0 then tsize=xdoc_size

;-- top row of buttons

col1=widget_base(base,title=' ',/column)

bopts=widget_base(col1,/row,/frame)

;-- return button

;b=cvttobm(bytscl(dist(50)))
quitb=widget_button(bopts,value='Done',/no_release,/menu,$
      font=bfont)
quit=widget_button(quitb,value='Quit completely',/no_release,uvalue='quit',$
      font=bfont)
keepb=widget_button(quitb,value='Quit, but retain last file window',uvalue='quit',/no_release,$
      font=bfont)
widget_control,keepb,sensitive=0

;-- print button

printb=widget_button(bopts,value='Print',uvalue='print',/no_release,$
                     font=bfont)

;-- extract button

extractb=widget_button(bopts,value='Extract',uvalue='extract',/no_release,$
         font=bfont)

;-- reload button

reloadb=widget_button(bopts,value='Reload',uvalue='reload',/no_release,$
         font=bfont)

multb=widget_button(bopts,value='New Window',uvalue='multiple',font=bfont)
widget_control,multb,sensitive=0

;-- history button
;-- up to 20 recent procedures can be stored in history list

nmax=20
histb=widget_button(bopts,value='History',uvalue='history',font=bfont,$
                    /menu)
if datatype(names) eq 'STR' then wmax=max(strlen(names)) > 10 else wmax=10
mhist=lonarr(nmax)
for i=0,nmax-1 do begin
 mhist(i)=widget_button(histb,value=strpad('',wmax),uvalue='',font=dfont)
endfor


;-- doc only button

values=['Doc Only']
xmenu2,values,bopts,/column,/nonexclusive,/frame,$
      buttons=docb,uvalue=['doc_only'],font=bfont

if not exist(doc_only) then begin
 doc_only=0
 xdoc_only=strtrim(chklog('XDOC_ONLY'),2)
 if (xdoc_only ne '') and (xdoc_only ne '0') then doc_only=1
 xdoc_only2=strtrim(chklog('xdoc_only'),2)
 if (xdoc_only2 ne '') and (xdoc_only2 ne '0') then doc_only=1
endif

widget_control,docb(0),set_button=doc_only

;-- 1st column contains list of libraries (or directories) and modules

row=widget_base(col1,/row)
slab=widget_label(row,value='Current search file: ',font=bfont)
stext=widget_text(row,/editable,font=dfont,uvalue='search')
sbutt=widget_button(row,value='Search',font=bfont,uvalue='search')
rbutt=widget_button(row,value='Reset',font=bfont,uvalue='reset')

comment=widget_text(col1,ysize=2,value=' ',/scroll,font=dfont)
lnames=get_lib()
tlabel=widget_label(col1,font=dfont,$
                    value='Select from the following directories/libraries')
tlist=widget_list(col1,ysize=12,value=lnames,uvalue='l_'+lnames,font=dfont)

;-- list of modules in selected library

if pc then temp=base else temp=col1
mlabel=widget_label(temp,value='Select from the following files',font=dfont)
mlist=widget_list(temp,ysize=12,font=dfont)

;-- search widget

;-- create and position windows

widget_control,base,/realize

;-- check input

do_find=0
if datatype(name) ne 'STR' then name=''
if keyword_set(last) and (last_name ne '') and (name eq '') then name=last_name
if name ne '' then do_find=1 else $
 widget_control,comment,set_value='Please select a library/directory'

if do_find then widget_control,base,timer=1,set_uvalue='find_'+name

;-- set up clock

child=widget_info(base,/child)
if timer_version() then begin
 widget_control,child,set_uvalue='update'
 widget_control,child,timer =1
endif

;-- update history list

scanpath_history

xmanager,'scanpath',base,clean='scanpath_clean',/no_block

;if idl_release(lower=5,/incl) then expr=expr+',/no_block'
;s=execute(expr)

dprint,'% out of SCANPATH'
;xmanager_reset,base,group=group,modal=modal,/no_block,crash='scanpath',/retall

if not xalive(base) then begin
 xshow,group
 scanpath_clean

;-- return most recent procedure

 if exist(tproc) then proc=tproc
endif

return & end



pro stepper_title, title, break, blank=blank, $
	brief=brief, charsize=charsize, color=color
;
;
;   stepper_title ; overly title on graphics device for stepper/xstepper
;
;   History - slf, 10-Jun-92 - provide single point maint for title
;	      slf, 31-aug-93 - add charsize and color keywords

;
;   Side Effects - title is written to default graphics device
;
if keyword_set(blank) then color = 0 else color =255
case 1 of
   keyword_set(blank): color=0
   1-keyword_set(color): color=255
   else:
endcase

if n_elements(charsize) eq 0 then charsize=1.26


title=title(0)					
if n_elements(break) eq 0 then begin
   break = 38        ; Break point
   nb=strpos(strmid(title,break,strlen(title)),' ')
   break=break+nb   
endif

if strlen(title) le break then begin
    xyouts,0,10,title, color=color,/device, charsize=charsize
endif else begin
     str0 = strmid(title,0,break)
     str1 = strmid(title,break,strlen(title))
     xyouts,10,10,str1,charsize = charsize, /device, color=color
     xyouts, 0,23,str0,charsize = charsize, /device, color=color
endelse 
return
end

function xstepper_status
;
;
;   xstepper_status ;  provide text description of common area variables
;
;   Keyword Parameters:
;      file - if set, output to text file
;
;
@xstepper.common
;
case dispopt of
   0: begin
         desc=' Data  Set  Contains  ' + strtrim(string(nimages),2) + $
	       '  images'
         desc=[desc,sinfo]
      endcase
   1: begin
        if sscnt eq 0 then desc=' No  SS  Vector  Defined' else begin 
	   desc=' SS  Vector  Contains ' + strtrim(string(sscnt),2) $
	   + '  elements' 
           desc=[desc,sinfo(ssmap(where(ssmap ge 0)))]
	endelse
      endcase
   2: begin
        if pixcnt eq 0 then desc='No PIXMAPs Defined' else begin
	   desc=strtrim(string(pixcnt),2) + '  PIXMAPs currently  ' + $
		'  defined'
	   desc=[desc,reform(sinfo(pixmap(0,where(pixmap(0,*) ge 0))))]
	endelse
      endcase
   else:
endcase
;
return,desc
end
pro update_piximg, topid
;
;
;   update_pixmap ; background task for xstepper pixmap movie sequence
;
;   History: slf, 2-Jun-92
;
;
@xstepper.common		; define common block variables
;
new=pixpnt+delta
case 1 of
   (new lt 0): new=pixcnt-1
   (new gt pixcnt-1): new=0
   else:                                ; within range
endcase
;
; handle auto-reverse function if selected
if (areverse) and (( (new eq 0) and (delta lt 0)) or  $
   ((new eq pixcnt-1) and delta gt 0) ) then delta=-delta
;
pixpnt=new
;
; set up window
wset,curwind

device,copy=[0,0,xs*mag_fact,ys*mag_fact,0,0,pixmap(1,pixpnt)]
return
end
pro update_image, topid , loud=loud
;
;
;   update_image ; update image and image parameters for xstepper and display
;
;   Input Parameters:
;      topid - widget id of toplevel (xstepper) widget
;
;   Keyword Parameters:
;      quiet - if set, inhibits status messages
;
;   History: slf, 30-Apr-92 (for xstepper)
;	     slf,  4-Jun-92 (add ssmap option)
;            slf, 19-Oct-92 (fixed interp bug)
;   
;
@xstepper.common
;
if dispopt ge 2 then begin			;wrong bckgrnd task?
   message,/info,'Invalid Display Option'
   return
endif

; set rate (more important for pixmap displays)

case dispopt of
   0: begin			; display DATA
         ss=subs
	 pnt=current
	 limit=nimages
      endcase 
   1: begin			; display DATA(SS)
         ss=ssmap
	 pnt=sspnt
	 limit=sscnt
      endcase
endcase
;
; first determine and update image pointer
; handle range rollovers - (wrap or auto-reverse)
new=pnt+delta
;
case 1 of  
   (new lt 0): new=(limit-1) 
   (new gt limit-1): new=0
   else:				; within range
endcase

; handle auto-reverse function if selected
if (areverse) and (( (new eq 0) and (delta lt 0)) or  $
   ((new eq limit-1) and delta gt 0) ) then delta=-delta

if dispopt eq 0 then current=new $	; update image pointer
   else sspnt=new

image=scube(*,*,ss(new))		; select current image
;

; set up window
wset,curwind
; select display procedure and then display
;
; if over_info then stepper_title, last_title, /blank
scale_proc=['tv','tvscl']
call_procedure,scale_proc(scale), congrid(image,xs,ys,interp=interp)
; erase unused portion of screen in title area (cleaner display)
unused=!d.x_size-(xs*mag_fact)
;if unused gt 0 then begin
;   area=bytarr(unused,64)
;   tv,area,xs,0
;endif

; 
;update text information
;if selected, overlay info on graphics device
outstring=sinfo(ss(new))
if over_info then begin
   stepper_title, outstring
   last_title=outstring
endif
;
; now output to widget text window determine if break required
if xs lt 512 then begin
    break=38			; same as stepper
    infolen=strlen(outstring)
    test=strmid(outstring,break,infolen) 
    break=break+strpos(test,' ')
    outstring=[strmid(outstring,0,break),strmid(outstring,break,infolen)]
endif
outstring=strtrim(outstring,2)
;

widget_control, set_value=outstring, xstep_str.text.text
;
; zoom if feature turned on
if zoom(0) then $
   zoom_single, zoom(2), zoom(3), window=zoom(1), scale=scale, $
	fact=zoom(4)

return
end
pro xstepper_t_event, event

;
;   xstepper_t_event ; manage timer events (movie mode)
;
;   27-feb-1997 - Change from backreg to timer (Version 5 requiement)
;
@xstepper.common
widget_control,event.top,get_uvalue=top_struct

if minprog then begin
   case dispopt of  
      2: update_piximg,  event.top
      else: update_image,event.top
   endcase   
   widget_control, top_struct.timerid, timer=1./(float(pixrate>1)+.05)
endif
return
end
pro xstepper_event, event
;
;   xstepper_event ; event handler for xstepper
;
;   History: slf, 30-April-1992 - prototype
;	     (based on sda_look.pro, circa oct,91)
;
;   Common Blocks:
;      sda_draw_private
;      xstepper_blk
;
;   History - 30-april-92 (see xtepper.pro documentation)
;	      19-oct-92   (fixed IMG->SS bug)
;             22-feb-93   (cleaned up backregister logic for V3.0)
;	      29-Jun-93   (allow scale/noscale for pixmaps)
;			  (reset pixmaps on QUIT (X-management))
;	      13-Oct-93   fix zoom_single call bug
;	      18-Nov-93 (SLF) Dont write title on PIXAP if title is off
;             27-feb-97 (SLF) backregister->timer events (Version 5 require)
;
;
widget_control,event.top,get_uvalue=top_struct
;
common	sda_draw_private,utility 	; zoom window widget
@xstepper.common

menubuts=get_wvalue(xstep_str.menubuts)
freeze=xstep_str.menubuts(where(menubuts eq 'Freeze'))
movie =xstep_str.menubuts(where(menubuts eq 'Movie'))

case (strtrim(event_name(event),2)) of
;
;-------------------- Draw Event (Zoom Image) -----------------
   "DRAW":begin
      sizeutil=size(utility)
      newone=0
      if sizeutil(1) eq 2 then newone=(total(utility) eq 0)
;
;     ************* break this out  ***********************
      zoom_xs=386
      zoom_ys=386
      if n_elements(utility) eq 0  or newone then begin
;	 define zoom widget
         base=widget_base(/column,title='XSTEPPER Utility')
         label=widget_label(base,/frame,value='Zoom Factor')  
	 zfacts=['2','4','8','16']
         xmenu2,zfacts, base,/exclusive,/row,uvalue=long(zfacts),$
            buttons=utilbuts,/no_release
         curr_zfact=where(zoom(4) eq long(zfacts))
	 widget_control,utilbuts(curr_zfact(0)),$
	    /set_button
         draw=widget_draw(base,xsize=zoom_xs,ysize=zoom_ys,/button_events) 
         widget_control,base,/realize
         utility=[base,draw]		; common
;        ***********************************************************
         xmanager,'utility',base,event_handler='xstep_uevent', $
	    group_leader=event.top
	 wherez=where(strpos(menubuts,'AZoom') eq 0,count)
	 if count ne 0 then $
	    mapx,xstep_str.menubuts(wherez(0)),/map,/show,/sens
	 
      endif
      if event.press then begin 
         which = where(top_struct.views.draw eq event.id)	; views(event)
;
;	 get 'interesting' widget values
         window =get_wvalue(event.id)
         wset,window
 
	 mapx,utility(0),/map,/show,/sensitive
	 widget_control, get_value=window, utility(1)
;
;        for now, just zoom feature enabled
	 zoom_single,event.x,event.y,window=window, scale=scale, $
		fact=zoom(4), xs=zoom_xs, ys=zoom_ys
	 zoom(1:3)=[window,event.x,event.y]
     endif
endcase 
;------------------------------------------------------------------
;
;
"BUTTON":begin				; option selection 
   value=get_wvalue(event.id)
   case strtrim(value,2) of
;
;-----------Display Sequence Direction Function ------------------
      "FWRD>>": begin
          delta=1
	  case dispopt of 
	     2: update_piximg, event.top
             else:update_image, event.top
	  endcase
      endcase
;
      "<<BWRD": begin
          delta=-1
	  case dispopt of 
	     2: update_piximg, event.top
             else:update_image, event.top
	  endcase
      endcase
;----------------------------------------------------------------
;
;-------------------- Movie Function ----------------------------
;     movie mode puts update_image or update_piximg in background
      "Movie"  : begin 
         mapx,[movie,freeze],/map,/show,sens=[0,1]
         minprog=1
         widget_control,top_struct.timerid, timer=float(pixrate)/100.
	 case dispopt of
           2: update_piximg,  event.top
           else: update_image,event.top
         endcase
    endcase
;-------------------------------------------------------------------
;
;-------------- Freeze Frame (stop movie) Function -----------------
;
;     freeze removes update_image from background
      "Freeze": begin
          mapx,[movie,freeze],/map,/show,sens=[1,0]
	  minprog=0
      endcase
;-----------------------------------------------------------------------
;
      "XLOADCT":xloadct, group=event.top
     
;   
;-------------- Title Overlay Toggle Function ----------------------
;     control title overlay.
      "OFF": begin
	 over_info=1
	 widget_control, set_value='ON', event.id
      endcase
;
      "ON":  begin
	 over_info=0
         widget_control, set_value='OFF', event.id 
      endcase
;
;--------------------------------------------------------------------
;
;-------------- Current Image to PIXMAP Function ------------------
;
      "IMG->PIX": begin
	curdef=where(current eq pixmap(0,*),count)	;no duplcates
	if count eq 0 then begin
	   widget_control, xstep_str.text.text, set_value= $
	      strcompress(' Creating PIXMAP for Frame: ' + $
	         string(current))
	   pixdef = where(pixmap(0,*) ge 0,ndef)
	   if ndef eq 0 then newmap=[0,-1] else begin
	       newmap=pixmap(*,pixdef)
	       newmap=[[newmap],[current,-1]]
	    endelse
	    if newmap(1,pixcnt) lt 0 then $ 
               window,/free,/pix,xsize=xs, ysize=ys
	    newmap(1,pixcnt)=!d.window
	    newmap(0,pixcnt)=current
	    order=sort(newmap(0,*))
	    pixmap(0,0)=[[newmap(*,order)]]		;time order 
	    pixcnt = pixcnt+1
            scale_proc=['tv','tvscl']
            call_procedure,scale_proc(scale),$
             congrid(scube(*,*,current),xs,ys,interp=interp) 			;pixmap write 
	    if over_info then stepper_title,sinfo(current)
	    mapx,xstep_str.dispbuts(2),/map,/show,/sens
	    widget_control, xstep_str.text.text, set_value= $
	       ' PIXMAP Complete'  
         endif
      endcase
;------------------------------------------------------------------
;
;--------------- Current Image to SS Function ----------------
      "IMG->SS": begin
	 widget_control,xstep_str.text.text, set_value = $
	    strcompress(' Adding Frame: ' + string(current) + ' to SS Vector')
         curdef=where(current eq ssmap,count)
	 if count eq 0 then begin
	   ssdef = where(ssmap ge 0,ndef)
           if ndef eq 0 then newmap=[current] else $ 
	      newmap=[ssmap(ssdef),current]
	   order=sort(newmap)
	   ssmap(0)=newmap(order)
	   sscnt=sscnt+1
	 endif
	 mapx,xstep_str.dispbuts(1),/map,/show,/sens
	 update_image
       endcase
;---------------------------------------------------------------------
;

;------------------- All SS to PIXMAP Function (recursive) ---------
      "SS->PIX": begin
         xstepper_event,force_evt(event,xstep_str.resetbuts, $
	    value= "RST-PIX" )
         ctemp=current
	 for i=0,sscnt-1 do begin
	    current=ssmap(i)
            xstepper_event,force_evt(event,xstep_str.cimgbuts, $
	       value="IMG->PIX")
	 endfor
	 current=ctemp
      endcase 
;
;-------------------------------------------------------------------
;
;------------------- All Data to PIXMAP Function (recursive) -------
      "DATA->PIX": begin
         xstepper_event,force_evt(event,xstep_str.resetbuts, $
	    value= "RST-PIX" )
         ctemp=current
	 for i=0,nimages-1 do begin
	    current=subs(i)
            xstepper_event,force_evt(event,xstep_str.cimgbuts, $
	       value="IMG->PIX")
	 endfor
	 current=ctemp
      endcase 
;--------------------------------------------------------------------
;
      "IMG-RNG(HI)": range(1)=current
;
;-------------------- Reset PIXMAP Function ----------------------
      "RST-PIX": begin
	 valid=where(pixmap(1,*) ge 0,count)	;identify pixmaps
	 for i=0,count-1 do $
	    wdelete,pixmap(1,valid(i)) 		;free pixmaps
         pixmap(*)=-1				;initialize common
	 pixcnt=0				;  ""
	 pixpnt=0				;  ""
	 if backopt eq 'update_piximg' then begin
            backopt=''
         endif
	 mapx,xstep_str.dispbuts(2),/show,/map,sens=0
	 widget_control, xstep_str.dispbuts(0), /set_button
	 dispopt=0
      endcase
;
;-------------------------------------------------------------------
;
;------------------------- Reset SS Vector Function ----------------
      "RST-SS": begin
	 ssmap(*)=-1
	 sscnt=0
	 sspnt=0
	 mapx,xstep_str.dispbuts(1),/show,/map,sens=0
	 widget_control, xstep_str.dispbuts(0), /set_button
	 dispopt=0
      endcase
;--------------------------------------------------------------------
;
      "PIX-ALIGN": begin
         align_opts=$ 
	    ['+Y','-Y','+X','-X']
	 for i=0,n_elements(xstep_str.cimgbuts)-1 do begin
	   widget_control, set_value=align_opts(i), $  
	      xstep_str.cimgbuts(i) 
	 endfor
       endcase
      "QUIT":begin
         xstepper_event,force_evt(event,xstep_str.resetbuts, $
	    value= "RST-PIX" )
          utility=[0,0]
         widget_control, event.top,/destroy
      endcase
;
      "HELP": widget_control,set_value=xstepper_status(), $
	  xstep_str.text.text
;
;------------------ DATA Display Function --------------------------
      "DATA": begin
	if event.select then begin
          dispopt=0
	  temp=delta
	  delta=0
	  update_image
	  delta=temp
	  if minprog then begin
             backopt='update_image'
          endif
	  mapx,xstep_str.cimgbuts(0:1),/map,/show,/sens
        endif
      endcase
;
;------------------------------------------------------------------
;------------------- DATA(SS) Display Function --------------------
      "DATA(SS)": begin
        if event.select then begin
	  dispopt=1
          if sscnt eq 0 then begin
             widget_control, xstep_str.text.text, set_value= $
	     '  NO  SS  Vector  Currently  Defined'
	  endif else begin
             temp=delta
	     delta=0
	     update_image
	     delta=temp
	     if minprog then begin
                backopt='update_image'
             endif
	  endelse 
	  mapx,xstep_str.cimgbuts(0:1),/map,/show
        endif
      endcase
;
;----------------------------------------------------------------------
;
;----------------- Display PIXMAP Function -------------------------
      "PIXMAP": begin
        if event.select then begin
          dispopt=2
          if pixcnt eq 0 then begin
             widget_control,  xstep_str.text.text, set_value= $
	     '  NO  PIXMAPs  Currently  Defined'
	  endif else begin
	     temp=delta
	     delta=0
	     update_piximg
	     delta=temp
	     widget_control,xstep_str.text.text,set_value=$
	        '  DISPLAYING  PIXMAP ' 
	     if minprog then begin
	     if backopt ne '' then $
                backopt='update_piximg'
             endif
	  endelse
	  mapx,xstep_str.cimgbuts(0:1),/map,/show
        endif
      endcase
;--------------------------------------------------------------------
      ">>IDL":stop		; exit to event loop
;--------------------------------------------------------------------
;
;---------------- auto reverse / wrap display functions -----------
      "Wrap": begin
         areverse=1
         widget_control,event.id,set_value="ARev"
      endcase
;
      "ARev": begin
         areverse=0
         widget_control,event.id,set_value="Wrap"
      endcase
;
;-------------------------------------------------------------------
;    
;----------------------- Auto Zoom Function -----------------------

      "AZoom-ON":begin
         zoom(0)=0
	 widget_control,event.id,set_value="AZoom-OFF"
      endcase
;
      "AZoom-OFF":begin
         zoom(0)=1
	 widget_control,event.id,set_value="AZoom-ON"
      endcase
;--------------------------------------------------------------------
      else:help,value 
   endcase
;
   if event.select then begin
      widget_control, event.id, get_uvalue=option, bad_id=destroyed
      if n_elements(option) ne 0 then top_struct.option=option
   endif
endcase
;---------------------------------------------------------------
;-------------------- Frame Rate Function (via slider) ----------
"SLIDER": begin          
   pixrate=get_wvalue(event.id) 
endcase
endcase
;-----------------------------------------------------------------
;
widget_control, event.top, set_uvalue=top_struct, bad_id=destroyed
return
end
pro xstepper, cube, info, xsize=xsize, ysize=ysize , labels=labels, $
	title=title , interp=interp, noscale=noscale,	$
        info_array=info_array, subscripts=subscripts, start=start, $
	ssout=ssout
;
;+
; NAME:  xstepper
;
; PURPOSE: Widget interface/ X-Windows data cube reviewer  
;
; INPUT PARAMETERS (positional):
;     	cube - image or image cube
;	info - strarray of image information         
;
; OPTIONAL INPUT PARAMETERS (keyword):
;	title 	    - widget title (default=XSTEPPER)
;	xsize/ysize - if present, rebin will be done  
;       noscale     - if set, turns off tvscl 
;	subscripts   - indices of images to display (default=all)
;	interp      - if set, rebin uses interp (default=sample)
;	start       - Index of starting image	
;	info_array  - strarray of image info (for stepper compatibility)
;		      may be passed as optional 2nd positional param
;       ssout       - SubScripts (SS) defined via IMG->SSW
;
; Calling Sequence:
;   xstepper,data [,info_array , xsize=xsize, ysize=ysize, /interp ,
;		   ,start=start, /noscale]
;
; Button Layout:
;
; ------------------------------------------------------------------------
;| QUIT | FWRD>> | <<BWRD | Movie | Freeze | AZoom-OFF | Wrap | XLOADCT   | 
; ------------------------------------------------------------------------
;| HELP | IMG->SS | IMG->PIX | DATA->PIX | SS->PIX | RST-SS | RST-PIX     |   
; ------------------------------------------------------------------------
;| Display:  <>DATA  <>DATA(SS)  <>PIXMAP    Title-Image: <> OFF          | 
; ------------------------------------------------------------------------
;
;Button Description:
;
;   --------------------------------------------------------------------------
;   QUIT 	- exits xstepper
;   FWRD>>	- steps forward 1 image (sets movie direction to forward)
;   <<BWRD	- steps backward 1 image (sets movie direction to backward)
;   Movie	- starts movie mode 
;   Freeze	- stops movie mode
;   AZoom-OFF   - toggles between Auto Zoom Off and Auto Zoom On modes
;   Wrap        - toggles between wrap around and auto reverse modes 
;   XLOADCT 	- runs XLOADCT
;   --------------------------------------------------------------------------
;   HELP	- displays text information about currently selected images
;   IMG->SS	- places current image into SS vector and advances display
;   IMG->PIX	- places current image in a pixmap 
;   DATA->PIX   - places entire data array into pixmap array (memory caution)
;   SS->PIX     - places DATA(SS) into pixmap array
;   RST-SS	- Reset (initialize) SS vector
;   RST-PIX     - Reset (initialize) PIXMAP array
;   --------------------------------------------------------------------------
;   Display:      (select from three categories of image display)
;      DATA	- Original data cube
;      DATA(SS) _ Subset of data cube ( Data(*,*,ss))
;      PIXMAP   - Offscreen Pixmaps (allows fast frame rates on most machines)
;   Title-Image:- Toggles On/Off information written to window area
;   --------------------------------------------------------------------------
;
;   Other Features:
;      clicking on image automatically opens a second window and displays
;      a zoomed copy of the current image - this second window allows selection
;      of zoom factors - clicking on zoom window will hide it.  If the display
;      selection is DATA or DATA(SS), then the zoom window may automatically 
;      track (single step or movie mode) and auto zoom if AZoom-ON is chosen
;      (auto zoom does not work while in PIXMAP display mode)
;      Image information is displayed to the text portion of the widget
;   
;
; Side Effects: widget(s) is displayed to X terminal
;
; Common Blocks: 
;      xstepper_blk     - (xstepper parameters, direction,rebin,etc)
;      sda_draw_private - (utility window info (zoom, etc)
;
;
; Restrictions: - only one instance may be run at a time due to common
;
; HISTORY: S.L.Freeland -  30-Apr-92 (based on stepper/multi_draw (browse)
;	   slf  5-Jun-92  (PIXMAP / SS features)
;	   slf 18-Jun-92  (interface , wrap/autoreverse) 
;	   slf 19-Oct-92  (documentation) 
;          slf 22-Feb-93  (Version 3.0 mods, added backopt to common, cleanup)
;	   slf 12-sep-93  (added curwind to common - xspr compatible)
;	   slf 25-oct-93  (made internal slecected SS relative to input subscripts)
;          slf 27-feb-97  (User Timer events instead of 'xbackregister'
;                         (REQUIRED FOR IDL VERSION > 5.)
;                         Combined several routines in "package"
;          DMZ 20-Nov-97  Fixed XSIZE/YSIZE and removed a TEMPORARY
;          SLF 15-Oct-98  - Clean up some documentation typos/format probs
;                           Add Category list
;          SLF 23-Oct-98  - Add SSOUT (return SS vector defined in xstepper)
;          SLF  6-Nov-98  - made window scrollable and moved speed slider
;                           above image (wont disappear on small displays)
;
; Category: 3D, DISPLAY, Image Cube, Widget , Movie, X Windows
;
;-
; on_error,2		; return to caller
;
if xregistered('xstepper') then begin
;  because of common, only allowed 1 run/process
   message,/info,'XSTEPPER already running, returning'
   return
endif
; 
@xstepper.common	;define common block

mag_fact=1

butfont=def_font()

; setup common block start up definitions
;
; 
delta=1				;default direction = forward 
scale=n_elements(noscale) eq 0  ;set tvscl flag
;
; zoom=[flag,window,xcent,ycent,factor]
zoom=lonarr(5)			;
zoom(4)=4			; factor 4 startup
;
;
ss=size(cube)
case ss(0) of
   2: nimages=1 
   3: if n_elements(subscripts) eq 0 then nimages=ss(3) else $
	nimages=n_elements(subscripts)
   else: begin 
	    message,'Image or Image cube required'
         endelse
endcase
xs=ss(1)
ys=ss(2)

if n_elements(xsize) ne 0 then begin
   xs=xsize
   if n_elements(ysize) eq 0 then begin 
      ys=xsize/xs*xs
      ysize=ys
   endif else ys=ysize 
endif else begin
   xsize=xs
   ysize=ys
endelse


;
pixmap=lonarr(2,nimages)-1		;index/pixmap window
pixpnt=0
pixcnt=0
pixrate=50

ssmap=lonarr(nimages)-1
sspnt=0
sscnt=0
        
backopt=''				; background task option
dispopt=0 				; display data default option
minprog=0				; movie in progress? (no)
range=[0,nimages-1]
over_info=data_chk(info,/string)	; 
areverse=0				; default is wrap-around
last_title=''

; slf 30-oct-92 c
; kludge for old version of idl on SUN (flare1)
istemp=0
if !version.release eq '2.1.2' then scube=cube else begin
   if n_elements(subscripts) ne 0 then begin
      ssnew=ss      
      ssnew(3)=nimages
      scube=make_array(size=ssnew)
      for i=0,nimages-1 do scube(0,0,i)=cube(*,*,subscripts(i))
   endif else begin
      scube=cube
      istemp=1
   endelse
endelse
;
subs=indgen(nimages)
interpol=keyword_set(interp)
;
rebin = xsize ne ss(1) or ysize ne ss(2)
;
if n_elements(start) eq 0 then current=nimages $   ;image pointer
   else current=start-1
;
; info may be positional or keyword parameter
if n_elements(info) ne 0 then tinfo = info	   ; positional 
if keyword_set(info_array) then tinfo = info_array ; keyword
if n_elements(tinfo) eq 0 then tinfo = $
	strcompress('Frame Number: ' + sindgen(ss(3)))
sinfo=tinfo						; common blk
if n_elements(subscripts) ne 0 then sinfo=sinfo(subscripts)
;
if not keyword_set (title)  then title  = 'Xstepper'
;
nregions = n_elements(xsize)

; create nested structure to contain widet information
draw_str=make_str('{dummy, base:0L, label:0L, draw:0L}')
text_str=make_str('{dummy, base:0L, label:0L, text:0L}')
;
draw_str_name = tag_names(draw_str,/structure)
text_str_name = tag_names(text_str,/structure)
;
multi_draw_str='{dummy, top:0L, parent:0L, option:0L,' + 	$
                 'timerid:0l,'                         +        $
                 'id:"",number:n_elements(xsize), ' + 		$
	         'views:replicate({' + draw_str_name + '},' + 	$
		  string(n_elements(xsize))+ '),' +		$
                 'menubuts:lonarr(8),' +			$
		 'dispbuts:lonarr(3),'  +			$
		 'resetbuts:lonarr(2),' +			$
		 'cimgbuts:lonarr(4),'  +			$
		 'text:{' + text_str_name +  '}}'
multi_draw_str=make_str(multi_draw_str)
;
temp=draw_str
;
base=widget_base(/column,title=title)			; format as row
basea=widget_base(base,/row)

event_options= $
   ['QUIT','FWRD>>','<<BWRD','Movie','Freeze',$
	'AZoom-OFF','Wrap','XLOADCT']
if keyword_set (event_options) then begin 
   xmenu2, event_options, base, uvalue=indgen(n_elements(event_options)), $
	/frame,/row,buttons=buttons, font=butfont
endif
; desensitize a couple of items for now
widget_control,buttons(5),sensitive=0	;zoom
widget_control,buttons(4),sensitive=0	;freeze
;
; make sub-base containing current image disposition
cimgb=widget_base(base,/row,/frame)
xmenu2, ['HELP'], cimgb, /row, font=butfont
; cimglabl=widget_label(cimgb,value='  MOVE CURRENT IMAGE TO:')
cimg_options=$
   ['IMG->SS','IMG->PIX','DATA->PIX','SS->PIX']
xmenu2, cimg_options, cimgb, /row, buttons=cimgbuts,font=butfont
; menu of reset buttons
reset_options=$
   ['RST-SS','RST-PIX']
xmenu2, reset_options, cimgb,/row,buttons=resetbuts, font=butfont

; make sub-base containg display option menu
dispoptb=widget_base(base,/row,/frame)
displabl=widget_label(dispoptb,value='Display:',font=butfont)
display_options= $
   ['DATA', 'DATA(SS)', 'PIXMAP']
xmenu2, display_options,dispoptb,/row,/exclusive,buttons=dispbuts, $
	font=butfont
titleopt=widget_label(dispoptb,value='Title-Image:',font=butfont)
xmenu2,/row,/exclusive,font=butfont,['OFF'],dispoptb
;
rowsize=0
i=0		; only one draw widget
   basex = widget_base(base,/column,/frame)
;
;  set up text window for info array
   text_base=widget_base(basex,/column,/frame)
;   text_label=widget_label(text_base,value='Image Information')
   text = widget_text(text_base,ysize=2, $
	font=butfont, value=string(replicate(32b,40)), /scroll)
;
;  set up draw window for image display
;  draw window size
   wxs=max([256,xsize(i)])
   wys=max([256,ysize(i)])
spaces=string(replicate(32b,(wxs/32-(wxs/384*5)) ))
spaces=string(replicate(32b,wxs/32))
slide=widget_slider(basex,/suppres, $
;	title='<<<Slower' + spaces + ' FRAME RATE' + spaces + 'Faster>>>', $ 
	value=50,font=butfont)
slabel=widget_label(basex,/frame,font=butfont, $
   value='<<<Slower' + spaces + ' FRAME RATE' + spaces + 'Faster>>>')

   drawx = widget_draw(basex, /scroll, /button_events, /frame, $
			xsize=wxs, ysize=wys, x_scroll_size=wxs < 1024, $
 				y_scroll_size=wys<1024)
;

   temp.base=basex
;   temp.label=labelx
   temp.draw=drawx
   multi_draw_str.views(i)=temp
;
   multi_draw_str.text.base=text_base
;   multi_draw_str.text.label=text_label
   multi_draw_str.text.text=text
;
multi_draw_str.top = base
multi_draw_str.timerid=basea
multi_draw_str.number = nregions
multi_draw_str.menubuts=buttons
multi_draw_str.dispbuts=dispbuts
multi_draw_str.cimgbuts=cimgbuts
multi_draw_str.resetbuts=resetbuts
;
widget_control,base,/realize
widget_control, get_value=wind, drawx
curwind=wind
mapx,dispbuts,/map,/show,sens=[1,0,0]
widget_control, dispbuts(0), /set_button	; default=DATA
widget_control,base,set_uvalue=multi_draw_str	; save info
xstep_str=multi_draw_str
;
; display the firs image
update_image , /loud 
timerid=basea
xmanager,'xstepper_t',timerid,/just_reg,event_handler='xstepper_t_event'
xmanager,'xstepper',base
if istemp then cube=temporary(scube)

ssgood=where(ssmap ne -1,sscnt)
if sscnt gt 0 then ssout=ssmap(ssgood) else ssout=-1

return 
end

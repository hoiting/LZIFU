pro restsys, all=all, aplot=aplot, x=x, y=y, z=z, p=p, $
	order=order, more=more, c=c, map=map, init=init
;
;+
;   Name: restsys
;
;   Purpose: restore idl system variables using values saved via savesys.pro
;            (values from Yohkoh system variables:ys_idlsys_temp,ys_idlsys_init)
;
;   Input Keyword Parameters:
;      all -   if set, restore all (writeable) idl system variables 
;      aplot -  if set, restore all plot related variables (!x,!y,!z,!p)
;      x,y,z - if set, restore specified axis variable (!x, !y, and/or !z)
;      c,order,map,more - restore associated system variable(s)
;      init  - if set, restore specified variables to startup values
;
;   Calling Examples:
;      restsys,/x,/y             ; restore !x, !y (from !ys_idlsys_temp)
;      restsys,/p                ; save !p
;      restsys,/aplot            ; save !x,!y,!z,!p
;      restsys,/all              ; save above plus some others (!c, !map..)
;      restsys,/init,/all	 ; startup values (from !ys_idlsys_init)
;
;      Generally, a routine would use this routine paired with savesys.pro
;
;        pro junk,a,b,c
;        savesys,/aplot          ; save plot variables
;        <change !x,!y,!p>       ; routine plays with global variables
;        restsys,/aplot          ; restore plot values
;        return
;
;
;   Side Effects:
;      def_yssysv.pro is called if it has not been done already
;      
;   Common Blocks:
;      def_yssysv_blk	- determine if Yohkoh system variables are defined
;
;   History:
;      21-Apr-1993 (SLF)
;      22-apr-1993 (SLF) ; remove !more references
;
;- 
common def_yssysv_blk,called

if n_elements(called) eq 0 then def_yssysv	; define if not already done

;Handle keyword parameters:
; tempted to use execute for this but that limits function...

all=keyword_set(all)
plot=keyword_set(aplot) or all
x=keyword_set(x) or plot
y=keyword_set(y) or plot
z=keyword_set(z) or plot
p=keyword_set(p) or plot

c=keyword_set(c) or all
map=keyword_set(map) or all
more=keyword_set(more) or all
order=keyword_set(c) or all

if keyword_set(init) then ys_idlsys_temp=!ys_idlsys_init else $
    ys_idlsys_temp=!ys_idlsys_temp
   
; plot related
if x then !x=ys_idlsys_temp.!x
if y then !y=ys_idlsys_temp.!y
if z then !z=ys_idlsys_temp.!z
if p then !p=ys_idlsys_temp.!p

if c then     !c=ys_idlsys_temp.!c
; if more then  !more=ys_idlsys_temp.!more
if order then !order=ys_idlsys_temp.!order
if map then   !map=!ys_idlsys_temp.!map

; DEFAULT INHIBITED - no default 
if 1- (x or y or z or c or more or order or p or map or all) then $  
; restsys,/all,init=init
  message,/info,'No variable update - must use at least one keyword switch...'    

return
end

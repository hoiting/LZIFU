pro savesys, all=all, aplot=aplot, x=x, y=y, z=z, p=p, $
	order=order, c=c, map=map, more=more
;
;+
;   Name: savesys
;
;   Purpose: save idl system variables for later restoration via restsys
;            (variables saved in yohkoh system variable: !ys_idlsys_temp)
;
;   Input Keyword Parameters:
;      all -   if set, save all (writeable) idl system variables 
;      aplot -  if set, save all plot related variables (!x,!y,!z,!p)
;      x,y,z - if set, save specified axis variable (!x, !y, and/or !z)
;      c,order,map,more - save associated system variable(s)
;
;   Calling Examples:
;      savesys,/x,/y		; save !x, !y 
;      savesys,/p		; save !p
;      savesys,/aplot		; save !x,!y,!z,!p
;      savesys,/all		; save above plus some others (!c, !map..)
;   
;      Generally, a routine would use this routine paired with restsys.pro
;        pro junk,a,b,c
;        savesys,/aplot		; save plot variables
;        <change !x,!y,!p>	; routine plays with global variables
;        restsys,/aplot		; restore plot values
;        return		   
;
;   Side Effects:
;      def_yssysv.pro is called if it has not been done already to define
;      Yohkoh system variables
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

; plot related
if x then !ys_idlsys_temp.!x=!x
if y then !ys_idlsys_temp.!y=!y
if z then !ys_idlsys_temp.!z=!z
if p then !ys_idlsys_temp.!p=!p

if c then     !ys_idlsys_temp.!c=!c
; if more then  !ys_idlsys_temp.!more=!more
if order then !ys_idlsys_temp.!order=!order
if map then   !ys_idlsys_temp.!map=!map

; DEFAULT INHIBITED ... default to all (recurse)
if 1-(x or y or z or c or p or more or order or map or all) then $ ;savesys,/all
  message,/info,'No variable saved - must use at least one keyword switch..'

return
end

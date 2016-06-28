pro clearplot, dummy
;
;+
;NAME:
;	clearplot
;PURPOSE:
;	To clear the IDL plotting parameters
;HISTORY:
;	Written Sep-91 by M.Morrison
;	 3-Mar-92 (MDM) - Added !x.margin and !y.margin and
;			  !p.title
;-
;
!p.multi	= 0
!p.region	= 0
!p.position	= 0
!p.charsize	= 0
!p.title	= ' '
;
!x.range	= 0		& !y.range	= 0
!x.title	= ' '		& !y.title	= ' '
!x.style	= 0		& !y.style	= 0
!x.ticks	= 0		& !y.ticks	= 0
!x.type		= 0		& !y.type	= 0
!x.tickname	= ''		& !y.tickname	= ''
!x.tickv	= 0		& !y.tickv	= 0
!x.charsize	= 0		& !y.charsize	= 0
!x.margin	= [10,3]	& !y.margin	= [4,2]
;
!linetype	= 0
!psym		= 0
!type		= 0
!noeras		= 0
;
;
end

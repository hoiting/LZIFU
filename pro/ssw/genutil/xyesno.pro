pro xyesno, str, ans, tit=tit, group=group
;+
;NAME:
;	xyesno
;PURPOSE:
;	Provide a yes/no question in widget form
;	A widget replacement for YESNOX
;SAMPLE CALLING SEQEUENCE:
;	xyesno,'Please answer this question',ans
;	xyesno, question, ans
;INPUT:
;	question - string array with the text of the question
;OUTPUT:
;	ans	- 0=no, 1=yes
;HISTORY:
;	Written 28-Jan-97 by M.Morrison
;-
;
if (n_elements(tit) eq 0) then tit = 'XYESNO'
;
;
ans0 = xmenu_gen_but(['Yes', 'No'], instructions=str, group=group)
ans = ans0 eq 'YES'
;
end
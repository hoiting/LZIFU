;+
; Project     : SOHO - CDS     
;                   
; Name        : FILL_CATEGORY
;               
; Purpose     : Load save file with current categories 
;               
; Explanation : Uses the CATEGORY routine to create a list of
;               relevant names and categories and then stores then in
;               $CDS_INFO/categories.save for later retrieval by TFTD with
;               the CAT keyword.
;               
; Use         : IDL>  fill_category [,/prog]
;    
; Inputs      : None 
;               
; Opt. Inputs : None
;               
; Outputs     : Save file created in /cs
;               
; Opt. Outputs: None
;               
; Keywords    : PROG - if present fill tables for 'programmers' routines.
;
; Calls       : PURPOSE
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, help
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 20-Sep-94 
;               
; Modified    : Use write version of env. variable. CDP, 20-Oct-95
;
; Version     : Version 2, 20-Oct-95
;-           
 
pro fill_category, prog=prog

;
;  check evar is set
;
if getenv('CDS_INFO_W') eq '' then begin
   bell
   print,'$CDS_INFO_W is not defined.'
   return
endif


if not keyword_set(prog) then begin

;
;  create string lists from specific directories
;
   print,'Loading util directories'
   category,list=util,path='util',/quiet

   print,'Loading database directory'
   category,list=db,path='database',/quiet

   print,'Loading doc directories'
   category,list=doc,path='doc',/quiet
   
   print,'Loading userlib directories'
   category,list=userlib,path='userlib',/quiet
   
   print,'Loading statlib directories'
   category,list=statlib,path='statlib',/quiet
   
   print,'Loading widgets directories'
   category,list=widgets,path='widgets',/quiet
   
   print,'Loading structure interface directory'
   category,list=inter,path='interface',/quiet
   
   print,'Loading ql_disp directory'
   category,list=qldisp,path='ql_disp',/quiet
   
   print,'Loading data_handling/soho/cds directory'
   category,list=gtfunc,path='/data_handling/soho/cds',/quiet
   
   
;
; concatenate them into single array
; (certain favoured ones are given double weight)
;
   catlist = [widgets,inter,util,db,doc,$
            qldisp,gtfunc,userlib,util,inter,doc,statlib]

;
;  save in place where TFTD will pick them up
;

   save,catlist,file=concat_dir('$CDS_INFO_W','category_user.save')

;
;  programmers library only
;
endif else begin

   print,'Adding programmer routines.'
   category,list=cal,path='cal',/quiet
   category,list=da,path='data_anal',/quiet
   category,list=dh,path='data_handling',/quiet
   category,list=plan,path='plan',/quiet
   
;
; concatenate them into single array
;
   catlist = [cal,da,dh,plan]

;
;  save in place where TFTD will pick them up
;
   save,catlist,file=concat_dir('$CDS_INFO_W','category_prog.save')

endelse

end

;+
; Project     : SOHO - CDS     
;                   
; Name        : FILL_TFTD
;               
; Purpose     : Load save file with current one-liners 
;               
; Explanation : Uses the PURPOSE routine to create a list of
;               relevant one-liners and then stores then in
;               $CDS_INFO/1liners.save for later retrieval by TFTD.
;               
; Use         : IDL>  fill_tftd [,/prog]
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
; Written     : C D Pike, RAL, 13-May-94 
;               
; Modified    : Change storage directory of save file, CDP, 20-May-1994
;               To include list of intrinsic routines. CDP, 25-May-95
;               Add PROG keyword.  CDP, 13-Jun-94
;               Take account of new directory structure. CDP, 21-Jun-94
;               Add database directories.  CDP, 22-Jul-94
;               Add ql_disp directory to user lists. CDP, 14-Sep-94
;               Added specific routines in the planning
;               directories.   CDP, 11-Jan-95
;               Add wavelength calibration routines.  CDP, 30-Jan-95
;               Add user telemetry calibration programs.  CDP, 3-Feb-95
;               Add /xdr to save file.  CDP, 3-Apr-95
;               Add further telemetry programs.  CDP, 18-Jun-95
;               Add Dere spectral synthesis.  CDP, 14-Jul-95
;               Use write version of env. variable.  CDP, 20-Oct-95
;               Added /cs/update directory.  CDP, 28-Jun-96
;               Added demo engineering directory.  CDP, 26-Jul-96
;               Added intensity calib directory.   CDP, 22-Aug-96
;               Added all CHIANTI directory routines.  CDP, 10-Jun-97
;
; Version     : Version 18, 10-Jun-97
;-           
 
pro fill_tftd, prog=prog

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
   print,'Loading update directory'
   purpose,list=update,path='update',/quiet

   print,'Loading util directories'
   purpose,list=util,path='util',/quiet

   print,'Loading database directory'
   purpose,list=db,path='database',/quiet

   print,'Loading doc directories'
   purpose,list=doc,path='doc',/quiet
   
   print,'Loading userlib directories'
   purpose,list=userlib,path='userlib',/quiet
   
   print,'Loading statlib directories'
   purpose,list=statlib,path='statlib',/quiet
   
   print,'Loading widgets directories'
   purpose,list=widgets,path='widgets',/quiet
   
   print,'Loading structure interface directory'
   purpose,list=inter,path='interface',/quiet
   
   print,'Loading ql_disp directory'
   purpose,list=qldisp,path='ql_disp',/quiet
   
   print,'Loading data_handling/soho/cds directory'
   purpose,list=gtfunc,path='/data_handling/soho/cds',/quiet
   
   print,'Loading wavelength calibration directory'
   purpose,list=wave,path='/wave',/quiet

   print,'Loading demo directory'
   purpose,list=demo,path='/sci/engineering',/quiet

   print,'Loading telemetry monitoring directory'
   purpose,'emon*',  list=emon1,path='/engineering',/quiet
   purpose,'*calib*',list=emon2,path='/engineering',/quiet
   purpose,'*tm*',   list=emon3,path='/engineering',/quiet
   purpose,'tlm*',   list=emon4,path='/engineering',/quiet
   purpose,'where*', list=emon5,path='/engineering',/quiet
   purpose,'show*',  list=emon6,path='/engineering',/quiet
   purpose,'gt_*',   list=emon7,path='/engineering',/quiet
   
   print,'Adding intrinsic routines.'
   restore,concat_dir('$CDS_INFO_W','intrinsic.save')

   print,'Adding special planning routines.'
   purpose, list=p1, 'mk_raster', path='plan', /quiet
   purpose, list=p2, 'mk_study',  path='plan', /quiet
   purpose, list=p3, 'mk_plan',   path='plan', /quiet
   purpose, list=p4, 'mk_detail', path='plan', /quiet
   purpose, list=p5, 'vds_dummy', path='plan', /quiet
   purpose, list=p6, 'gis_dummy', path='plan', /quiet
   purpose, list=p7, 'xshow_study', path='plan', /quiet

   print,'Adding special FITS routines.'
   purpose, list=f1, 'cds*', path='i_o/fits/cds', /quiet
   purpose, list=f2, 'readcdsfits',  path='i_o/fits/cds', /quiet

   print,'Adding special STM routines.'
   purpose, list=f3, 'stm', path='egse/ops', /quiet
   purpose, list=f4, 'show*',  path='egse/ops', /quiet

   print,'Adding CHIANTI routines.'
   purpose, list=f5, path='data_anal/spec_syn', /quiet
   
   print,'Adding intensity cal routines.'
   purpose, list=f6, path='inten', /quiet
   
;
; concatenate them into single array          
; (certain favoured ones are given double weight)
;
   mlist = [widgets,inter,util,db,wave,doc,intrinsic,p1,p2,p3,p4,p5,p6,p7,$
            f1,f2,f3,f4,f5,f6,qldisp,gtfunc,userlib,emon1,emon2,emon3,$
            emon4,emon5,emon6,emon7,util,demo,update,inter,doc,statlib]

;
;  save in place where TFTD will pick them up
;
   save,/xdr,mlist,file=concat_dir('$CDS_INFO_W','1liners_user.save')

;
;  programmers library only
;
endif else begin

   print,'Adding programmer routines.'
   purpose,list=cal,path='cal',/quiet
   purpose,list=da,path='data_anal',/quiet
   purpose,list=dh,path='data_handling',/quiet
   purpose,list=plan,path='plan',/quiet
   
;
; concatenate them into single array
;
   mlist = [cal,da,dh,plan]

;
;  save in place where TFTD will pick them up
;
   save,/xdr,mlist,file=concat_dir('$CDS_INFO_W','1liners_prog.save')

endelse

end

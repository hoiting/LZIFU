pro savegen,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
      		file=file, xdr=xdr, notype=notype , names=names,   $ 
		text=text, replace=replace, struct=struct
;+
;   Name savegen   
; 
;   Purpose: save user specified parameters (idl variables) in a generic file
;	     [front end to wrt_genx - files are restored via savegen.pro]
;
;   Input Parameters:
;      p1, p2, p3... p15 - idl variables to save
;
;   Optional Keyword Parameters
;      file - file name for save - default is 'save.genx' in current direct
;             if name is supplied and notype keyword is not set, the
;	      actual file name used will have .genx appended
;      names - strarr or delimited string containg saved variable names - 
;	       number elements in array (or expanded array) should equal
;	       the number of input parameters - Use to document saved names
;      text -  string or string array describing file (for user internal 
;	       documentation)
;      notype - if set, inhibits default file type assignment
;		by default, filename=file+'.gen' for  non xdr and
;			    filename=file+'.genx' for xdr format
;      replace - [note: version 1.0 replace is default]
;      xdr  -    [note: version 1.0 and greater is always xdr]
;
;   Calling Sequence:
;      savegen,v1 [,v2, v3..., v15, name=name, file=file, text=text]
;								  
;   Calling Examples:						[file name]

;      savegen, spectra , times, file='spec_01'			'spec_01.genx'

;      savegen, temp, EM, index(3:4), text=info_array(3:4),  $  'save.genx'
;	  names=['temp', 'EM']

;      savegen, pimage,infil,ss, file='sxt_kp', 	     $  'sxt_kp.genx'
;		text=['SXT:KP Mag Overlay',info_array(4:5)], $
;      
;   History: 
;       30-oct-91 - SLF (originally for Calibration files)
;	8-Nov-91  - MDM Expanded from 10 to 15 parameters
;	15-Apr-93 - SLF   file name updates (dont clobber input)
;       16-Mar-93 - SLF - add struct input keyword
;	24-Mar-93 - SLF - update documentation and 'unclutter'
;	30-Mar-93 - SLF - error check positional paramter(0)
;       31-Mar-93 - SLF - allow names keyword to be delimited string
;			  some documentation upgrades
;
;
;   Hints - if you intend on keeping a file around, it pays to include 
;     internal documentation which will jog your memory later.  The simplest 
;     method is to supply a string or string array via the TEXT keyword.  
;     You could save additional documentation via additional input paramters.
;     For example, if you journal your idl session while creating a final
;     data product, you could pass that in as internal documentation.
;     For this, you could use the generic text reader <rd_tfile.pro> to
;     transform the journal file to a string array - this could then
;     be passed in as a positional parameter (or via keyword TEXT)
;     For example, the following call might save an image, an index record,
;     reformated file info, and the journal file used during image creation:
;
;     savegen, fltimage, index, fileid, rd_tfile('idlsave.pro'), $
;	   text='Nobel Candidate', file='apj_fig1'
;
;     An additional level of internal documentation is available through
;     the use of the NAMES keyword - you should use this if you desire to
;     retain the actual names used in the call to savegen.  
;     EX: (may use X-cut and paste of call sequence)
;     savegen,index,data,info_array,names='index,data,info_array'
;             |-------cut---------|        |----- paste -------|
;
;     Use of savegen/restgen pair (simple example):
;     savegen,v1,v2,v3		; saves user variables v1,v2,v3 in 'save.genx'
;     restgen,a,b,c 		; restores them (now named a,b,c)
;
;     To verify your file after writing, use restgen inquire option:
;     restgen,/inquire [,/nodata] ; displays summary of 'save.genx' contents
;     
;-
; determine tag names for super structure
;
; slf 31-mar-1993, allow delimited string for names 
if n_elements(names) eq 1 then names=str2arr(names)

if not keyword_set(names) and not keyword_set(struct) then $
   names=strcompress('savegen' + sindgen(n_params()),/remove_all)

; slf, 16-mar-1993 - allow struct keyword input
case 1 of

   keyword_set(struct): begin			; structure input, use as is
      sstruct=size(struct)

      case sstruct(2) of
         8: begin				; but do some parameter checking
               case 1 of
                  n_params() ne 0: $
                     message,/info, $
		       "Can't specify both a positional parameter & STRUCT keyword"
		  sstruct(0) ne 1 or sstruct(3) ne 1: $
                     message,/info,"Input Keyword Parameter STRUCT " + $
			"must be a scaler structure"                
		  else: structure=struct
               endcase
            endcase
         else: message,/info,"STRUCT keyword input must be a structure!"
      endcase 
   endcase
;  if struct not supplied, the generic super structure is built via buildgen
   else: begin
      if n_elements(p0) eq 0 then $
         message,/info,'First positional parameter is undefined' else $
	 structure= $	; 	(not keyword_set(struct))
      buildgen(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, names=names)
   endcase
endcase		; end case 1 (everything)

if n_elements(structure) eq 0 then begin
   message,/info,'Problem with input, returning...'
   return
endif
;
; now write generic file
; *** hard coded for xdr and replace (careful) 
;
; determine file name
ftype=['.gen','.genx']				; default extentions
if not keyword_set(file) then file='save'	; default file name
fileout=file
; force xdr name convention via (or 1) - dont append extention if already
; specified by user
if not keyword_set(notype) and strpos(fileout,'.gen') lt 0 then begin
   fileout=fileout + ftype(keyword_set(xdr)or 1)
   message,/info,'Writing generic file with name: ' + fileout
endif 
;
; wrt_genx (and called routines) does the 'real' work
wrt_genx,fileout,structure,/xdr,text=text,/replace 
;
return
end

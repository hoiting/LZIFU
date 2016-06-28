;+
; Project     : SOHO - CDS
;
; Name        : MK_TEMP_FILE
;
; Purpose     : Create a temporary filename
;
; Category    : Utility
;
; Syntax      : IDL> file=mk_temp_file()
;
; Inputs      : FILE = file name [def='temp.dat']
;
; Opt. Inputs : None
;
; Outputs     : NAME = file name with added path
;
; Keywords    : RANDOM - prepend a random set of digits to force uniqueness
;               DIREC (input) - specified directory location of temp file 
;               PATH (output) - actual directory location of temp file
;
; History     : Version 1,  25-May-1997,  D.M. Zarro.  Written
;               17 April 2000, Zarro (SM&A/GSFC) - added DIREC keyword
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function mk_temp_file,file,path=path,random=random,directory=directory

if is_blank(file) then file='temp.dat'

break_file,file(0),fdsk,fdir,fname,fext

fpath=trim(fdsk+fdir)

cd,curr=curr
home=getenv('HOME')
tmp=get_temp_dir()

;-- determine directory location of temporary file based on
;   write access

name=trim(fname+fext)
if is_string(directory) then begin
 case 1 of 
  write_dir(directory,/quiet,out=opath): path=opath
  write_dir(fpath,/quiet,out=opath): path=opath
  write_dir(curr,/quiet,out=opath): path=opath
  write_dir(home,/quiet,out=opath): path=opath
  else: path=tmp
 endcase
 rfile=concat_dir(path,name)
endif else rfile=name

if keyword_set(random) then begin
 break_file,rfile,rdsk,rdir,rname,rext
 rid='r'+get_rid()
 rfile=concat_dir(rdsk+rdir,rid+rname+rext)
endif

return,trim(rfile)
     
end


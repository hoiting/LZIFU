pro main_execute, filename, text=text, helpme=helpme
;+
;   Name: main_execute
;
;   Purpose: execute idl 'command' file (in IDL_STARTUP format)
;
;   Input Paramters:
;      filename - file containing idl startup commands
;   Keyword Parameters:
;      text     - text array already processed by rd_tfile(/compr,nocomm=';')
;
;   History:
;      slf -  5-feb-1993 - allow chaining of multiple IDL_STARTUP files
;      slf - 30-mar-1993 - return to caller on error
;      slf - 21-apr-1993 - trap executive commands (.run, .size, etc)
;      ras -  8-jul-1996 - take text array instead of file 
;      ras - 19-jul-1996 - recursively traps and uses @file[.pro] 
;   Restrictions:
;      filename contents must conform to IDL_STARTUP format
;      Cannot execute idl executive commands (TBD)
;      Uses execute function so no recursion allowed - multiple line block
;      commands are limited to total string length of 512 (execute limit)
;-
;
on_error,2
helpme=keyword_set(helpme)
;
; read the startup file (remove comments, whitespace, be quiet)
if data_chk(text,/string) then statements=text else $
	statements=rd_tfile(filename,/quiet,/comp,nocomment=';') 
; RAS, 19-jul-1996, trap "@" statements, include their text
inclcmds = where( strpos(statements,'@') eq 0, inc_count)
if inc_count ge 1 then bpath = break_path(!path)
while inc_count gt 0 do begin
  inc_file1= strmid(statements(inclcmds(0)),1,200)
  break_file, inc_file1, disk, dir, inc_filenam, ext, fversion, node
  if ext eq '' then ext = '.pro'
  inc_file1 = node + disk + dir + inc_filenam + ext + fversion
  inc_file= loc_file(inc_file1, path=bpath)
  more_statements = rd_tfile(inc_file,/quiet,/comp,nocomment=';')  
  if inclcmds(0) eq 0 then start_blk = '' else start_blk=statements(0:inclcmds(0)-1)
  if inclcmds(0) eq (n_elements(statements)-1) then end_blk = '' else $
	end_blk=statements(inclcmds(0)+1:*)
  statements = [start_blk, more_statements, end_blk]
  wstatements = where( statements ne '', nstatements)
  if nstatements ge 1 then statements=statements(wstatements) else statements=''
  inclcmds = where( strpos(statements,'@') eq 0, inc_count)
endwhile
;
; slf, 21-apr-1993 trap and don't execute executive commands
execmds=where(strpos(statements,'.') eq 0,ecount)
if ecount gt 0 then begin
   if helpme then begin
      print,"Can't execute following commands in file: <" + filename + ">"
      print,'   ' + statements(execmds), format='(a)'
   endif
   valid=where(strpos(statements,'.') ne 0,vcount)
   if vcount gt 0 then statements=statements(valid) else statements = ''
endif
      
;

if statements(0) ne '' then begin		; file has some statements
   nstatements=n_elements(statements)
   state=0
;  for each statement.
   while state lt nstatements do begin
      exestate=statements(state)
;     for each continuation line, merge into one executable string
;     (single line commands bypass the next while loop
;      while strpos(statements(state),'& $') ne -1 do begin
       exestate=statements(state)
       slen=strlen(exestate)
       while strmid(exestate,slen-1,1) eq '$' do begin
         state=state+1
         exestate=strmid(exestate,0,slen-2) + statements(state) 
         slen=strlen(exestate)
      endwhile
;
;     commmand is ready, so execute it
      if helpme then print,'Execute: ' + exestate
      exestat=execute(exestate)
      state=state+1
   endwhile      
endif

return
end

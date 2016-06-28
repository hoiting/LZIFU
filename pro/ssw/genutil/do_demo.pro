pro do_demo, demofile, pause=pause, wait=wait
;+
;   Name: do_demo
;
;   Purpose: run an idl demo program (format can be IDL main routine)
;
;   Input Parameters:
;      demofile - name of file to demo (execute) - if none, menu select from
;                 files in $DIR_GEN_DOC with names: XXXdemo.pro
;
;   Keyword Parameters:
;      pause - if set, pause after IDL statement execution until user <CR>s
;      wait  - if set, number of seconds to wait between each line
;
;   Calling Sequence:
;      do_demo [,demofile]
;
;   Non comment lines in demofile are displayed with highlights to terminal
;   and then executed - comment lines are echoed
;
;   History:
;      10-Jan-1995 (SLF)
;
;   Restrictions:
;      single line IDL commands for now
;-
if keyword_set(wait) then iwait=wait else iwait=0.
pause=keyword_set(pause)

if n_elements(demofile) eq 0 then begin
   demofiles=file_list('$DIR_GEN_DOC','*demo.pro')
   case 1 of 
      demofiles(0) eq '': begin
         tbeep
         message,/info,"Can't find any demo files and none supplied, returning..."
         return
      endcase
      n_elements(demofiles) gt 1: begin
         tbeep
         message,/info,"Select a demo file..."
         ss=wmenu_sel(demofiles,/one)
         if ss(0) eq -1 then message,"Nothing selected, Aborting..."
         demofile=demofiles(ss)
      endcase
      else: demofile=demofiles(0)
   endcase
endif

if not file_exist(demofile) then begin
   tbeep
   message,/info,"Demo file: " + demofile + " not found, returning..."
   return
endif

input=rd_tfile(demofile(0),/compress)

line="--------------------------------------------------------"
prstr,["","Executing Demo File: " + demofile,line,""]
qtemp=!quiet
!quiet=1		; shut off compilation messages
resp=''
for i=0,n_elements(input) -1 do begin
   case 1 of 
      input(i) eq 'end':
      strlen(input(i)) le 1: print
      strmid(input(i),0,1) eq ';': prstr,[strmid(input(i),1,1000)]
      else: begin
         prstr,strjustify(["","IDL> " + input(i),""],/box)
         exestat=execute(input(i))      
         lastcom=0
         if pause then begin
            print
            read,"Enter <CR> to continue, anything else to quit: ",resp
            if resp ne "" then message,"Aborting on request..."
         endif    
      endcase
   endcase
   wait,iwait
endfor

!quiet=qtemp
tbeep
prstr,["","End of Demo..."]
return 
end

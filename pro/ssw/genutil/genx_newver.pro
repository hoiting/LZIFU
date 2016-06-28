pro genx_newver, filename, newname, newtext=newtext, verbose=verbose
;
;+ 
;   Name: genx_newver
;
;   Purpose: create new version of genx file - only updates genx header
;	     and (optionally) text sections - original data is preserved
;
;   Input Paramters:
;      filename - file to convert (assume genx)
;      newname  - name for new file (defaults to filename , ie replace orig)
;
;   Keyword Paramters:
;      newtext - optional string / strarray to append to existing text section
;      verbose - if set, print some informational information
;
;   Calling Sequence:
;      genx_newver,filename		; replace existing file 
;      genx_newver,filename, newname    ; make new file
;
;   History - slf, 29-jan-1993		; 
;-
verbose=keyword_set(verbose)

restgen,file=filename,a,b,c,d,e,f,g,h,i,j,k,l,m,n,0,struct=struct, $ 
	text=text, head=head, /quiet
uptext=text
namet=tag_names(struct)
if n_elements(newtext) gt 0 then uptext=[uptext,newtext]
if n_elements(newname) eq 0 then newname=filename
if verbose then begin
    print,'Existing File: ' + filename
    help,head,/str
    message,/info,'Writing new file...'
endif
savegen,file=newname, a,b,c,d,e,f,g,h,i,j,k,l,m,n,0, text=uptext, names=namet
restgen,file=newname,a,b,c,d,e,f,g,h,i,j,k,l,m,n,0, struct=newstruct, $
	text=rdtext, head=rdhead, /quiet

if verbose then begin
    print
    print,'Updated  File: ' + newname
    help,rdhead,/str
    if n_elements(text) eq n_elements(rdtext) then begin
       if text(0) ne rdtext(0) then $
          prstr,['TEXT Changed','Old...',text(0),'New...',rdtext(0)]
    endif else begin
          print,'TEXT section was Updated'
	  prstr,rdtext
    endelse
endif

if str_diff(struct,newstruct) then begin
   tbeep
   message,/info,'Problem with file compare...
endif else begin
   message,/info,'Succesful update verified'
endelse

return
end

function next_window, free=free, user=user, string=string, label=label
;
;+
;   Name: next_window
;
;   Purpose: return next available window number, so they can be known in advance
;            (one use is to allow window Title which include this# prior to window creation)
;
;   Calling Sequence:
;      wind=next_window( [/free, /user] )
;
;   Calling Examples:
;      wind=next_window(/free)			; IDL will use this for next /free
;      wind=next_window(/user)			; next explicit avail (0-31)
;
;      wdef,zz,512,512,title='My Title' + next_window(/free,/label)
;      (create a window with defined title which includes window number for info)
;      
;   History:
;      7-oct-1994 (SLF)
;
;   Restrictions:
;-

user=keyword_set(user)
free=keyword_set(free) or 1-(keyword_set(user))

device,window=ws
ws=[ws,intarr(100)]			; simplfy logic via extension 
freeu=where(ws(0:31) eq 0,fcnt)
nextwin=freeu(0)

case 1 of
   keyword_set(free): nextwin=( where( ws(32:*) eq 0))(0) + 32

   keyword_set(user): if fcnt eq 0 then $
      message,/info,"No free user windows (range:0-31)  are available..."
endcase

label=keyword_set(label)
string=keyword_set(string) or keyword_set(label)

if string then nextwin=strtrim(nextwin,2)
if label then nextwin='(# ' + nextwin + ')'

return,nextwin
end

function str_is, test
;
;+ 
;   Name: str_is
;
;   Purpose: boolean function - is input a structure or structure array?
;
;   Input:
;      test - data structure to test
;
;   Output:
;      function returns: 1 if test is structure
;			 0 if test is not a structure
;
;-
return,n_tags(test) gt 0
end

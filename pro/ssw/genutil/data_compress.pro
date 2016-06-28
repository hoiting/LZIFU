function data_compress, data, decomp=decomp, qdebug=qdebug, $ 
                        type_comp=type_comp, t_comp=t_comp 
;
;+
;NAME:
;	data_compress
;
;PURPOSE:
;	Compress and decompress data using UNIX compress or gzip by
;	writing a temporary file.
;INPUT:
;	data	  - uncompressed data (unless /DECOMP is set in which
;		    case it is the compressed data)
;OPTIONAL KEYWORD INPUT:
;	decomp	  - If set, then the input is compressed data and decompression
;		    is supposed to be performed.
;       type_comp - Indicates type of compression.    1=>gzip, 2=>Unix Compress
;          t_comp - indicates type of decompression.  1=>gzip, 2=>Unix Compress
;
;METHOD:
;	A file must be created in a temporary directory to be decompressed/
;	compressed.  The following logic is used to figure out which 
;	directory to use:
;		1. If $DIR_GEN_DECOMP is defined and has enough space
;		2. If $DIR_GBO_TEMP is defined and has enough space
;		3. If $HOME has enough space
;		4. The current default directory
;		5. If /tmp has enough space
;HISTORY:
;	Written 7-Mar-95 by M.Morrison 
;       t_comp, type_comp added 11-Dec-97 by PGS      
;-
;
common data_compress_blk2, qfirst_time, last_dir_list, write_arr
;
qdebug = keyword_set(qdebug)
nbytes = get_nbytes(data)
IF (keyword_set(type_comp) EQ 0) THEN type_comp=1
;
;---------------------------- Determine the temporary directory location ----------------
;
;
;
start_time = systime(1)
dir_list = [get_logenv('DIR_GEN_DECOMP'), $
		get_logenv('DIR_GBO_TEMP'), $
		get_logenv('HOME'), $
		curdir(), $
		'/tmp']
;
qfigure = 1
if (keyword_set(last_dir_list)) then qfigure = total( byte(dir_list) - byte(last_dir_list) ) ne 0
if (qfigure) then begin
    if (keyword_set(qdebug)) then print, 'DATA_COMPRESS: Figuring Write Access'
    write_arr = bytarr(n_elements(dir_list))
    for i=0,n_elements(dir_list)-1 do if (dir_list(i) ne '') then write_arr(i) = write_access(dir_list(i))
end
last_dir_list = dir_list
;
idir = -1
qdone = 0
while not qdone do begin
    idir = idir + 1
    outdir = dir_list(idir)
    if (outdir ne '') then begin
	if (keyword_set(decomp)) then need = get_nbytes(decomp)*2.5 else need = get_nbytes(data)*2.5
	free = diskfree(outdir) * 1e+6
	;qwritable = write_access(outdir)
	qwritable = write_arr(idir)
	if (qwritable and (free gt need)) then qdone = 1
	if (keyword_set(qdebug)) then print, outdir, need, free, qwritable
    end
    if (idir ge n_elements(dir_list)) then begin
	print, 'RDWRT_COMP: Cannot figure out where to write a temporary file.  Stopping...'
	stop
    end
end
if (keyword_set(qdebug)) then print, 'RDWRT_COMP: Temporary directory ' + outdir
;
if (n_elements(qfirst_time) eq 0) then begin	;do some cleanup if necessary
     temp_file = concat_dir(outdir, 'rdwrt_temp_' + get_logenv('USER') + '*')
     if (keyword_set(qdebug)) then print, 'RDWRT_COMP: Deleting old files: ' + temp_file
     file_delete, temp_file
     qfirst_time = 0
end
;
filnam = 'rdwrt_temp_' + get_logenv('USER') + '_' + strtrim(long(systime(1)) mod 1000000, 2)
temp_file = concat_dir(outdir, filnam)
;
if (keyword_set(qdebug)) then print, 'Finding temp dir took', systime(1)-start_time
;
;---------------------------- Do the compression/decompression work ----------------
;
IF (keyword_set(t_comp) EQ 0) THEN t_comp = 1; ask greg about this
    tsuffix = ['','.Z','.gz']                                  ;PGS 
if (keyword_set(decomp)) then begin
    out = decomp
    ;
    openw, lun2, temp_file + tsuffix(t_comp), /get_lun;write out comp data
    writeu, lun2, data
    close, lun2
    openw, lun2, temp_file + tsuffix(t_comp), /append;write out comp data
    writeu, lun2, bytarr(1000)
    close, lun2

    free_lun, lun2
    ;
    file_uncompress,temp_file +tsuffix(t_comp) ;(was +'.Z',PGS) uncompress the data
    openr, lun2,temp_file,/get_lun
    rdwrt, 'R', lun2, 0, 0, out					;read the uncompressed data
    free_lun, lun2
end else begin
    openw, lun3, temp_file, /get_lun				;write uncompressed data
    writeu, lun3, data
    close, lun3
    ;
    file_compress, temp_file, type_comp=type_comp; compress the data; 
    ;
    openr, lun3, temp_file+tsuffix(type_comp)					;read the compressed data
    nbyte_comp = file_stat(temp_file+tsuffix(type_comp), /size)
    out = bytarr(nbyte_comp)
    readu, lun3, out
    free_lun, lun3
end
;
file_delete, temp_file + '*'
return, out
end

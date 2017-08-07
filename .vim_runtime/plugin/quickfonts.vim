" Description: plugin for quickly switching between a list of favorite fonts
" Last Change: $Date: 2005/03/30 20:16:07 $
" Version:     $Revision: 1.29 $
" Maintainer:  T Scott Urban <tsurban@HORMELcomcast.net>
"	             (remove HORMEL from my email first)
"
" For full user info, see quickfonts.txt
" Key user info:
"
" Overview:
"   This plugin manages a list of favorite fonts, and allows you to swich
"   quickly between those fonts
"
" Globals Config Variables:  read-only unless noted, only used on startup
"   g:quickFontsFile         - file to use to read and save font info
"   g:quickFontsNoMappings   - disable default mappings
"   g:quickFontsNoMenu       - disable menu creation
"   g:quickFontsBaseMenu     - use to put QuickFontSet in another menu
"   g:quickFontsNoXwininfo   - disable calling xininfo (for unix)
"   g:quickFontsAutoLoad     - auto load last used font on gui startup
"   g:quickfonts_loaded      - used to avoid multiple loading (read-write)
"
" Commands:
"   :QuickFontInfo              - display info about font list
"   :QuickFontAdd [*|font_name] - add a font to the list
"   :QuickFontDel [num]         - delete a font from the list
"   :QuickFontBigger            - switch to next bigger font in list
"   :QuickFontSmaller           - switch to next smaller font in list
"   :QuickFontSet <num>         - switch to specified font in list
"   :QuickFontReload            - reload list fron list file
"
" Mappings: disable (and do your own) with g:quickFontsNoMappings
"   Alt>                        - QuickFontBigger
"   Alt<                        - QuickFontSmaller
"
" Menus: most functionality in menus unless g:quickFontsNoMenu is defined
"
" Other:
"   fonts are read from the font file at vim start
"   fonts are written to the font file at vim exit
"
" TODO:
"

" protect from multiple sourcing, but allow it for devel
if exists("quickfonts_loaded") && ! exists ("quickfonts_debug")
	finish
endif
let quickfonts_loaded = 1

""" global script variables
" s:auto         - whether to autoload last used font
" s:file         - file for storing fonts
" s:fna          - font name array, used s:fna{i}
" s:fnum         - number of fonts in list
" s:fsa          - font size array, used s:fsa{i}
" s:save         - whether font list has changed, flag to save one exit
" s:maps         - whether we should create mappings
" s:menu         - whether we should create/update menus
" s:mbas         - basename for menus
" s:mdep         - menu priority string prefix - account for variable depth
" s:xwin         - whether we should use `xwininfo` for geometry
" s:scpo         - to restore settings
" s:selfont      - selected font index
" s:var_{key}    - font file settings
" s:winsys       - type of system we'll be dealing with


""" save settings
let s:scpo = &cpo | set cpo&vim

""" determine system type
if has("unix")
	let s:winsys = "Xwindows"
elseif has ("gui_win32") || has ("gui_win32s")
	let s:winsys = "Windows"
else
	let s:winsys "Unknown"
endif

""" temporaries
let tfileWindows  = $HOME . "/_vimquickfonts"
let tfileXwindows = $HOME . "/.vimquickfonts"
let tfileUnknown  = $HOME . "/.vimquickfonts"

""" config from global variables
let s:file = (exists ("g:quickFontsFile") ? g:quickFontsFile : tfile{s:winsys})
let s:maps = (exists ("g:quickFontsNoMappings") ? 0 : 1)
let s:menu = (exists ("g:quickFontsNoMenu") ? 0 : 1)
let s:mbas = (exists ("g:quickFontsBaseMenu") ? g:quickFontsBaseMenu : '')
let s:xwin = (exists ("g:quickFontsNoXwininfo") ? 0 : 1)
let s:auto = (exists ("g:quickFontsAutoLoad") ? 1 : 0)

""" makw sure that if the menu base is specified, it ends with a period
if strlen (s:mbas) > 0 && strpart (s:mbas, strlen (s:mbas) - 1) != '.'
	let s:mbas = s:mbas . '.'
endif

let s:mdep = '.'

let ix = match (s:mbas, '\.')
while ix != -1
	let s:mdep = s:mdep . '.'
	let ix = match (s:mbas, '\.', ix + 1)
endwhile

unlet tfileWindows tfileXwindows tfileUnknown

""" autocommands
au VimLeave * call s:ScriptFinish ()
execute ("au BufWritePost " . s:file . " call s:LoadFonts (0)")

""" global commands
command! -n=0 QuickFontInfo :call s:QuickFontInfo()
command! -n=? QuickFontAdd :call s:QuickFontAdd(<f-args>)
command! -n=? QuickFontDel :call s:QuickFontDel(<f-args>)
command! -n=0 QuickFontBigger :call s:QuickFontBigger()
command! -n=0 QuickFontSmaller :call s:QuickFontSmaller()
command! -n=1 QuickFontSet :call s:QuickFontSet(<f-args>)
command! -n=0 QuickFontReload :call s:LoadFonts(0)

""" global mappings
if s:maps
	if exists ("quickfonts_debug") " so unique doesn't break
		nmap <A->> :QuickFontBigger<CR>
		nmap <A-<> :QuickFontSmaller<CR>
	else
		nmap <unique> <A->> :QuickFontBigger<CR>
		nmap <unique> <A-<> :QuickFontSmaller<CR>
	endif
endif


""" read or re-read font file
function! s:LoadFonts(setfont)
	let strbuf = s:LoadFile (s:file)

	" read header info
	while strbuf =~ '^#'
		let curlin = substitute (strbuf, "\n.*", "", "")
		let strbuf = substitute (strbuf, "[^\n]*\n", "", "")
		let colon = match (curlin, ":")
		let key = strpart (curlin, 1, colon -1)
		let val = strpart (curlin, colon + 1)
		let s:var_{key} = val
	endwhile

	" read fonts (backward compatible)
	call s:ReadFonts (strbuf)

	if a:setfont > 0
		let s:selfont = 0
	elseif s:selfont >= s:fnum
		let s:selfont = s:fnum - 1
	endif

	if s:menu
		call s:BuildFontMenus()
	endif

	let s:save = 0
endfunction

""" utility to load file into string
function! s:LoadFile(fname)
	let retstr = ""
	if filereadable (a:fname)
		let retstr = system ("cat " . a:fname)
	endif
	return retstr
endfunction

"" parse fonts from a string (header info already stripped)
function! s:ReadFonts(str)
	let fonts = a:str
	let s:fnum = 0
	while strlen (fonts) > 0
		let curfont = substitute (fonts, "\n.*", "", "")
		let fonts = substitute (fonts, "[^\n]*\n", "" , "")
		if curfont != ""
			let name_start = match (curfont, ":") + 1
			let s:fsa{s:fnum} = strpart (curfont, 0, name_start - 1)
			let s:fna{s:fnum} = strpart (curfont, name_start)
			let s:fnum = s:fnum + 1
		endif
	endwhile
endfunction

"" write fonts to config file
function! s:ScriptFinish()
	if s:save == 0 && (s:auto == 0 || (exists ("s:var_LASTFONT") && s:selfont == s:var_LASTFONT))
		return
	endif
	let fonts = ""
	let cnt = 0
	while cnt < s:fnum
		let fonts = fonts . s:fsa{cnt} . ":" . s:fna{cnt} . "\n"
		let cnt = cnt + 1
	endwhile
	let fonts = "#VERSION:2\n#LASTFONT:" . s:selfont . "\n" . fonts
	if &shell =~ 'csh'
		call system ("echo '" . escape (fonts, "\n") .  "' > " . s:file)
	else
		call system ("echo '" . fonts .  "' > " . s:file)
	endif
endfunction

"" list fonts info and selected font
function! s:QuickFontInfo()
	echo "num area name"
	let cnt = 0
	while cnt < s:fnum
		let sel_str = (s:selfont == cnt ? "*" : " ")
		"these are for alignment of numbers and text in info
		exec "let cnt_str = substitute (\"  \", ' \\{" 
					\ . strlen (cnt) . "}$', " . cnt . ", \"\")"
		exec "let fsa_str = substitute (\"    \", ' \\{" 
					\. strlen (s:fsa{cnt}) . "}$', " . s:fsa{cnt} . ", \"\")"
		echo sel_str . cnt_str . " " . fsa_str . " " . s:fna{cnt}
		let cnt = cnt + 1
	endwhile
endfunction

"" add current font, argument font,  or font selector if arg is '*'
function! s:QuickFontAdd(...)
	if a:0 > 0
		let prevfont = &guifont
		if a:1 == '*'
			set guifont=*
			if prevfont == &guifont
				echo "QuickFontAdd: new font not selected"
				return
			endif
		else
			execute "set guifont=" . a:1
		endif
	endif
	let newfont = &guifont
	if newfont == "" || newfont == "*"
		echo "no font in 'guifont' - use '*' or set with :set guifont=*"
		return
	endif

	redraw
	let area = s:GetGeom{s:winsys} (newfont)

	let cnt = 0
	while cnt < s:fnum
		" see if we already have this font
		if s:fna{cnt} == newfont
			echo "QuickFontAdd: new font matches font number " cnt
			return
		endif

		"echo "cnt " . cnt . " area " . area . " fsa{cnt} " . s:fsa{cnt}
		if (area + 0) <= (s:fsa{cnt} + 0)
			break
		endif
		let cnt = cnt + 1
	endwhile

	echo "QuickFontAdd: " . newfont

	let cnt2 = s:fnum - 1
	while cnt2 >= cnt
		let s:fsa{cnt2 + 1} = s:fsa{cnt2}
		let s:fna{cnt2 + 1} = s:fna{cnt2}
		let cnt2 = cnt2 - 1
	endwhile

	let s:selfont = cnt
	let s:fsa{cnt} = area
	let s:fna{cnt} = newfont
	let s:fnum = s:fnum + 1
	let s:save = 1

	if s:menu
		call s:BuildFontMenus()
	endif

endfunction

"" remove passed in font num or current selected font
function! s:QuickFontDel(...)
	if a:0 > 0
		let condemned = a:1
	else
		let condemned = s:selfont
	endif

	if condemned >= s:fnum || condemned < 0
		echo "font " . condemned . " out of range"
		return
	endif

	let cnt = condemned
	while cnt < s:fnum - 1
		let s:fsa{cnt} = s:fsa{cnt + 1}
		let s:fna{cnt} = s:fna{cnt + 1}
		let cnt = cnt + 1
	endwhile
	let s:fnum = s:fnum - 1
	exec "unlet s:fsa" . cnt
	exec "unlet s:fna" . cnt
	if condemned == s:selfont && s:fnum > 1
		let s:selfont = s:selfont - 1
		call <SID>QuickFontBigger ()
	endif

	let s:save = 1
	if s:menu
		call s:BuildFontMenus()
	endif
endfunction

"" switch to bigger font
function! s:QuickFontBigger()
  let s:selfont = s:selfont + 1
  if s:fnum == 0 || s:selfont >= s:fnum
    let s:selfont = s:fnum - 1
		echo "QuickFont: no more fonts - end of list"
		return
  endif
	let newfont = s:fna{s:selfont}
  execute "set guifont=" . escape (newfont, " ")
	redraw
	echo "QuickFontBigger: " . newfont
endfunction

"" switch to smaller font
function! s:QuickFontSmaller()
  let s:selfont = s:selfont - 1
  if s:fnum == 0 || s:selfont < 0
		echo "QuickFont: no more fonts - start of list"
    let s:selfont = 0
		return
  endif
	let newfont = s:fna{s:selfont}
  execute "set guifont=" . escape (newfont, " ")
	redraw
	echo "QuickFontBigger: " . newfont
endfunction

"" switch to specific font - usefule after QuickFontInfo
function! s:QuickFontSet(fn)
	if a:fn < 0 || a:fn >= s:fnum
		echo "QuickFont: invalid font number - see :QuickFontInfo"
		return
	endif

	let s:selfont = a:fn

	let newfont = s:fna{s:selfont}
  execute "set guifont=" . escape (newfont, " ")
	redraw
	echo "QuickFontSet: " . newfont
endfunction
	
"" get X windows font geometry (unix only)
function! s:GetGeomXwindows(newfont)
	if s:xwin
		let save_ts = &titlestring
		let save_t = &title
		let temp_title = tempname()
		set title
		exec "set titlestring=" . temp_title
		redraw! " required now to get title to take
		sleep 50m
		let geom = system ('xwininfo -name ' . temp_title)
		" save and swith ignorecase setting becasue it affects substitute()
		let save_ic = &ignorecase | set noignorecase
		" make sure no errors from xwininfo
		if match (geom, "error") < 0  && match (geom, "Command not found") < 0
			let geom_w = substitute (geom, '.*Width: ', "", "")
			let geom_w = substitute (geom_w, '[^0-9].*', "", "")
			let geom_h = substitute (geom, '.*Height: ', "", "")
			let geom_h = substitute (geom_h, '[^0-9].*', "", "")
			let width = (geom_w/&columns)
			let area = ((geom_h/&lines)*width)
			let &titlestring = save_ts
			let &title = save_t
			let &ignorecase = save_ic
			return (area)
		else
			" drop through to next method
			let &titlestring = save_ts
			let &title = save_t
		endif
		let &ignorecase = save_ic
	endif

	"TODO

	let area = 0
	return (area)

endfunction

"" get MS Windows font geometry (not implemented)
function! s:GetGeomWindows(newfont)
	return '0'
endfunction

""  get font geometry fall back
function! s:GetGeomUnknown(newfont)
	return '0'
endfunction

function s:QFA_Helper()
	let nf = input ("Enter font name> ")

	if strlen (nf) == 0
		return
	else
		call s:QuickFontAdd(nf)
	endif
endfunction

function! s:Helper(prom, cmd)
	let in=input(a:prom)
	if strlen (in) == 0
		return
	endif
	execute ":" . a:cmd . " " . in
endfunction

" create menus
if s:menu
	execute "menu " . s:mdep . "10 " . s:mbas 
				\ ."&QuickFonts.&Smaller      :QuickFontSmaller<cr>"
	execute "menu " . s:mdep . "20 " . s:mbas 
				\ . "&QuickFonts.&Bigger       :QuickFontBigger<cr>"
	execute "menu " . s:mdep . "40 " . s:mbas 
				\ . "&QuickFonts.&Info         :QuickFontInfo<cr>"
	execute "menu " . s:mdep . "50 " . s:mbas 
				\ . "&QuickFonts.&Add.&Current :QuickFontAdd<cr>"
	execute "menu     " . s:mbas 
				\ . "&QuickFonts.&Add.&Specify :QuickFontAdd *<cr>"
	execute "menu " . s:mdep . "60 " . s:mbas 
				\ . "&QuickFonts.&Del.&Current :QuickFontDel<cr>"
	execute "menu     " . s:mbas 
				\ . "&QuickFonts.&Del.&Specify :call "
				\ . "<SID>Helper('DELETE: Font Number> ', 'QuickFontDel')<cr>"
	execute "menu " . s:mdep . "70 " . s:mbas 
				\ . "&QuickFonts.&Reload       :QuickFontReload<cr>"
endif

"""  utility to build font specific menus
function! s:BuildFontMenus()
	execute "silent! unmenu " . s:mbas . "QuickFonts.Set"
	let cnt = 0
	let mencmd1 = "menu " . s:mdep . "30 " . s:mbas . "&QuickFonts.S&et.&"
	let mencmd2 = "menu " . s:mdep . "30 " . s:mbas . "&QuickFonts.S&et.&"
	while cnt < s:fnum
		let cmd = ((cnt < 10) ? mencmd1 : mencmd2)
		let cmd = cmd . cnt . escape(s:fna{cnt}, '. ')
		let cmd = cmd . " :QuickFontSet " . cnt .  "<cr>"
		execute cmd
		let cnt = cnt + 1
	endwhile
endfunction

" first time load
call s:LoadFonts (1)
if s:auto == 1 && exists("s:var_LASTFONT")
	if s:var_LASTFONT >= 0 && s:var_LASTFONT < s:fnum
		let s:selfont = s:var_LASTFONT
		execute "set guifont=" . escape (s:fna{s:selfont}, " ")
	endif
endif

let &cpo = s:scpo " restore vim settings

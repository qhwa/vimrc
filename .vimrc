fun! MySys()
   return "mac"
endfun
set runtimepath=~/.vim_runtime,~/.vim_runtime/after,\$VIMRUNTIME
source ~/.vim_runtime/vimrc
"helptags ~/.vim_runtime/doc

" Lucida Sans Typewriter
"set guifont=Lucida\ Sans\ Typewriter\ Regular:h13

" Fira Code
set guifont=Fira\ Code:h15
set macligatures

if has("gui_running")
  set guioptions-=T
  set t_Co=256
  set background=light
  colorscheme tutticolori
else
  colorscheme colorful
endif

set nocompatible
set number
set noeb
set confirm
set autoindent cindent
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab
set history=1000
set nobackup noswapfile
set ignorecase smartcase hlsearch incsearch
set gdefault
set enc=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set langmenu=zh_CN.UTF-8 helplang=cn
set ruler

" 显示空白字符
" 方便团队协作时使用规范的代码间隔
set listchars=tab:>-,trail:~,extends:>,precedes:<

set viminfo+=!
set mouse=a
set selection=exclusive
set selectmode=mouse,key
set report=0
set shortmess=atl
set showmatch
set matchtime=5
set scrolloff=3

syntax on
filetype on
filetype plugin on
filetype indent on

imap jk <Esc>
inoremap <leader>d <ESC>dd

"<Ctrl-s> for saving
map <silent><C-s> :update<CR>
inoremap <C-s> <ESC>:update<CR>a

" key-mappings for comment line in normal mode
nnoremap <silent> cm :call CommentLine()<CR>
" key-mappings for range comment lines in visual <Shift-V> mode
vnoremap <silent> cm :call RangeCommentLine()<CR>

" key-mappings for un-comment line in normal mode
nnoremap <silent> cu :call UnCommentLine()<CR>
" key-mappings for range un-comment lines in visual <Shift-V> mode
vnoremap <silent> cu :call RangeUnCommentLine()<CR>

" key-mapping for CtrlSF plugin
nnoremap <silent> <leader>f :CtrlSF<CR>
nmap <silent> <leader>d <Plug>DashSearch

au FileType ruby nnoremap <buffer> <leader>r :!ruby "%"<CR>
au FileType javascript nnoremap <buffer> <leader>r :!node "%"<CR>
au FileType vim nnoremap <buffer> <leader>r :so %<CR>
au FileType sh  nnoremap <buffer> <leader>r :!sh "%"<CR>
au FileType arduino  nnoremap <buffer> <leader>r :!make && make upload<CR>
au FileType actionscript set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab
au BufRead,BufNewFile *.wpy setlocal filetype=vue.html.javascript.css

" key-mappings for <Alt-[hjkl]> moving cursor in insert mode
inoremap <M-l> <RIGHT>
inoremap <M-k> <UP>
inoremap <M-j> <DOWN>
inoremap <M-h> <LEFT>

inoremap `` <ESC>
inoremap <C-l> <ESC>A
inoremap <C-h> <ESC>I
inoremap <silent><C-o> <ESC>O

nnoremap <C-d> yyp
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" <Alt + [1-5]> goto tab in position i
nnoremap <M-1> 1gt
nnoremap <M-2> 2gt
nnoremap <M-3> 3gt
nnoremap <M-4> 4gt
nnoremap <M-5> 5gt

unmap <LEFT>
unmap <RIGHT>

nnoremap <C-z> :shell<CR>

" Plugin: Quickfonts
nnoremap <leader>= :QuickFontBigger<CR>
nnoremap <leader>- :QuickFontSmaller<CR>

vnoremap " <ESC>i"<ESC>gvo<ESC>i"<ESC>
vnoremap ' <ESC>i'<ESC>gvo<ESC>i'<ESC>

" Plugin: NERDTree
noremap <F2> :NERDTreeToggle \| :silent NERDTreeMirror<CR>

" hit <leader> twice to auto align codes
noremap <leader><leader> :Tabularize /=<CR>
noremap <leader>;        :Tabularize /:/l0<CR>

let g:NERDTreeWinPos = "right"

" Plugin: Rails
let g:rails_statusline=0

" Plugin: NERDTree-Ack
let g:path_to_search_app = "/usr/bin/ack-grep" 

" Plugin: vimim
"let g:vimim_cloud = 'google,sogou,baidu,QQ'
let g:vimim_cloud = 'sogou'

autocmd! BufRead,BufNewFile *.less set filetype=less

" open NERDTree if start as a blank file
autocmd vimenter * if !argc() | NERDTree | endif


" vundle configs
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

Bundle 'tpope/vim-rails'
Bundle 'Keithbsmiley/rspec.vim'
Bundle 'plasticboy/vim-markdown'
Bundle 'godlygeek/tabular'
Bundle 'Lokaltog/vim-powerline'
Bundle 'digitaltoad/vim-jade'
Bundle 'slim-template/vim-slim'
Bundle 'groenewege/vim-less'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-dispatch'
Bundle 'sudar/vim-arduino-syntax'
Bundle 'tclem/vim-arduino'
Bundle 'hsanson/vim-android'
Bundle 'jeroenbourgois/vim-actionscript'
Bundle 'AndrewRadev/vim-eco'
Bundle 'dyng/ctrlsf.vim'
Bundle 'evanmiller/nginx-vim-syntax'
Bundle 'suan/vim-instant-markdown'
Bundle 'rizzatti/dash.vim'
Bundle "MarcWeber/vim-addon-mw-utils"

" snipmate
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle "honza/vim-snippets"

Bundle 'vim-scripts/Emmet.vim'
Bundle 'vim-scripts/WebAPI.vim'
Bundle 'elixir-lang/vim-elixir'
Bundle 'posva/vim-vue'
Bundle 'nathanielc/vim-tickscript'
Bundle 'sjl/gundo.vim'

let g:vim_markdown_folding_disabled = 1
let g:jsx_ext_required = 0
let g:tick_fmt_autosave = 0

filetype on

" Vundle Stuff {{{
set nocompatible              " be iMproved, required
   filetype off                  " required

   " set the runtime path to include Vundle and initialize
   set rtp+=~/.vim/bundle/Vundle.vim
   call vundle#begin()
   " alternatively, pass a path where Vundle should install plugins
   "call vundle#begin('~/some/path/here')

   " let Vundle manage Vundle, required
   Plugin 'gmarik/Vundle.vim'
   Plugin 'christoomey/vim-tmux-navigator'
   Plugin 'benmills/vimux'
   Plugin 'rust-lang/rust.vim'
   Plugin 'tpope/vim-unimpaired'
   Plugin 'tpope/vim-repeat'
   Plugin 'tpope/vim-fugitive'
   Plugin 'tpope/vim-speeddating'

   " All of your Plugins must be added before the following line
   call vundle#end()            " required
   filetype plugin indent on    " required

" }}}

" set leader
let mapleader = ','
let maplocalleader = "\\"

"Always show current position
set ruler
set number

" configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
set autochdir

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

"no error sounds
set noerrorbells

" Tab complete like bash/zsh
set wildmode=longest,list,full
set wildmenu

""""""""""""""""""""""""""""""""""""""""""""""
"==Colors & Syntax==

syntax enable
"colorscheme solarized 
"  colorscheme slate 
"  set background=dark
""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" map <space> to search and ctrl-space to reverse search
map <space> /
map <c-space> ?

"disable highlight
map <silent> <leader><cr> :noh<cr>

"move between windows smartly
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>cd :lcd %:p:h<cr>:pwd<cr>

"return to last edit position
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

"show status line
set laststatus=2

"format status line
set statusline=\ %{HasPaste()\ }%t%m%r%h\ %y%w\ \ cwd:\ %r%{getcwd()}%h\ \ %{fugitive#statusline()}\ \ Line:\ %l/%L\ %P

"=> helper functions"
function! HasPaste()
    if &paste
        return 'PASTE MODE'
    en
    return ''
endfunction

" Set shortcuts for editing/sourcing vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>es :source $MYVIMRC<cr>

" Vimscript file settings {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

" Insert Mode Mappings {{{
    inoremap  <c-d> <esc>ddi
" }}}

" Normal Mode Mappings {{{
    "Quote current word, include dots include.h
    nnoremap <leader>"w viw<esc>a"<esc>hbi"<esc>lel
    nnoremap <leader>"W viW<esc>a"<esc>hBi"<esc>lEl
    nnoremap <leader>x  :VimuxPromptCommand<CR>
" }}}

" Visual Mode Mappings {{{
    vnoremap <leader>" <esc>`>a"<esc>v`<<esc>i"<esc>`>l    
" }}}

" Commenting Commands {{{
augroup filetype_comments
    autocmd FileType c,cpp,java,javascript let b:comment_leader = '// '
    autocmd FileType sh,ruby,python,zsh    let b:comment_leader = '# ' 
    autocmd FileType vim                   let b:comment_leader = '" '
augroup END
noremap <silent> <leader>cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>

noremap <silent> <leader>cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
" }}}

" Makefile Specific {{{
"This is to set Makefiles to use tabs
autocmd FileType make setlocal noexpandtab
" }}}

function! HeatseekerCommand(choice_command, hs_args, first_command, rest_command)
    try
        let selections = system(a:choice_command . " | hs " . a:hs_args)
    catch /Vim:Interrupt/
        redraw!
        return
    endtry
    redraw!
    let first = 1
    for selection in split(selections, "\n")
        if first
            exec a:first_command . " " . selection
            let first = 0
        else
            exec a:rest_command . " " . selection
        endif
    endfor
endfunction

if has('win32')
    nnoremap <leader>f :call HeatseekerCommand("dir /a-d /s /b", "", ':e', ':tabe')<CR>
else
    nnoremap <leader>f :call HeatseekerCommand("find . ! -path '*/.git/*' -type f -follow", "", ':e', ':tabe')<cr>
endif

function! HeatseekerBuffer()
    let bufnrs = filter(range(1, bufnr("$")), 'buflisted(v:val)')
    let buffers = map(bufnrs, 'bufname(v:val)')
    let named_buffers = filter(buffers, '!empty(v:val)')
    if has('win32')
        let filename = tempname()
        call writefile(named_buffers, filename)
        call HeatseekerCommand("type " . filename, "", ":b", ":b")
        silent let _ = system("del " . filename)
    else
        call HeatseekerCommand('echo "' . join(named_buffers, "\n") . '"', "", ":b", ":b")
    endif
endfunction

" Fuzzy select a buffer. Open the selected buffer with :b.
nnoremap <leader>b :call HeatseekerBuffer()<cr>

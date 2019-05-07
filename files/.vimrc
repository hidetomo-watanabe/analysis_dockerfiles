set nocompatible
colorscheme darkblue
syntax on
set number
set clipboard=unnamed,autoselect
set showmatch
set fileencodings=ja_JP,utf-8,iso-2022-jp,cp932,euc-jp
set laststatus=2
set statusline=%f\ [%{&fenc==''?&enc:&fenc}][%{&ff}]%=%8l:%c%8P
set splitright
set incsearch
set hlsearch
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set cindent
" set statusline=%F%m%r%h%w\%=[TYPE=%Y]\[FORMAT=%{&ff}]\[ENC=%{&fileencoding}]\[LOW=%l/%L]
set statusline=%F%m%r%h%w\%=[ENC=%{&fileencoding}]\[LOW=%l/%L]
set backspace=indent,eol,start
set whichwrap=b,s,[,],,~
" set mouse=a
" set ttymouse=xterm2
set ignorecase
set wildmenu
set cursorline
set encoding=utf-8

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <Down> gj
nnoremap <Up> gk
imap <C-j> <esc>

autocmd FileType python setl cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
autocmd FileType markdown hi! def link markdownItalic LineNr
autocmd FileType sh setl tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType vue setl tabstop=2 shiftwidth=2 softtabstop=2

augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

if has("autocmd")
    augroup redhat
        " In text files, always limit the width of text to 78 characters
        autocmd BufRead *.txt set tw=78
        " When editing a file, always jump to the last cursor position
        autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
        \   exe "normal! g'\"" |
        \ endif
    augroup END
endif

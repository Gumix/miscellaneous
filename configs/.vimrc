" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set laststatus=2    " Always display the status line
"set statusline=%f%M%R%Y\ \ \ %{fugitive#statusline()}%=%{strftime(\"%H:%M\",localtime())}\ \ %P\ %3c\ %4l/%L\ 
"set statusline=%f%M%R%Y\ \ \ %{fugitive#statusline()}%=\ \ \ %{strftime(\"%H:%M\",localtime())}\ \ %P\ %3c%V\ %4l/%L\ 
set statusline=%f%M%R%Y\ \ \ %=\ \ %P\ %3c%V\ %4l/%L\ 
set incsearch		" Do incremental searching
set ignorecase		" Case-insensitive searching
set smartcase		" If a pattern contains an uppercase letter, it is case sensitive, otherwise, it is not
set wildmenu		" Show possible completions of command line commands
set undolevels=1000	" The number of changes that are remembered
set history=500		" Lines of command line history
set swapfile!
set updatecount=0	" No swap file will be used
set nobackup		" Do not keep a backup file
set number			" Show line numbers
set ruler			" Show the cursor position all the time
set backspace=indent,eol,start	" allow backspacing over everything in insert mode
set showcmd			" Display incomplete commands
set tabstop=4		" Display tab as 4 spaces
set t_Co=256		" Enable 256 colors
colorscheme jellybeans_g

map \ :nohlsearch <CR>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" results of grep - next F7, prev F9
map <F7> :cprevious <CR>
map <F9> :cnext <CR>
let Grep_Skip_Dirs = '.git build build_accel build_host install'
let Grep_Skip_Files = 'tags'

execute pathogen#infect()

let gitgutter_sign = "⇰"
let g:gitgutter_sign_added = gitgutter_sign
let g:gitgutter_sign_modified = gitgutter_sign
let g:gitgutter_sign_removed = gitgutter_sign
let g:gitgutter_sign_modified_removed = gitgutter_sign

let g:move_key_modifier = 'C'

let g:startify_fortune_use_unicode = 1

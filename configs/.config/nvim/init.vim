set number			" Show line numbers
set ruler			" Show the cursor position all the time
set laststatus=2		" Always display the status line
set statusline=%f%M%R%Y\ \ \ %=\ \ %P\ %3c%V\ %4l/%L\ 
set incsearch			" Do incremental searching
set ignorecase			" Case-insensitive searching
set smartcase			" If a pattern contains an uppercase letter, it is case sensitive, otherwise, it is not
set wildmenu			" Show possible completions of command line commands
set undolevels=1000		" The number of changes that are remembered
set history=500			" Lines of command line history
set updatecount=0		" Do not create the swap file
set nobackup			" Do not keep a backup file
set backspace=indent,eol,start	" Allow backspacing over everything in insert mode
set showcmd			" Display incomplete commands
set termguicolors		" Use 24-bit color
set background=dark		" Set the background theme to dark
set hlsearch			" Highlight the last used search pattern.
syntax enable			" Syntax highlighting
colorscheme jellybeans_g	" Set the color scheme

map \ :nohlsearch <CR>

set tags=./tags,tags;

set shiftwidth=8 tabstop=8 softtabstop=0
set cinoptions=:0,l1,t0,(0,u0,W1s,j1
autocmd FileType lua setlocal sw=4 ts=4 sts=4 et

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!
" For all text files set 'textwidth' to 80 characters.
autocmd FileType text setlocal textwidth=80

" Comma-separated list of screen columns that are highlighted with ColorColumn.
let &colorcolumn=join(range(81,200),",")

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif
augroup END

" Results of grep - next F7, prev F9
map <F7> :cprevious <CR>
map <F9> :cnext <CR>
let Grep_Skip_Dirs = '.git build install'
let Grep_Skip_Files = 'tags'

let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1

let gitgutter_sign = "→"
let g:gitgutter_sign_added = gitgutter_sign
let g:gitgutter_sign_modified = gitgutter_sign
let g:gitgutter_sign_removed = gitgutter_sign
let g:gitgutter_sign_modified_removed = gitgutter_sign

" FZF key bindings
nnoremap <C-f> :FZF <CR>

" Load Lua config
lua require('init')

" numToStr/Comment.nvim
lua require('Comment').setup()

let g:bookmark_sign = '✏️'

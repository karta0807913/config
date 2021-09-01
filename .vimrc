let mapleader = ','

map <leader>ntd :NERDTreeToggle<CR>
nmap <C-x><C-b> :buffers<CR>
nmap <leader>bn :bnext<CR>
nmap <leader>bp :bprev<CR>
nmap <leader>b  :b

set tabstop=4
set expandtab
set nu
set shiftwidth=4
" colorscheme darkblue

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'sonph/onehalf', { 'rtp': 'vim' }

call plug#end()

try
    colorscheme onehalfdark
catch
endtry

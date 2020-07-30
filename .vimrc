
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

syntax on
filetype plugin indent on

" VundleVim
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-surround'

" Plugin 'flazz/vim-colorschemes'
" Plugin 'morhetz/gruvbox'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" git config --global diff.tool vimdiff
" git config --global difftool.prompt false
" git config --global alias.d difftool

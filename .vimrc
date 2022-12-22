inoremap <silent> jj <ESC>
set expandtab
set hlsearch
set incsearch
set smartcase
set autoindent
set number
set tabstop=4
set shiftwidth=4
set guioptions+=1
syntax on
set smartindent
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>
if has('vim_starting')
	let &t_SI .= "\e[6 q"
	let &t_EI .= "\e[2 q"
	let &t_SR .= "\e[4 q"
endif

nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
    let buffer_numbers = {}
    for quickfix_item in getqflist()
        let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
        endfor
        return join(map(values(buffer_numbers),'fnameescape(v:val)'))
        endfunction

let g:syntastic_javascript_checkers=['eslint']
let g:syntastic_python_checkers=['pep8', 'pyflakes']
call plug#begin('~/.vim/plugged')
  Plug 'rust-lang/rust.vim'
  Plug 'EdenEast/nightfox.nvim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
  Plug 'godlygeek/tabular'
  Plug 'plasticboy/vim-markdown'
  Plug 'previm/previm'
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/fern-git-status.vim'
  Plug 'tomasiser/vim-code-dark'
call plug#end()
let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
let g:previm_open_cmd = 'open -a Google\ Chrome'

filetype plugin indent on
let g:rustfmt_autosave = 1
let g:coc_global_extensions = ['coc-rust-analyzer']
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
set termguicolors
packloadall
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

colorscheme codedark
let g:airline_thema = 'codedark'
nnoremap <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>


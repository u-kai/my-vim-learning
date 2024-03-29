""""""""""""""""""""" Normal settings
inoremap <silent> jj <ESC>
set hlsearch
set incsearch
set smartcase
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
set clipboard=unnamed

if !exists('g:vscode')
    set expandtab
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
endif

syntax on
"""""""""""""""""""""" Vim file type detection
filetype plugin indent on

""""""""""""""""""""" Plugin settings
call plug#begin('~/.config/nvim/plugged')

  """"""""""""""""""""" LSP
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  ""Plug 'rust-lang/rust.vim'

  """"""""""""""""""""" Lint and Formatters
  ""Plug 'prettier/vim-prettier', {
   ""         \ 'do': 'yarn install --frozen-lockfile --production',
   ""         \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html']}

  """"""""""""""""""""" Displays
  """"""""""""""""""""" Display status line
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tomasiser/vim-code-dark'

  """"""""""""""""""""" Display file tree
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/fern-git-status.vim'

  """"""""""""""""""""" Display Icon
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/glyph-palette.vim'

  """"""""""""""""""""" Display Git
  Plug 'airblade/vim-gitgutter'

  """"""""""""""""""""" Search files
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'


call plug#end()



""""""""""""""""""""" LSP Settings
let g:coc_global_extensions = [
      \'coc-actions',
      \'coc-cspell-dicts', 
      \'coc-diagnostic', 
      \'coc-dictionary', 
      \'coc-eslint', 
      \'coc-floaterm', 
      \'coc-git', 
      \'coc-highlight',
      \'coc-lists', 
      \'coc-markdownlint', 
      \'coc-metals', 
      \'coc-prettier', 
      \'coc-snippets', 
      \'coc-spell-checker', 
      \'coc-tslint-plugin', 
      \'coc-ultisnips', 
      \'coc-java', 
      \'coc-go', 
      \'coc-tsserver', 
      \'coc-jedi', 
      \'coc-json', 
      \'coc-yaml',
      \'coc-rust-analyzer',]
""" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

""""""""""""""""""""" Displays 
" tab line
let g:airline#extensions#tabline#enabled = 1

"" vim-airline
" ステータスラインに表示する項目を変更する
let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c' ],
  \ ['z']
  \ ]
let g:airline_section_c = '%t %M'
let g:airline_section_z = get(g:, 'airline_linecolumn_prefix', '').'%3l:%-2v'
" 変更がなければdiffの行数を表示しない
let g:airline#extensions#hunks#non_zero_only = 1 

" タブラインの表示を変更する
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#show_close_button = 0

"""""""""""""""" VSCode like colorscheme
colorscheme codedark

" airline theme
let g:airline_theme = 'codedark'

" File tree settings
nnoremap <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>

" Enable Icon
let g:fern#renderer = 'nerdfont'

" Add color to icon
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

"""""""""""""""""""" git操作
" g]で前の変更箇所へ移動する
nnoremap g[ :GitGutterPrevHunk<CR>

" g[で次の変更箇所へ移動する
nnoremap g] :GitGutterNextHunk<CR>

" ghでdiffをハイライトする
nnoremap gh :GitGutterLineHighlightsToggle<CR>

" gpでカーソル行のdiffを表示する
nnoremap gp :GitGutterPreviewHunk<CR>

" 記号の色を変更する
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=blue
highlight GitGutterDelete ctermfg=red
"" 反映時間を短くする(デフォルトは4000ms)
set updatetime=250


"" fzf.vim
" Ctrl+pでファイル検索を開く
" git管理されていれば:GFiles、そうでなければ:Filesを実行する
fun! FzfOmniFiles()
  let is_git = system('git status')
  if v:shell_error
    :Files
  else
    :GFiles
  endif
endfun
nnoremap <C-p> :call FzfOmniFiles()<CR>

" Ctrl+gで文字列検索を開く
" <S-?>でプレビューを表示/非表示する
command! -bang -nargs=* Rg
\ call fzf#vim#grep(
\ 'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
\ <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 3..'}, 'up:60%')
\ : fzf#vim#with_preview({'options': '--exact --delimiter : --nth 3..'}, 'right:50%:hidden', '?'),
\ <bang>0)
nnoremap <C-g> :Rg<CR>


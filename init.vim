""""""""""""""""""""" Normal settings
inoremap <silent> jj <ESC>
set hlsearch
set incsearch
set smartcase
nnoremap <silent> <C-f> :<C-u>nohlsearch<CR><C-f>
set clipboard=unnamed
set noswapfile
nnoremap <silent> <C-l> :bnext<CR>
nnoremap <silent> <C-h> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>:bdelete #<CR>
command! ReloadInitNvim source ~/.config/nvim/init.vim
nnoremap <silent> <C-]> :vertical resize +5<CR>
nnoremap <silent> <C-[> :vertical resize -5<CR>

function! AddLastLine(text)abort
    let lnum = line('$')
    let last_line = getline(l:lnum)
    let new_line = l:last_line . a:text

    call setline(l:lnum, l:new_line)
endfunction

function! Chat() abort
    :new

    call AddLastLine("you >")
endfunction

function! AICommand()
    " 現在のバッファの内容を取得
    let l:lines = getline(1, '$')
    let l:text = join(l:lines, "\n")
    " 各行を大文字に変換
    let cmd =  "termai ask " . '"' . l:text . '"'
    return l:cmd
endfunction

function! ProcessOutput(job_id,data,event) abort
    if a:event != 'stdout'
        return
    endif
    call AddLastLine(join(a:data,''))
endfunction

function! Run() 
    call append(line('$'), "\n")
    let l:cmd = AICommand()
    call jobstart(l:cmd, {'on_stdout': 'ProcessOutput'}) 
endfunction

command! Chat call Chat()
command! Send call ProcessInput()
command! Run call Run()



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
    inoremap < <><LEFT>
    " inoremap ' ''<LEFT>
    " set complement insert enter
    " inoremap <expr> <CR> pumvisible() ? "<C-y>" : "<CR>"
    if has('vim_starting')
        let &t_SI .= "\e[6 q"
        let &t_EI .= "\e[2 q"
        let &t_SR .= "\e[4 q"
    endif
endif

function! HiraToKata(str) abort
  return a:str->substitute('[ぁ-ゖ]','\=nr2char(char2nr(submatch(0), v:true) + 96, v:true)', 'g')
endfunction

function! CharToByte(char) abort
    let l:char_byte = 1
    if a:char >= 192 && a:char <= 223
        let l:char_byte = 2 
    elseif a:char >= 224 && a:char <= 239
        let l:char_byte = 3
    elseif a:char >= 240 && a:char <= 247
        let l:char_byte = 4
    end
    return l:char_byte
endfunction

function! GetVisualSelected() abort
  let l:start = getpos("'<")
  let l:end = getpos("'>")

  let l:lines = getline(l:start[1], l:end[1])

  let l:result = ""
  for i in range(0, len(l:lines) - 1)
    let l:line = l:lines[i]
    "select only one column
    if l:start[2] == l:end[2]
        let start_char = char2nr(l:line[l:start[2] - 1])
        let char_byte = CharToByte(start_char)
        let l:result = l:result . strpart(l:line, l:start[2] - 1, char_byte)
        continue
    endif

    let l:selected_last_char_byte = CharToByte(char2nr(l:line[l:end[2] - 1]))
    let l:selected_last_char_start = l:end[2] - l:selected_last_char_byte
    let l:range = l:end[2] - l:start[2] + l:selected_last_char_byte
    let l:selected_last_char = strpart(l:line,l:selected_last_char_start,range)

    let l:result = l:result . strpart(l:line, l:start[2] - 1, l:range)

  endfor
  return l:result

endfunction

function! ConvertVisualSelectedByFunc(f)
  let l:start = getpos("'<")
  let l:end = getpos("'>")

  let l:lines = getline(l:start[1], l:end[1])

  for i in range(0, len(l:lines) - 1)
    let l:line = l:lines[i]
    "select only one column
    if l:start[2] == l:end[2]
        let start_char = char2nr(l:line[l:start[2] - 1])
        let char_byte = CharToByte(start_char)
        let l:before = strpart(l:line, 0, l:start[2] - 1)
        let l:replacement = call(a:f, [strpart(l:line, l:start[2] - 1, char_byte)])
        let l:after = strpart(l:line, l:start[2] - 1 + char_byte)

        let l:line = l:before . l:replacement . l:after
        call setline(l:start[1] + i, l:line)
        continue
    endif

    let l:before = strpart(l:line, 0, l:start[2] - 1)
    let l:selected_last_char_byte = CharToByte(char2nr(l:line[l:end[2] - 1]))
    let l:selected_last_char_start = l:end[2] - l:selected_last_char_byte
    let l:range = l:end[2] - l:start[2] + l:selected_last_char_byte
    let l:selected_last_char = strpart(l:line,l:selected_last_char_start,range)

    let l:replacement = call(a:f, [strpart(l:line, l:start[2] - 1, l:range )])
    let l:after = strpart(l:line, l:end[2] + l:selected_last_char_byte - 1)

    let l:line = l:before . l:replacement . l:after
    call setline(l:start[1] + i, l:line)

  endfor
endfunction

function Translate(text)
    if a:text == ""
        return ""
    endif

    let cmd =  "cai ask -r 単語を英語にしてください。ただし、解説等は一切不要で結果のみください。 " . '"' . a:text . '"'
    return system(l:cmd)
endfunction

function CreateProgram(text)
    if a:text == ""
        return ""
    endif

    let extention = expand('%:e')

    let cmd =  "cai ask -r 今から渡す文章に沿ったプログラムを考えてください。ただし、解説やプログラミングの囲み表記などは一切不要で結果のみください。言語は" . l:extention . "拡張子の言語です。 " . "'" . a:text . "'"
    return system(l:cmd)
endfunction

function TypoCorrection(text)
    if a:text == ""
        return ""
    endif
    let l:text = substitute(a:text, '-', '\\-', 'g')
    let cmd =  "cai ask -r 今から渡す文章の誤字脱字を修正してください。ただし、解説等は一切不要で結果のみください。また、もし\\-という文字があればそれは-に変換してください " . "'" . l:text . "'"
    return system(l:cmd)
endfunction

function CreateVariableName(text)
    if a:text == ""
        return ""
    endif

    let l:file_extension = expand('%:e')
    let l:name_rule = ""
    if l:file_extension == "rs" 
        let l:name_rule = "snake_case"
    elseif l:file_extension == "go"
        let l:name_rule = "camelCase"
    else 
        let l:name_rule = "snake_case"
    endif


    let cmd =  "cai ask -r 今から渡す指示に沿ったプログラミングの変数名を考えてく提示してください。ただし、解説等は一切不要で結果のみください。変数の命名規則は" . l:name_rule . "に則って考えてください" . ' "' . a:text . '"'
    return system(l:cmd)
endfunction

function! SearchSelected()abort 
    let l:selected = GetVisualSelected()
    execute "Rg " . l:selected
endfunction

function TypeGenRust(name) abort
    let l:json = GetVisualSelected()
    let l:cmd = "tg rust -p --row " .  "'" .l:json . "'" . " --name " . a:name . " --derives " . "Clone,Debug" . "  --console"
    echo l:cmd
    let output = system(l:cmd)
    let @0 = l:output
endfunction

function TypeGenGo(name) abort
    let l:json = GetVisualSelected()
    let l:cmd = "tg go -pj --row " .  "'" .l:json . "'" . " --name " . a:name . "  --console"
    echo l:cmd
    let output = system(l:cmd)
    let @0 = l:output
endfunction
command! -range -nargs=1 Tgrs call TypeGenRust(<f-args>)
command! -range -nargs=1 Tggo call TypeGenGo(<f-args>)
command! -range Typo call ConvertVisualSelectedByFunc("TypoCorrection")

vnoremap <C-t> :<C-u>call ConvertVisualSelectedByFunc("Translate")<CR>
vnoremap <C-k> :<C-u>call ConvertVisualSelectedByFunc("HiraToKata")<CR>
vnoremap <C-v> :<C-u>call ConvertVisualSelectedByFunc("CreateVariableName")<CR>
vnoremap <C-g> :<C-u>call SearchSelected()<CR>
vnoremap <C-p> :<C-u>call ConvertVisualSelectedByFunc("CreateProgram")<CR>

""""""""""""""""""""" Plugin settings

syntax on
"""""""""""""""""""""" Vim file type detection
filetype plugin indent on

""""""""""""""""""""" Plugin settings
call plug#begin('~/.config/nvim/plugged')

  """"""""""""""""""""" LSP
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'dense-analysis/ale'

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
  Plug 'APZelos/blamer.nvim'

  """"""""""""""""""""" Search files
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'hashivim/vim-terraform' , { 'for': 'terraform'}

  Plug 'ngmy/vim-rubocop'



call plug#end()

let g:blamer_enabled = 1

""if executable('terraform-lsp')
""  au User lsp_setup call lsp#register_server({
""    \ 'name': 'terraform-lsp',
""    \ 'cmd': {server_info->['terraform-lsp']},
""    \ 'whitelist': ['terraform','tf'],
""    \ })
""endif
let g:terraform_fmt_on_save=1

"let g:ale_disable_lsp = 1
"let g:ale_lint_on_text_changed = 1
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
      \'coc-json', 
      \'coc-yaml',
      \'coc-solargraph',
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

let g:copilot_filetypes={"markdown":v:true,"yaml":v:true}

""let g:ale_linters = {
""            \    'ruby': ['rubocop'],
""            \}
""let g:ale_fixers = {
""            \'ruby': ['rubocop'],
""            \}
let g:ale_ruby_rubocop_executable = 'robocop'
let g:fern#default_hidden=1

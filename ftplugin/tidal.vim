if !has('channel') || !has('job')
  echoerr "+channel or +job features are missing! vim-tidal-re won't work here :("
endif

""" Global variables

if !exists("g:tidal_repl")
  " In case of using a symlink but resources are in the same directory as the
  " actual script, do this:
  " 1. Get the absolute path of the script
  " 2. Resolve all symbolic links
  " 3. Get the folder of the resolved absolute file
  let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
  let s:bin_path = resolve(expand(s:path . "/../bin"))

  let g:tidal_repl = get(g:, 'tidal_repl', s:bin_path . "/tidal")
endif

if !exists("g:tidal_preserve_curpos")
  let g:tidal_preserve_curpos = 1
endif

if !exists("g:tidal_flash_duration")
  let g:tidal_flash_duration = 150
end

""" Bindings

if !exists("g:tidal_no_mappings") || !g:tidal_no_mappings
  nnoremap <buffer> <localleader>b :call tidal#Start()<cr>
  nnoremap <buffer> <localleader>q :call tidal#Stop()<cr>

  nnoremap <buffer> <localleader>ee :call tidal#EvalParagraph()<cr>
  nnoremap <buffer> <c-e> :call tidal#EvalParagraph()<cr>
  inoremap <buffer> <c-e> <esc>:call tidal#EvalParagraph()<cr><right>i
  xnoremap <buffer> <localleader>e :call tidal#EvalSelection()<cr>
  xnoremap <buffer> <c-e> :call tidal#EvalSelection()<cr>

  nnoremap <buffer> <localleader>h :call tidal#Hush()<cr>
  nnoremap <buffer> <c-h> :call tidal#Hush()<cr>
  inoremap <buffer> <c-h> <esc>:call tidal#Hush()<cr><right>i

  let i = 1
  while i <= 9
    execute 'nnoremap <buffer> <localleader>'.i.'  :call tidal#Silence('.i.')<cr>'
    execute 'nnoremap <buffer> <c-'.i.'>  :call tidal#Silence('.i.')<cr>'
    execute 'nnoremap <buffer> <localleader>e'.i.' :call tidal#Play('.i.')<cr>'
    let i += 1
  endwhile
endif

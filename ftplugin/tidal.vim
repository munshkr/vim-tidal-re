if !has('channel') || !has('job')
  echoerr "+channel or +job features are missing! vim-tidal-re won't work here :("
endif

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

nnoremap <buffer> <localleader>b :call tidal#Start()<cr>
nnoremap <buffer> <localleader>s :call tidal#EvalParagraph()<cr>
nnoremap <buffer> <c-e> :call tidal#EvalParagraph()<cr>
nnoremap <buffer> <localleader>h :call tidal#Hush()<cr>

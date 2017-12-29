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
nnoremap <buffer> <localleader>q :call tidal#Stop()<cr>

nnoremap <buffer> <localleader>ss :call tidal#EvalParagraph()<cr>
nnoremap <buffer> <c-e> :call tidal#EvalParagraph()<cr>

nnoremap <buffer> <localleader>h :call tidal#Hush()<cr>
nnoremap <buffer> <c-h> :call tidal#Hush()<cr>

let i = 1
while i <= 9
  execute 'nnoremap <buffer> <localleader>'.i.'  :call tidal#Silence('.i.')<cr>'
  execute 'nnoremap <buffer> <c-'.i.'>  :call tidal#Silence('.i.')<cr>'
  execute 'nnoremap <buffer> <localleader>s'.i.' :call tidal#Play('.i.')<cr>'
  let i += 1
endwhile

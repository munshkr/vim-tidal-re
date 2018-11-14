let s:not_prefixable_keywords = [
  \"--",
  \"{-#",
  \"case",
  \"class",
  \"data",
  \"default",
  \"do",
  \"foreign",
  \"import",
  \"instance",
  \"let",
  \"type"
\]

let s:tidal_repl_buffer = 'tidal_repl_buffer'

""" Helpers

function! s:StoreCurPos()
  if g:tidal_preserve_curpos == 1
    if exists("*getcurpos")
      let s:cur = getcurpos()
    else
      let s:cur = getpos('.')
    endif
  endif
endfunction

function! s:RestoreCurPos()
  if g:tidal_preserve_curpos == 1
    call setpos('.', s:cur)
  endif
endfunction

function! s:FlashVisualSelection(msg)
  " Redraw to show current visual selection, and sleep
  redraw
  execute "sleep " . g:tidal_flash_duration . " m"
  " Then leave visual mode
  silent execute "normal! vv"
endfunction

" Guess correct number of spaces to indent
" (tabs are not allowed)
function! s:GetIndentString()
  return repeat(" ", 4)
endfunction

" Teplace tabs by spaces
function! s:TabToSpaces(text)
  return substitute(a:text, "	", s:GetIndentString(), "g")
endfunction

" Check if line is commented out
function! s:IsComment(line)
  return (match(a:line, "^[ \t]*--.*") >= 0)
endfunction

" Remove commented out lines
function! s:RemoveLineComments(lines)
  let l:i = 0
  let l:len = len(a:lines)
  let l:ret = []
  while l:i < l:len
    if !s:IsComment(a:lines[l:i])
      call add(l:ret, a:lines[l:i])
    endif
    let l:i += 1
  endwhile
  return l:ret
endfunction

" Remove block comments
function! s:RemoveBlockComments(text)
  return substitute(a:text, "{-.*-}", "", "g")
endfunction

" Wrap in :{ :} if there's more than one line
function! s:WrapIfMulti(lines)
  if len(a:lines) > 1
    return [":{"] + a:lines + [":}"]
  else
    return a:lines
  endif
endfunction

" Change string into array of lines
function! s:Lines(text)
  return split(a:text, "\n")
endfunction

" Change lines back into text
function! s:Unlines(lines)
  return join(a:lines, "\n") . "\n"
endfunction

function! s:EscapeText(text)
  let l:text  = s:RemoveBlockComments(a:text)
  let l:lines = s:Lines(s:TabToSpaces(l:text))
  let l:lines = s:RemoveLineComments(l:lines)
  let l:lines = s:WrapIfMulti(l:lines)
  let l:result  = s:Unlines(l:lines)

  " return an array, regardless
  if type(l:result) == type("")
    return [l:result]
  else
    return l:result
  end
endfunction

function! s:Truncate(string, num)
  let letters = split(a:string, '\zs')
  return join(letters[:a:num], "")
endfunction

""" Main Functions

let g:tidal_out_buffer = []

function! tidal#plugin#OutHandler(_job_id, data, event) dict
  " Do nothing
endfunction

function! tidal#plugin#ErrHandler(_job_id, data, event)
  echohl ErrorMsg
  for line in a:data
    echo line
  endfor
  echohl None
endfunction

function! tidal#plugin#Start()
  if exists("g:tidal_job") && g:tidal_job > 0
    echo 'TidalCycles already started.'
  else
    let g:tidal_job = tidal#job#start([g:tidal_repl], {
      \'on_stdout': function('tidal#plugin#OutHandler'),
      \'on_stderr': function('tidal#plugin#ErrHandler'),
    \})
    if g:tidal_job > 0
      echom 'TidalCycles started.'
    else
      echom 'TidalCycles failed to start.'
    endif
  endif
endfunction

function! tidal#plugin#Stop()
  if exists("g:tidal_job")
    call tidal#job#stop(g:tidal_job)
    unlet g:tidal_job
    echom "TidalCycles stopped."
  else
    echo "TidalCycles is not running."
  endif
endfunction

function! tidal#plugin#Eval(message)
  if !exists("g:tidal_job")
    call tidal#plugin#Start()
  endif

  let trunc_msg = s:Truncate(a:message, 20)
  echo trunc_msg

  let l:lines = s:EscapeText(a:message)
  for line in l:lines
    call tidal#job#send(g:tidal_job, line . "\n")
  endfor
endfunction

function! tidal#plugin#EvalSimple(message)
  if !exists("g:tidal_job")
    call tidal#plugin#Start()
  endif

  echom a:message
  call tidal#job#send(g:tidal_job, a:message . "\n")
endfunction

function! tidal#plugin#EvalParagraph()
  call s:StoreCurPos()

  silent execute "normal! vipy<cr>"
  let l:content = getreg('')
  call tidal#plugin#Eval(l:content)

  silent execute "normal! '[V']"
  call s:FlashVisualSelection(l:content)
  call s:RestoreCurPos()
endfunction

function! tidal#plugin#EvalSelection() range
  silent execute a:firstline . ',' . a:lastline . 'yank'
  let l:content = getreg('')
  call tidal#plugin#Eval(l:content)
endfunction

function! tidal#plugin#Silence(n)
  if exists("g:tidal_job")
    call tidal#plugin#EvalSimple("d" . a:n . " silence")
  else
    echo "TidalCycles is not running."
  endif
endfunction

function! tidal#plugin#Play(n)
  let res = search('^\s*d' . a:n)
  if res > 0
    call tidal#plugin#EvalParagraph()
  else
    echo "d" . a:stream . " was not found"
  endif
endfunction

function! tidal#plugin#Hush()
  if exists("g:tidal_job")
    call tidal#plugin#EvalSimple("hush")
  else
    echo "TidalCycles is not running."
  endif
endfunction

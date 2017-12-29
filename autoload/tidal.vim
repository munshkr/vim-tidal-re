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

let s:cycle_position_defs = [
  \"now' <- getNow",
  \"let now = nextSam now'",
  \"let retrig = (now `rotR`)",
  \"let fadeOut n = spread' (_degradeBy) (retrig $ slow n $ envL)",
  \"let fadeIn n = spread' (_degradeBy) (retrig $ slow n $ (1-) <$> envL)"
\]

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

function! s:AddCyclePosDefs(lines)
  return s:cycle_position_defs + a:lines
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
    let l:lines = s:AddCyclePosDefs(l:lines)
    let l:result  = s:Unlines(l:lines)

    " return an array, regardless
    if type(l:result) == type("")
      return [l:result]
    else
      return l:result
    end
endfunction

""" Main Functions

function! tidal#OutHandler(channel, msg)
  echohl WarningMsg
  echom a:msg
  echohl None
endfunction

function! tidal#ErrHandler(channel, msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

function! tidal#Start()
  echom "Starting TidalCycles..."
  let g:tidal_job = job_start(g:tidal_repl, {"mode": "nl",
    \                                        "out_cb": "tidal#OutHandler",
    \                                        "err_cb": "tidal#ErrHandler"})
endfunction

function! tidal#Stop()
  if exists("g:tidal_job")
    call job_stop(g:tidal_job)
    unlet g:tidal_job
    echom "TidalCycles stopped."
  else
    echom "TidalCycles is not running."
  endif
endfunction

function! tidal#Eval(message)
  if !exists("g:tidal_job")
    call tidal#Start()
  endif

  let l:lines = s:EscapeText(a:message)
  for line in l:lines
    call ch_sendraw(g:tidal_job, line . "\n")
  endfor
endfunction

function! tidal#EvalSimple(message)
  if !exists("g:tidal_job")
    call tidal#Start()
  endif

  echom a:message
  call ch_sendraw(g:tidal_job, a:message . "\n")
endfunction

function! tidal#EvalParagraph()
  call s:StoreCurPos()

  silent execute "normal! vipy<cr>"
  let l:content = getreg('')
  call tidal#Eval(l:content)

  silent execute "normal! '[V']"
  call s:FlashVisualSelection(l:content)
  call s:RestoreCurPos()
endfunction

function! tidal#EvalSelection() range
  silent execute a:firstline . ',' . a:lastline . 'yank'
  let l:content = getreg('')
  call tidal#Eval(l:content)
endfunction

function! tidal#Silence(n)
  if exists("g:tidal_job")
    call tidal#EvalSimple("d" . a:n . " silence")
  else
    echom "TidalCycles is not running."
  endif
endfunction

function! tidal#Play(n)
  let res = search('^\s*d' . a:n)
  if res > 0
    call tidal#EvalParagraph()
  else
    echo "d" . a:stream . " was not found"
  endif
endfunction

function! tidal#Hush()
  if exists("g:tidal_job")
    call tidal#EvalSimple("hush")
  else
    echom "TidalCycles is not running."
  endif
endfunction

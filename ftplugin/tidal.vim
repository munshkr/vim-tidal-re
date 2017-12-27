" In case of using a symlink but resources are in the same directory as the
" actual script, do this:
" 1. Get the absolute path of the script
" 2. Resolve all symbolic links
" 3. Get the folder of the resolved absolute file
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:bin_path = resolve(expand(s:path . "/../bin"))

let g:tidal_repl = get(g:, 'tidal_repl', s:bin_path . "/tidal")

func! TidalOutHandler(channel, msg)
  echohl WarningMsg
  echom a:msg
  echohl None
endfunc

func! TidalErrHandler(channel, msg)
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunc

func! TidalStart()
  echom "Starting Tidal..."
  let g:tidal_job = job_start(g:tidal_repl, {"mode": "nl",
                  \                          "out_cb": "TidalOutHandler",
                  \                          "err_cb": "TidalErrHandler"})
endfunc

func! TidalStop()
  if exists("g:tidal_job")
    call job_stop(g:tidal_job)
    unlet g:tidal_job
    echom "Tidal stopped."
  else
    echom "Tidal is not running."
  endif
endfunc

func! TidalEval(message)
  if !exists("g:tidal_job")
    call TidalStart()
  endif
  call ch_sendraw(g:tidal_job, a:message . "\n")
  echom a:message
endfunc

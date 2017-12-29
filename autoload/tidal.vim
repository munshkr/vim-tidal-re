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
    call TidalStart()
  endif
  call ch_sendraw(g:tidal_job, a:message . "\n")
  echom a:message
endfunction

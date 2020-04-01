function! maputils#preserve(command) abort
    " Save and restore search and default register and view
    let search_save = @/
    let default_save = @@
    let view = winsaveview()

    execute a:command

    let @/ = search_save
    let @@ = default_save
    call winrestview(view)
endfunction

function! maputils#fzy(choice_command, vim_command) abort
    try
        let output = system(a:choice_command . " | fzy")
    catch /Vim:Interrupt/
        " Swallow errors from ^C, allow redraw! below
    endtry
    redraw!
    if v:shell_error == 0 && !empty(output)
        exec a:vim_command . ' ' . fnameescape(output[:-2])
    endif
endfunction

function! maputils#show_highlight_groups() abort
    echo synstack(line('.'), col('.'))
            \ ->map({_, val -> synIDattr(val, "name")})
            \ ->join()
endfunction

function! maputils#get_selection() abort
    let [pos_start, pos_end] = mode() ==? "v" ? ["v", "."] : ["'<", "'>"]
    let [line_start, column_start] = getpos(pos_start)[1:2]
    let [line_end, column_end] = getpos(pos_end)[1:2]

    " reverse positions if selection is in reverse
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    endif

    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif

    if mode() ==# "v"
        let lines[-1] = lines[-1][:column_end-(&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start-1:]
    endif
    return join(lines, "\n")
endfunction

function! maputils#grep_literal(string) abort
    return ":\<C-U>Grep --fixed-strings " . a:string
                \ ->shellescape(1)
                \ ->escape('|')
                \ ->substitute('\\!', '!', 'g')
                \ . "\<CR>"
endfunction

function! maputils#tmux_xrestore() abort
    let $DISPLAY = split(system("tmux show-environment DISPLAY"), "=")[1][:-2]
    execute "xrestore" $DISPLAY
endfunction

if [ -x /usr/bin/keychain ]; then
    eval $(keychain --eval --clear --nogui id_rsa 0xDFE691AE331BA3DB)
fi
if [ -x /usr/bin/uptime ]; then
    uptime
    echo
fi
if [ -x /usr/games/fortune ]; then
    /usr/games/fortune -s
    echo
fi
if [ -x /usr/bin/from ]; then
    from -c 2>/dev/null
    echo
fi
if [ -x /usr/bin/calendar ]; then
    calendar
fi
if [ -z "$VISUAL" ]; then
    if command -v nvim >/dev/null 2>&1; then
        export VISUAL=nvim
    elif command -v vimx >/dev/null 2>&1; then
        export VISUAL=vimx
    elif command -v vim >/dev/null 2>&1; then
        export VISUAL=vim
    fi
fi

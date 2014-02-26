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
[ ! -x /usr/bin/lesspipe ] || eval "$(lesspipe)"

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original false
zstyle ':completion:*' prompt 'Attempting to correct %e with:'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/home/jamessan/.zshrc'

autoload colors && colors

rst="%{$reset_color%}"
pcc[1]="%{$reset_color${1:-$fg_no_bold[green]}%}"
pcc[2]="%{$reset_color${2:-$fg_no_bold[cyan]}%}"
pcc[3]="%{$reset_color${3:-$fg_bold[red]}%}"
pcc[4]="%{$reset_color${4:-$fg_bold[magenta]}%}"
pcc[5]="%{$reset_color${5:-$fg_no_bold[red]}%}"
pcc[6]="%{$reset_color${6:-$fg_no_bold[yellow]}%}"

typeset -a precmd_functions
# vcs_info wasn't included until 5.0, so ignore all this for older versions
if ! [[ $ZSH_VERSION < 5.0 ]]; then
    _vcs_info_setup() {
        zstyle ':vcs_info:*' enable git hg svn bzr darcs
        zstyle ':vcs_info:*' use-prompt-escapes true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:bzr:*' use-simple true
        zstyle ':vcs_info:*' stagedstr "·$pcc[6]+$pcc[1]"
        zstyle ':vcs_info:*' unstagedstr "·$pcc[5]+$pcc[1]"
        zstyle ':vcs_info:*' formats "─($pcc[2]%s$pcc[1])─<$pcc[4]%r$pcc[2]/%S$pcc[1] $pcc[2]%b$pcc[1]%u%c>"
        zstyle ':vcs_info:svn:*' formats "─($pcc[2]%s$pcc[1])─<$pcc[4]%r$pcc[2]/%S$pcc[1] $pcc[2]%b$pcc[1]>"
        zstyle ':vcs_info:*' actionformats "─($pcc[2]%s$pcc[1])─<$pcc[4]%r$pcc[2]/%S$pcc[1] $pcc[2]%b$pcc[1]%u%c|$pcc[3]%a$pcc[1]>"
        zstyle ':vcs_info:git+set-message:*' hooks show_vcsh
        function +vi-show_vcsh() {
            if [ ! -z "$VCSH_REPO_NAME" ]; then
                hook_com[vcs]="vcsh:$VCSH_REPO_NAME"
            fi
        }

    }
    _vcs_info_setup

    autoload -Uz vcs_info

    precmd_functions+=(vcs_info)
fi

autoload -U bashcompinit && bashcompinit
autoload -Uz compinit && compinit
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY HIST_IGNORE_ALL_DUPS SHARE_HISTORY
setopt NOMATCH
setopt PROMPT_SUBST TRANSIENT_RPROMPT
unsetopt AUTO_CD BEEP EXTENDED_GLOB NOTIFY
bindkey -e

_cyc_config() {
    cyc_config=
    if [ -n "$CYC_CONFIG" ]; then
        cyc_config="(${CYC_CONFIG##*.})"
    fi
}
precmd_functions+=(_cyc_config)

_prompt_setup() {
    chroot_name=
    if [ -f /etc/debian_chroot ]; then
        chroot_name="($(cat /etc/debian_chroot))"
    elif [ -n "$INSIDE_DATAPATH_DOCKER" ]; then
        chroot_name="$INSIDE_DATAPATH_DOCKER"
    fi

    hostcolor="$pcc[2]"
    if [ -n "$SSH_CONNECTION" ]; then
        hostcolor="$pcc[6]"
    fi

    # Provide an indicator when a sub-shell is being used so I don't forget
    # when I do things like run "shell" in gdb
    # It's turtles all the way down
    nested=
    if [ "$SHLVL" -gt 1 ]; then
        # tmux/screen increase the shell level, which is ok because there is
        # clear feedback
        if [ -z "$TMUX" ] && [ -z "$STY" ]; then
            nested='(🐢)'
        elif [ "$SHLVL" -gt 2 ]; then
            nested='(🐢)'
        fi
    fi

    PS1="\
$pcc[1]┌─($pcc[2]%D{%Y-%m-%d %H:%M:%S}$pcc[1])\$vcs_info_msg_0_
$pcc[1]└[\$cyc_config$nested$chroot_name$pcc[2]%n$pcc[1]@$hostcolor%m$pcc[1]] %(0?.$pcc[1].$pcc[3])%? $pcc[1]%#$rst "
    RPROMPT="$pcc[1]($pcc[4]%~$pcc[1])$rst"
    POSTEDIT=$reset_color
}

_prompt_setup

typeset -U path
if [ -d "$HOME/.local/bin" ]; then
    path=($HOME/.local/bin $path)
fi
if [ -d "/usr/games" ]; then
    path=($path /usr/games)
fi
if [ -d "$HOME/.cabal/bin" ]; then
    path=($HOME/.cabal/bin $path)
fi
if [ -d "$HOME/.cargo/bin" ]; then
    path=($HOME/.cargo/bin $path)
fi
if [ -d "$HOME/centos8_tools" ]; then
    path=($HOME/centos8_tools/bin $path)
    if [ -d "$HOME/centos8_tools/venv/bin" ]; then
        eval "$($HOME/centos8_tools/venv/bin/register-python-argcomplete dpsim_session)"
    fi
fi

crack_dump()
{
    local core=$(realpath "$1")
    local coredir=$(dirname "$core")

    if [[ $core =~ \.(tgz|tar\.gz)$ ]]; then
        (
            cd "${coredir}"
            tar axf "${core}"
            [ -d cyc_bsc ] || tar axf cyc_bsc*
        )
        core=${core%.tgz}
        core=${core%.tar.gz}
    fi
    if [ ! -d "${coredir}/cyc_bsc" ]; then
        (
            cd "${coredir}"
            tar axf cyc_bsc*
        )
    fi
    if [ -d "${coredir}/cyc_src" ]; then
        c7 env TZ=UTC "${coredir}"/cyc_bsc/utils/cyc_gdb.sh "${coredir}"/cyc_bsc/bin/xtremapp "$core" --src_path "${coredir}"/cyc_src
    else
        c7 env TZ=UTC "${coredir}"/cyc_bsc/utils/cyc_gdb.sh "${coredir}"/cyc_bsc/bin/xtremapp "$core" -s
    fi
}

dpsim_docker()
{
    local build_type=debug
    [[ -z $1 ]] || build_type=$1
    local repo
    repo=$(git rev-parse --show-toplevel)
    [[ ! -d "${repo}/source/cyc_core" ]] || repo="${repo}/source/cyc_core"
    local image
    mage=$(awk -F= '/IO_BUILD_DOCKER/{print $2}' "${repo}/env.properties")
    [[ -n $image ]] || image=$(cat "${repo}/.dmcache/link/builder")
    if [[ -n $image ]]; then
        eval docker run --pid host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v "${repo}":"${repo}":rw --rm -w "${repo}"/cyc_app/"${build_type}"/simulation/bin -i -t --net=host "${image}" bash
    else
        2>&1 printf 'Could not determine what docker to use\n'
    fi
}

case "$TERM" in
    screen*)
        PROMPT="${PROMPT}%{kzsh\\%}"
        preexec() {
            local CMD=${1[(wr)^(*=*|sudo|exec|-*)]}
            echo -ne "\ek$CMD\e\\"
        }
    ;;
    xterm*)
        PROMPT="${PROMPT}%{]2;zsh%}"
        preexec() {
            local CMD=${1[(wr)^(*=*|sudo|exec|-*)]}
            echo -ne "\e]2;$CMD\007"
        }
    ;;
    *)
    ;;
esac
case $OSTYPE in
    *-gnu)
        alias ls='ls -bC --color=auto --group-directories-first'
    ;;
    *bsd*)
        alias ls='ls -bCG'
    ;;
    *)
    ;;
esac
export GPG_TTY=$(tty)
[ ! -x /usr/bin/lesspipe ] || eval "$(lesspipe)"

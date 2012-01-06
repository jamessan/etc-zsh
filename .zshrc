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
pcc[4]="%{$reset_color${4:-$fg_no_bold[blue]}%}"
pcc[5]="%{$reset_color${5:-$fg_no_bold[red]}%}"
pcc[6]="%{$reset_color${6:-$fg_no_bold[yellow]}%}"

_vcs_info_setup() {
    # Order is important.  Set git last since $HOME is under git control
    zstyle ':vcs_info:*' enable bzr hg darcs svn cvs git
    zstyle ':vcs_info:*' use-prompt-escapes true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:bzr:*' use-simple true
    zstyle ':vcs_info:*' stagedstr "·$pcc[6]+$pcc[1]"
    zstyle ':vcs_info:*' unstagedstr "·$pcc[5]+$pcc[1]"
    zstyle ':vcs_info:*' formats "─($pcc[2]%s$pcc[1])─<$pcc[4]%r$pcc[2]/%S$pcc[1] $pcc[2]%b$pcc[1]%u%c>"
    zstyle ':vcs_info:*' actionformats "─($pcc[2]%s$pcc[1])─<$pcc[4]%r$pcc[2]/%S$pcc[1] $pcc[2]%b$pcc[1]%u%c|$pcc[3]%a$pcc[1]>"
}
_vcs_info_setup

autoload -Uz compinit && compinit
autoload -Uz vcs_info
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory nomatch prompt_subst
unsetopt autocd beep extendedglob notify
bindkey -e

precmd() { vcs_info }

_prompt_setup() {
    chroot_name=
    if [ -f /etc/debian_chroot ]; then
        chroot_name="($(cat /etc/debian_chroot))"
    fi

    PS1="\
$pcc[1]┌─($pcc[2]%D{%Y-%m-%d %H:%M:%S}$pcc[1])\$vcs_info_msg_0_
$pcc[1]└[$chroot_name$pcc[2]%n$pcc[1]@$pcc[2]%m$pcc[1]] %(0?.$pcc[1].$pcc[3])%? $pcc[1]%#$rst "
    RPROMPT="$pcc[1]($pcc[4]%~$pcc[1])$rst"
    POSTEDIT=$reset_color
}

_prompt_setup

typeset -U path
if [ -d "$HOME/bin" ]; then
    path=($HOME/bin $path)
fi
if [ -d "/usr/games" ]; then
    path=($path /usr/games)
fi

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
alias ls='ls -bC --color=auto --group-directories-first'
export DEBEMAIL=jamessan@debian.org
export DEBFULLNAME="James McCoy"
export GPG_TTY=$(tty)

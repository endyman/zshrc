##### COMPLETION
zmodload -i zsh/complist

## enable completition
autoload -U compinit
compinit
autoload -U url-quote-magic
zle -N self-insert url-quote-magic
zstyle -e :urlglobber url-other-schema \
	'[[ $words[1] == scp ]] && reply=("*") || reply=(http https ftp)'

## colors
autoload -U colors
colors

## Completion Style
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' completer _complete _correct _approximate _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

## misc functions
### puppet validate
ndpv() { for pp in $(find $1 -name \*.pp); do echo -n "$pp: ";  puppet parser validate $pp; puppet-lint --no-80chars-check --no-class_inherits_from_params_class-check $pp && echo "Syntax OK";done && for erb in $(find $1 -name \*.erb); do echo -n "$erb: "; erb -x -T '-' $erb | ruby -c ; done}

### inline replace
ndilr() {
    if [ -z $2 ]; then
        echo "Usage: ilr <old> <new>"
	return 1
    else
        grep -r -l $1 * | xargs sed -i '' s/"$1"/"$2"/g
    fi
}

## duration
function preexec() {
  typeset -gi CALCTIME=1
  typeset -gi CMDSTARTTIME=SECONDS
}
function precmd() {
  typeset -gi ETIME=0
  if (( CALCTIME )) ; then
    typeset -gi ETIME=SECONDS-CMDSTARTTIME
  fi
    typeset -gi CALCTIME=0
}
typeset -gi ETIME=0
REPORTTIME=1

## git
setopt prompt_subst
autoload -Uz vcs_info

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr "%{$fg[red]%}U"
zstyle ':vcs_info:*' stagedstr "%{$fg[yellow]%}S"
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
	'%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}][%u%c%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}

## dirstack
mkdir -p $HOME/.cache/zsh
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome
## Remove duplicate entries
setopt pushdignoredups
## This reverts the +/- operators.
setopt pushdminus

# prompt
autoload -U promptinit && promptinit
prompt adam2
RPROMPT=$'[%(?,%{$fg[green]%}%B✓%B%{$reset_color%},%{$fg[red]%}%B✘%B%{$reset_color%}(%?%))][%{$fg[yellow]%}${ETIME}s%{$reset_color%}]$(vcs_info_wrapper)'

# history
SAVEHIST=1000
HISTSIZE=1000
HISTFILE=~/.history
export HISTTIMEFORMAT='%F %T '
export HISTTIMEFORMAT="%Y-%m-%d% H:%M"
export HISTCONTROL="erasedups:ignoreboth"

# tetris
autoload -U tetris
zle -N tetris
bindkey '^X^T' tetris

## misc aliases
alias ll='ls -la'
alias lt='ls -ltr'
alias vi='vim'
alias lhistory='fc -lfDE -1000'
alias d='dirs -v'
alias 0='cd -0'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'


# locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# PATH manipluation
export ANDROID_SDK="/Users/nido/dev/android-sdk"
export PATH="$PATH:$ANDROID_SDK/platform-tools"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin::$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/packer:$PATH"
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

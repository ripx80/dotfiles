# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias
alias ls='ls --color=auto'

# prompt setup
RESET="\[\017\]"
NORMAL="\[\033[0m\]"
RED="\[\033[31;1m\]"
YELLOW="\[\033[33;1m\]"
WHITE="\[\033[37;1m\]"
PINK="\[\033[35m\]"
CYAN="\[\033[36m\]"
SMILEY="${WHITE}:)${NORMAL}"
FROWNY="${RED}:(${NORMAL}"
SELECT="if [ \$? = 0 ]; then echo \"${SMILEY}\"; else echo \"${FROWNY}\"; fi"

#PS1="${RESET}${YELLOW}\h${NORMAL} \`${SELECT}\` ${YELLOW}>${NORMAL} "
PS1="${RESET}${PINK}\t${NORMAL} ${CYAN}\u${NORMAL}@\[\033[32m\]\h:${YELLOW}\w${NORMAL}\$ "
#PS1='[\u@\h \W]\$ '

# funcs

extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }

# Path
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin:/home/rip/code/bin/:/home/rip/.local/bin

export EDITOR=code
# Alias
alias depv='dep status -dot | dot -T png | display'
alias gc='git clone'
alias gp='git push'

alias kube-gt="kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin | awk '{print $1}')"

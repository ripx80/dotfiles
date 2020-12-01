#!/bin/bash

set -e
set -o pipefail

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

PS1="${RESET}${PINK}\t${NORMAL} ${CYAN}\u${NORMAL}@\[\033[32m\]\h:${YELLOW}\w${NORMAL}\$ "


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

# go

godep(){
     go list -f '{{ join .Deps  "\n"}}' .
}
alias depv='dep status -dot | dot -T png | display'

# jw

function vt() {

	if [ -z "$1" ]; then
		echo "Argument for user is missing" 1>&2
		return 1
	fi

	vaulty_authy() {
		if [ $(command -v jq) ]; then
			export VAULT_ADDR=$(echo $3 | jq -r '.vault.address')
			export AWS_REGION=$(echo $3 | jq -r '.aws.region')
			export AWS_DEFAULT_REGION=$(echo $3 | jq -r '.aws.region')
			unset VAULT_TOKEN
			vault login -method=ldap username="$2"
			export VAULT_TOKEN=$(cat ~/.vault-token)
		else
			printf "You must have jq installed to use this script.\n"
			$?=1
		fi

		if [ $? == 0 ]; then
			data=$(vault read -format=json "$1")
			export AWS_ACCESS_KEY_ID=$(echo $data | jq -r '.data.access_key')
			export AWS_SECRET_ACCESS_KEY=$(echo $data | jq -r '.data.secret_key')
		fi
	}

	awsaccounts=(lab1 lab2 hyperloop prod art apps brdcst)
	bethel_values=$(<~/bethel_values.json)
	PS3='Select an account: '
	select opt in "${awsaccounts[@]}"; do
		case "$opt" in
		lab1)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.lab1')" "$1" "$bethel_values"
			break
			;;
		lab2)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.lab2')" "$1" "$bethel_values"
			break
			;;
		hyperloop)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.hyperloop')" "$1" "$bethel_values"
			break
			;;
		prod)
                        vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.prod')" "$1" "$bethel_values"
                        break
                        ;;
		art)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.art')" "$1" "$bethel_values"
                        break
                        ;;
		apps)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.apps')" "$1" "$bethel_values"
                        break
                        ;;
		brdcst)
			vaulty_authy "$(echo $bethel_values | jq -r '.vault.environment_creds.brdcst')" "$1" "$bethel_values"
                        break
                        ;;
		*)
			printf "Invalid selection. Please try again.\n"
			;;
		esac
	done

}

function art(){
	artjson=$(vault read -format json artifactory/creds/bethel-adfs-awsorchestrationadmins2)
    # echo $artjson
    unset ARTIFACTORY_URL ARTIFACTORY_USERNAME ARTIFACTORY_ACCESS_TOKEN ARTIFACTORY_API_KEY
	export ARTIFACTORY_URL="docker.packages.bethel.jw.org"
	export ARTIFACTORY_USERNAME=$(jq -r '.data.username' <<< "$artjson")
	export ARTIFACTORY_ACCESS_TOKEN=$(jq -r '.data.access_token' <<< "$artjson")
	export ARTIFACTORY_API_KEY=$(jq -r '.data.api_key' <<< "$artjson")
    export ARTIFACTORY_PASSWORD=$(jq -r '.data.password' <<< "$artjson")
    echo "username: $ARTIFACTORY_USERNAME"
    echo "api_key: $ARTIFACTORY_API_KEY"
    echo "token: $ARTIFACTORY_ACCESS_TOKEN"
    echo "password: $ARTIFACTORY_PASSWORD"
    echo $ARTIFACTORY_PASSWORD | docker login --username $ARTIFACTORY_USERNAME --password-stdin $ARTIFACTORY_URL
}

# alias for own user
alias vtm='vt drittweiler2'
alias gkc='for f in $(vault list -format=json secret/systems/eks/ | jq -rc '.[]'); do vault read -field=master secret/systems/eks/$f  > $f;done'

# k8s
function sk(){
    export KUBECONFIG=$(pwd)/.kube/config
}

alias k='kubectl'
alias kdp="k describe pod"
alias kgt="kubectl -n kube-system describe secret kubernetes-dashboard-token | awk '/^token:/ {print $2}'"
alias kpfm='kubectl port-forward $(kubectl get pods -n ingress-nginx -o name -l app=auth-ingress-nginx | head -n 1) 8443:443 -n ingress-nginx'
alias kgpm='kubectl run --generator=run-pod/v1 --rm -i --tty testpod --image alpine:latest -n monitoring -- sh'

# git
alias gpf="git push --force"
alias tpip='git commit --amend --no-edit --date="now" && git push --force-with-lease'
alias gc='git clone'
alias gp='git push'
alias gpf='git push --force'

# Path
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export RUSTBIN="$HOME/.cargo/bin"
export EDITOR=code

export PATH=$PATH:$GOBIN:$RUSTBIN:/home/rip/code/bin/

# rust
source $HOME/.cargo/env

# arch
alias pacman='yay'

#docker

dcnuke(){
    docker system prune -a --volumes
}

dccs(){
    local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	fi
}

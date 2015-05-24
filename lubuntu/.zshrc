# This is the start of BENS STUFF
# One note: don't try to execute progams here. It will lock up the shell :(
#This i like the mac's open command. It overwrites the default open command.
alias open="xdg-open"

# use my common config
source $HOME/.benshellrc

#This turns off the Dell Monitor. Useful for PS3
alias onemon="monitor.sh right"

#This turns on both monitors. Undoes onemon
alias twomon="monitor.sh"

alias clang++="clang++-3.6"

# Set my compiler for Cmake
export CXX=/usr/bin/clang++-3.6

symlink() {ln -s  $(readlink -f $1) $(readlink -f $2) }
# This is the end of BENS STUFF
#
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

export TERM="xterm-256color"

playcd() {mplayer -cdrom-device /dev/sr0 cdda://$1}

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git vi-mode)


source $ZSH/oh-my-zsh.sh

# User configuration

# Now that I'm using vi-mode, I need to set jj to <ESC>
bindkey jj vi-cmd-mode

#Changing this for anaconda
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#changing it... here
export PATH="$HOME/anaconda3/bin:$PATH"

# adding Haskell support to syntastic by letting it find the plugins
export PATH="$HOME/.cabal/bin:$PATH"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


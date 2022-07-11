# ~/.zshrc

# key bindings
bindkey '^?'      backward-delete-char          # backspace delete one char backward
bindkey '^[[3~'   delete-char                   # del        delete one char forward
bindkey '^[[A'    up-line-or-history            # up         last command
bindkey '^[[B'    down-line-or-history          # down       next command
# bindkey '^[[D'    backward-char                 # left       move cursor one char backward
# bindkey '^[[C'    forward-char                  # right      move cursor one char
bindkey '^[[5~'   up-line-or-history            # pg_up     move cursor one char backward
bindkey '^[[6~'   down-line-or-history          # pg_dn      move cursor one char forward
bindkey '^[[H'    beginning-of-line             # home       go to the beginning of line
bindkey '^[[F'    end-of-line                   # end        go to the end of line
bindkey '^[[1;5C' forward-word                  # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                 # ctrl+left  go backward one word
bindkey '^H'      backward-kill-word            # ctrl+bs    delete previous word
bindkey '^[[3;5~' kill-word                     # ctrl+del   delete next word
bindkey '^J'      backward-kill-line            # ctrl+j     delete everything before cursor

# auto completion
# in-line suggesetions
source '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
fpath=('/usr/share/zsh/site-functons/'$fpath)
# tab completion
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
# arrow key driven completion menu
zstyle ':completion:*' menu select
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# sudo completion
zstyle ':completion::complete:*' gain-privileges 1

# history shared across sessions
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000
# setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# setopt appendhistory

# syntax highlighting
source '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

# VCS info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ':%b'
source '/usr/share/zsh/plugins/zsh-gitstatus/gitstatus.prompt.zsh'

# colors
function get_kde_color() {
    IFS="," read -A color_rgb <<< $(kreadconfig5 --file kdeglobals --group "$1" --key "$2")
    color_hex=$(printf "#%02x%02x%02x\n" $color_rgb)
    echo $color_hex
}
accent=$(get_kde_color General AccentColor)
# accent=$(get_kde_color Colors:View DecorationFocus)
foreground=$(get_kde_color Colors:View ForegroundNormal)
background=$(get_kde_color Colors:View BackgroundNormal)
alternate=$(get_kde_color Colors:View BackgroundAlternate)
inactive=$(get_kde_color Colors:View ForegroundInactive)
selection=$(get_kde_color Colors:Selection BackgroundAlternate)

# prompt style
set -o PROMPT_SUBST
autoload -Uz promptinit && promptinit
prompt_natalie_setup() {
    # PS1='%K{$accent}%F{black}%~ %f%k%K{black}%F{$accent}%f%k ''
    # PS1=$'\n'"%~"$'\n'"%K{$accent} %k%F{$accent}%f "
    PS1='%F{$accent}%f '
    RPROMPT='%~/%'
    RPROMPT+='$GITSTATUS_PROMPT'

}
prompt_themes+=( natalie )
prompt natalie

# stderr in red
export LD_PRELOAD="/lib/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"

# executable paths
export PATH="/home/natalie/.local/bin:$PATH"
export PATH="/home/natalie/Dropbox/Code/Shell:$PATH"
export PATH="/home/natalie/kde/src/kdesrc-build:$PATH"

# functions for opening files and directories
function f () {
    if [[ -d "$1" ]]
    then
        # directory: enter and list contents
        cd "$1" && ls -1 -A -p --group-directories-first --color=auto
    elif [[ -f "$1" ]]
    then
        # file: edit with micro
        micro "$1"
    else
        cd "$1" 2>&1
    fi
}

function o () {
  xdg-open "$@">/dev/null 2>&1
}

# aliases for file operations
alias rm='trash'
alias cp='cp -i'

# aliases for shell scripts
alias lpd='duplex_print_CLI.sh'
alias replace='replace.py'
alias backup-home='rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=.cache /home/natalie/ home/$(date +"%Y-%m-%d")'
alias backup-root='sudo rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=home --exclude=media --exclude=var/temp --exclude=swapfile / root/$(date +"%Y-%m-%d")'
alias kompile='kdesrc-build --no-src --no-include-dependencies --debug'

# aliases for pacman
alias pacsearch='f() { yay -Ss $1 }; f'
alias pacfind='f() { yay -Qs $1; yay -F $1 }; f'
alias pacinstall='f() { sudo pacman -Syy; sudo pacman -S $1 --noconfirm || yay -S $1 --noconfirm }; f'
alias pacuninstall='f() { sudo pacman -R $1 }; f'
alias pacdatabase='sudo pacman -Syy'
alias pacupgrade='yay -Syu --noconfirm; sudo paccache -rk 1'

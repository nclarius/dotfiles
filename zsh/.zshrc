# ~/.zshrc

# key bindings
bindkey '^?'      backward-delete-char          # backspace delete one char backward
bindkey '^[[3~'   delete-char                   # del        delete one char forward
bindkey '^[[H'    beginning-of-line             # home       go to the beginning of line
bindkey '^[[F'    end-of-line                   # end        go to the end of line
bindkey '^[[1;5C' forward-word                  # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                 # ctrl+left  go backward one word
bindkey '^H'      backward-kill-word            # ctrl+bs    delete previous word
bindkey '^[[3;5~' kill-word                     # ctrl+del   delete next word
bindkey '^J'      backward-kill-line            # ctrl+j     delete everything before cursor
# bindkey '^[[A'    up-line-or-history            # up         last command
# bindkey '^[[B'    down-line-or-history          # down       next command
# bindkey '^[[D'    backward-char                 # left       move cursor one char backward
# bindkey '^[[C'    forward-char                  # right      move cursor one char
# bindkey '^[[5~'   up-line-or-history            # pg_up     move cursor one char backward
# bindkey '^[[6~'   down-line-or-history          # pg_dn      move cursor one char forward  

# auto completion
# in-line suggestions
source ~/Dropbox/Code/Shell/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# source '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
# fpath=('/usr/share/zsh/site-functons/'$fpath)
# tab completion
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# sudo completion
zstyle ':completion::complete:*' gain-privileges 1
# completion category headings style
zstyle ':completion:*' format '%F{green}- %d -%f'

# history shared across sessions
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000
setopt INC_APPEND_HISTORY
# setopt SHARE_HISTORY
# setopt appendhistory

# syntax highlighting
source '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

# vscode integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# VCS info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ':%b'
source '/usr/share/zsh/plugins/zsh-gitstatus/gitstatus.prompt.zsh'

# colors
function get_kde_color() {
    IFS="," read -A color <<< $(kreadconfig5 --file kdeglobals --group "$1" --key "$2")
    if [[ $color != \#* ]]; then color=$(printf "#%02x%02x%02x\n" $color); fi
    echo $color
}
accent=$(get_kde_color General AccentColor)
highlight=$(get_kde_color Colors:View DecorationFocus) 
foreground=$(get_kde_color Colors:View ForegroundNormal)
background=$(get_kde_color Colors:View BackgroundNormal)
alternate=$(get_kde_color Colors:View BackgroundAlternate)
inactive=$(get_kde_color Colors:View ForegroundInactive)
selection=$(get_kde_color Colors:Selection BackgroundAlternate)
if [[ $accent == "#000000" ]]; then accent=$highlight; fi

# prompt style
set -o PROMPT_SUBST
autoload -Uz promptinit && promptinit
prompt_natalie_setup() {
    # PS1='%K{$accent}%F{black}%~ %f%k%K{black}%F{$accent}%f%k ''
    # PS1=$'\n'"%~"$'\n'"%K{$accent} %k%F{$accent}%f "
    # PS1='%F{$accent}%f '
    RPROMPT='%~/%'
    RPROMPT+='$GITSTATUS_PROMPT'
}
prompt_themes+=( natalie )
prompt natalie

# stderr in red
export LD_PRELOAD="/lib/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"

# semantic shell integration https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
# place cursor with mouse
_prompt_executing=""
function __prompt_precmd() {
    local ret="$?"
    if test "$_prompt_executing" != "0"
    then
      _PROMPT_SAVE_PS1="$PS1"
      _PROMPT_SAVE_PS2="$PS2"
      # PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
      # PS1:
      # %70F%n@%m%f %39F%$((-GITSTATUS_PROMPT_LEN-1))<…<%~%<<%f${GITSTATUS_PROMPT:+ $GITSTATUS_PROMPT}
      # %F{%(?.76.196)}%#%f 
      PS1=$'%{\e]133;P;k=i\a%}''
%F{$accent}%f '$'%{\e]133;B\a\e]122;> \a%}'
      PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    fi
    if test "$_prompt_executing" != ""
    then
       printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
    fi
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
    _prompt_executing=0
}
function __prompt_preexec() {
    PS1="$_PROMPT_SAVE_PS1"
    PS2="$_PROMPT_SAVE_PS2"
    printf "\033]133;C;\007"
    _prompt_executing=1
}
preexec_functions+=(__prompt_preexec)
precmd_functions+=(__prompt_precmd)

# executable paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Dropbox/Code/Shell:$PATH"

# functions and aliases for file operations
function f () # go to file or directory
{
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
function o () # open file externally
{
  xdg-open "$@">/dev/null 2>&1
}
alias rm='trash'
alias cp='cp -i'

# aliases for pacman
alias pacsearch='f() { yay -Ss $1 }; f'
alias pacfind='f() { yay -Qs $1; yay -F $1 }; f'
alias pacinstall='f() { sudo pacman -Syy; yay -S $1 --noconfirm --sudoloop}; f'
alias pacuninstall='f() { sudo pacman -R $1 }; f'
alias pacdatabase='sudo pacman -Syy'
alias pacupgrade='yay -Syu --noconfirm --sudoloop; sudo paccache -rk 1'

# aliases for shell scripts
alias lpd='duplex_print_CLI.sh'
alias replace='replace.py'
alias backup-home='rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=.cache /home/natalie/ home/$(date +"%Y-%m-%d")'
alias backup-root='sudo rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=home --exclude=media --exclude=var/temp --exclude=swapfile / root/$(date +"%Y-%m-%d")'

# kdesrc-build
export PATH="$HOME/kde/src/kdesrc-build:$PATH"
function kompile
{
    kdesrc-build --no-src --no-include-dependencies --debug $1
}
function _comp_kdesrcbuild  # completion for kdesrc-build
{
  local cur="${COMP_WORDS[COMP_CWORD]}" # get current word
  local modules=$(ls $HOME/kde/src) # get src modules
  local parameters=$(case "$cur" in -*) echo "--async --help --version -v --show-info --initial-setup --author --color --nice= --no-async --no-color --pretend -p --quiet -q --really-quiet --verbose --src-only --build-only --install-only --metadata-only --rebuild-failures --include-dependencies --no-include-dependencies --ignore-modules --no-src --no-build --no-metadata --no-install --no-build-when-unchanged --force-build --debug --query= --no-rebuild-on-fail --refresh-build --reconfigure --resume-from --resume-after --resume --stop-before --stop-after --stop-on-failure --rc-file --print-modules --list-build --dependency-tree --run --build-system-only --install --no-snapshots --delete-my-patches --delete-my-settings --set-module-option-value=";; esac) # define available options
  COMPREPLY=( $(compgen -W "$parameters $modules" -- $cur) ) # return completions matching the current word
  return 0
}
complete -o nospace -F _comp_kdesrcbuild kdesrc-build
complete -o nospace -F _comp_kdesrcbuild kompile

function _comp_kdesrcrun # completion for kdesrc-run 
{
  local cur="${COMP_WORDS[COMP_CWORD]}" # get current word
  if [[ $COMP_CWORD != 1 ]]; then return 0; fi # complete only first arg
  local modules=$(kdesrc-run --list-installed) # get installed modules
  local parameters=$(case "$cur" in -*) echo "-e --exec -f --fork -q --quiet -h --help --list-installed";; esac) # define available options
  COMPREPLY=( $(compgen -W "$parameters ${modules}" -- "$cur") ) # return completions matching the current word
  return 0
}
complete -o nospace -F _comp_kdesrcrun kdesrc-run

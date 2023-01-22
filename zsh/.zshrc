# ~/.zshrc

# auto completion
# completion menu
source ~/Dropbox/Code/Shell/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# fpath=('/usr/share/zsh/site-functons/'$fpath)
# tab completion
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
# match case-insensitive and in substrings
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# sudo completion
zstyle ':completion::complete:*' gain-privileges 1
# completion category headings style
zstyle ':completion:*' format $'\e[3m\e[2m%d\e[0m\e[0m'
# automatically cd to path
# setopt autocd
# completion for all files
alias completions='source /home/natalie/Dropbox/Code/Shell/generate_zsh_completions.sh'
# completion for kdesrc-build
source /home/natalie/Dropbox/Code/kde/src/kdesrc-build/completion.zsh 2>/dev/null

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000
setopt INC_APPEND_HISTORY
setopt histignorealldups

# key bindings for prompt navigation
bindkey '^?'      backward-delete-char   # backspace      delete one char backward
bindkey '^[[3~'   delete-char            # del            delete one char forward
bindkey '^[[H'    beginning-of-line      # home           go to the beginning of line
bindkey '^[[F'    end-of-line            # end            go to the end of line
bindkey '^[[1;5C' forward-word           # ctrl+right     go forward one word
bindkey '^[[1;5D' backward-word          # ctrl+left      go backward one word
bindkey '^H'      backward-kill-word     # ctrl+backspace delete previous word
bindkey '^[[3;5~' kill-word              # ctrl+del       delete next word
bindkey '^J'      backward-kill-line     # ctrl+j         delete everything before cursor

# key bindings for menu navigation
bindkey '^[[A'    up-line-or-history     # up             go to previous command in history
bindkey '^[[B'    down-line-or-history   # down           go to next command in history
bindkey '^[[1;5A' vi-backward-blank-word # ctrl+up        go to previous completion category
bindkey '^[[1;5B' vi-forward-blank-word  # ctrl+down      go to next completion category

# never beep
setopt NO_BEEP

# syntax highlighting
source '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
# stderr in red
export LD_PRELOAD="/lib/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"

# vscode integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# git status
autoload -Uz vcs_info
precmd() { 
    vcs_info 
}
zstyle ':vcs_info:git:*' formats ':%b'
source '/usr/share/zsh/plugins/zsh-gitstatus/gitstatus.prompt.zsh'

# color scheme
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

# prompt
# semantic shell integration: https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/prompts-data/shell-integration.zsh
_prompt_executing=""
function __prompt_precmd() {
    local ret="$?"
    if test "$_prompt_executing" != "0"
    then
      _PROMPT_SAVE_PS1="$PS1"
      _PROMPT_SAVE_PS2="$PS2"
      PS1=$'
%F{$accent}%f '
	  RPROMPT='❯%1d% $GITSTATUS_PROMPT'
      PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
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
export PATH="$HOME/kde/src/kdesrc-build:$PATH"

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
alias cp='cp -i'
alias rm='trash'

# aliases for pacman
alias pacsearch='yay -Ss'
alias pacfind='yay -Qs'
alias pacinstall='sudo pacman -Syy; yay -S --noconfirm --sudoloop'
alias pacuninstall='sudo pacman -Syy; sudo pacman -R'
alias pacdatabase='sudo pacman -Syy'
alias pacupgrade='sudo pacman -Syu --noconfirm --disable-download-timeout; sudo paccache -r -k 1; paccache -r -c ~/.cache/yay'

# aliases for kdesrc-build
alias kompare='kompare -o -'
function kode()
{
    module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
    code "/home/natalie/kde/src/$module"

}
function kompile()
{
    command="kdesrc-build --no-src --no-include-dependencies"
    for arg in "$@"; do
        # replace "." with current directory name
        module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
        option="$module"
        command="$command $option"
    done
    eval "$command"
}
function konfirm()
{
    command="ctest --verbose --output-on-failure --timeout 30"
    for arg in "$@"; do
        module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
        option=$([[ -d "/home/natalie/kde/build/$module" ]] && echo "--test-dir /home/natalie/kde/build/$module" || echo "$arg")
        command="$command $option"
    done
    command="$command | rainbow --green=PASS --red=FAIL!"
    eval "$command"
}

# aliases for shutdown
alias ksm-logout='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout'
alias ksm-shutdown='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndShutdown'
alias ksm-reboot='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndReboot'
alias ksm-lock='qdbus org.kde.screensaver /ScreenSaver org.freedesktop.ScreenSaver.Lock'
alias ksm-sleep='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendToRam'
alias ksm-hibernate='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendToDisk'
alias ksm-suspend='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendHybrid'
alias ksm-dim='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness 0'

# aliases for shell scripts
alias lpd='duplex_print_CLI.sh'
alias replace='replace.py'
alias backup-home='rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=.cache /home/natalie/ home/$(date +"%Y-%m-%d")'
alias backup-root='sudo rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=home --exclude=media --exclude=var/temp --exclude=swapfile / root/$(date +"%Y-%m-%d")'

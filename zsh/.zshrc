# ~/.zshrc

# prompt
# semantic shell integration: https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/prompts-data/shell-integration.zsh
function get_kde_color() {
    IFS="," read -A color <<< $(kreadconfig5 --file kdeglobals --group "$1" --key "$2")
    if [[ $color != \#* ]]; then color=$(printf "#%02x%02x%02x\n" $color); fi
    echo $color
}
accent=$(get_kde_color General AccentColor) && [[  $accent != "#000000" ]] || accent=$(get_kde_color Colors:View DecorationFocus)
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

# completion
# completion menu
source ~/Dropbox/Code/Shell/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# tab completion
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
# match case-insensitive, then partial word, then substring
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+r:|[._-]=* l:|[._-]=*' '+r:|=* l:|=*'
# sudo completion
zstyle ':completion::complete:*' gain-privileges 1
# completion category headings style
zstyle ':completion:*' format $'\e[3m\e[2m%d\e[0m\e[0m'
# automatically cd to path
setopt autocd

# completion sources
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#fpath=(/usr/local/share/zsh-completions $fpath)
fpath=(/usr/share/zsh/site-functions/ $fpath)
# completion for all files
alias completions='source /home/natalie/Dropbox/Code/Shell/generate_zsh_completions.sh'
# completion for kdesrc-build
fpath=(/home/natalie/kde6/src/kdesrc-build/completions/zsh $fpath)
compdef _kdesrc-build kdesrc-build
compdef _kdesrc-build kompile
#source /home/natalie/kde6/src/kdesrc-build/completions/zsh/_kdesrc-build 2>/dev/null
function _comp_kdesrc-build
{
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  # Retrieve source modules through kde/build
  # If the exit status indicates failure, set the wordlist empty to avoid unrelated messages
  local modules
  if ! modules=$(ls $HOME/kde6/build); then modules=""; fi
  # Return completions that match the current word
  COMPREPLY=( $(compgen -W "${modules}" -- "$cur") )
  return 0
}
complete -o nospace -F _comp_kdesrc-build kdesrc-test
complete -o nospace -F _comp_kdesrc-build kdesrc-install

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
#bindkey '^[[A'    up-line-or-history     # up             go to previous command in history
#bindkey '^[[B'    down-line-or-history   # down           go to next command in history
#bindkey '^[[5~'   up-line-or-history     # pg_up          move cursor one char backward
#bindkey '^[[6~'   down-line-or-history   # pg_dn          move cursor one char forward  

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

# autocorrect
eval $(thefuck --alias)
export THEFUCK_REQUIRE_CONFIRMATION='false'
export THEFUCK_EXCLUDE_RULES='git_pull:git_push'

# executable paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Dropbox/Code/Shell:$PATH"
export PATH="$HOME/kde/src/kdesrc-build:$PATH"

# functions and aliases for file operations
function f () # go to file or directory
{
    if [[ -z "$1" ]]
    then
        # no argument/current directory: list contents
        ls -A -p --group-directories-first
    elif [[ -d "$1" ]]
    then
        # directory: enter and list contents
        cd "$1" && ls -A -p --group-directories-first
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
# alias rm='trash'

# aliases for pacman
alias pacsearch='yay -Ss'
alias pacfind='yay -Qs'
alias pacinstall='sudo pacman -Sy; yay -S --noconfirm --sudoloop'
alias pacuninstall='sudo pacman -Sy; sudo pacman -R'
alias pacdatabase='sudo pacman -Sy'
alias pacupgrade='sudo pacman -Syu --noconfirm --disable-download-timeout --ignore=network-manager-sstp && sudo paccache -r -k 1 && paccache -r -c ~/.cache/yay'
alias pacupgradeall='yay -Syu --noconfirm --sudoloop; flatpak update --noninteractive; rm -r ~/.cache/yay'
alias pacupgradable='yay -Sy && yay -Qu && echo $(yay -Qu | wc -l) "packages to upgrade"'

# aliases for kdesrc-build
alias komparediff='kompare -o -'
function kode()
{
    module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
    code "/home/natalie/kde6/src/$module"

}
alias kde5src-build='kdesrc-build --rc-file=/home/natalie/.config/kde5src-buildrc'
alias kdesrc-build='kdesrc-build --rc-file=/home/natalie/.config/kde6src-buildrc'
function kompile()
{
    command="kdesrc-build --rc-file=/home/natalie/.config/kde6src-buildrc --no-src --no-include-dependencies"
    for arg in "$@"; do
        # replace "." with current directory name
        module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
        option="$module"
        command="$command $option"
    done
    command="rainbow --red=error: $command"
    eval "$command"
}

function kdesrc-install()
{
    command="ninja"
    for arg in "$@"; do
        module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
        option=$([[ -d "/home/natalie/kde6/build/$module" ]] && echo "-C /home/natalie/kde6/build/$module install" || echo "$arg")
        command="$command $option"
    done
    eval "$command"
}
function kdesrc-test()
{
    command="ctest --verbose --output-on-failure --timeout 30"
    for arg in "$@"; do
        module=$([ "$arg" = "." ] && echo "${arg/\./"${PWD##*/}"}" || echo "$arg")
        option=$([[ -d "/home/natalie/kde6/build/$module" ]] && echo "--test-dir /home/natalie/kde/build/$module" || echo "$arg")
        command="$command $option"
    done
    command="rainbow --green=PASS --red=FAIL! $command"
    eval "$command"
}
alias konfirm='kdesrc-test'
# konfirm -R 'testPlacement' kwin

# aliases for session management
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

# other aliases
alias driver-libinput='sudo mv /etc/X11/xorg.conf.d/70-synaptics.conf /etc/X11/xorg.conf.d/30-synaptics.conf; sudo mv /usr/share/X11/xorg.conf.d/70-synaptics.conf /usr/share/X11/xorg.conf.d/30-synaptics.conf'
alias driver-synaptics='sudo mv /etc/X11/xorg.conf.d/30-synaptics.conf /etc/X11/xorg.conf.d/70-synaptics.conf'
# /usr/share/X11/xorg.conf.d/
alias zonfig='micro ~/.zshrc'

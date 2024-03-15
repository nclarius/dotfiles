# ~/.zshrc

# prompt

# semantic shell integration: https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/prompts-data/shell-integration.zsh
function get_kde_color() {
    IFS="," read -A color <<< $(kreadconfig5 --file kdeglobals --group "$1" --key "$2")
    if [[ $color != \#* ]]; then color=$(printf "#%02x%02x%02x\n" $color); fi
    echo $color
}
accent=$(get_kde_color General AccentColor) && [[  $accent != "#000000" ]] || accent=$(get_kde_color Colors:View DecorationFocus)
red='\033[0;31m'
fg='\033[0m'
_prompt_executing=""
function __prompt_precmd() {
    local ret="$?"
    if test "$_prompt_executing" != "0"
    then
      _PROMPT_SAVE_PS1="$PS1"
      _PROMPT_SAVE_PS2="$PS2"
      PS1=$'
%F{$accent}%f '
	  RPROMPT='%0/% $GITSTATUS_PROMPT'
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

# completion sources
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#fpath=(/usr/local/share/zsh-completions $fpath)
#fpath=(/usr/share/zsh/site-functions/ $fpath)
#fpath=(/home/natalie/kde/src/kdesrc-build/completions/zsh $fpath)
#source /home/natalie/kde/src/kdesrc-build/completions/zsh/_kdesrc-build 2>/dev/null
fpath=(/home/natalie/kde/usr/share/zsh/site-functions $fpath)
# completion for all files
alias completions='source /home/natalie/Dropbox/Code/Shell/generate_zsh_completions.sh'

# completion menu
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# tab completion
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
compinit -u
# match case-insensitive, then partial word, then substring
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+r:|[._-]=* l:|[._-]=*' '+r:|=* l:|=*'
# sudo completion
zstyle ':completion::complete:*' gain-privileges 1
# completion category headings style
zstyle ':completion:*' format $'\e[3m\e[2m%d\e[0m\e[0m'
# automatically cd to path
setopt autocd
# sort suggestions by most recently accessed
zstyle ':completion:*' file-sort access

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
# stderr output in red
export LD_PRELOAD="/usr/lib/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"

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

# make sudo work with aliases
alias sudo='sudo '

# functions and aliases for file operations
alias ls='ls -A --file-type -h -v --group-directories-first -1'
function f () # go to file or directory
{
    if [[ -z "$1" ]]
    then
        # no argument/current directory: list contents
        ls
    elif [[ -d "$1" ]]
    then
        # directory: enter and list contents
        cd "$1" && ls
    elif [[ -f "$1" ]]
    then
        # file: edit with micro
        micro "$1"
    else
        cd "$1" 2>&1 || return
    fi
}
function o () # open file externally
{
  xdg-open "$@">/dev/null 2>&1
}
alias cp='cp -i -r'
alias mkdir='mkdir -p'
function touchp() { if [[ "$1" == */* ]]; then if [ ! -d "${1%/*}/" ]; then mkdir -p "${1%/*}/"; fi; fi; touch "$1" }
alias touch='touchp'
function cpr() # copy file including parent dirs from source to destination
{
	if [ "$#" -ne 3 ]; then echo "cpr: usage: cpr source-dir file-to-copy destination-dir" >&2; return 1; fi
	if [ ! -d "$1" ]; then echo "${red}cpr: source directory does not exist${fg}" >&2; return 1; fi
	if [ ! -e "$1/$2" ]; then echo "${red}cpr: file to copy does not exist${fg}" >&2; return 1; fi
	if [ ! -d "$3" ]; then echo "${red}cpr: destination directory does not exist${fg}" >&2; return 1; fi
	[[ "$1" == /* ]] && srcdir="$1" || srcdir=$(cd "$(pwd)/$1"; pwd)
	[[ "$3" == /* ]] && destdir="$3" || destdir=$(cd "$(pwd)/$3"; pwd)
	[[ "$2" == */* ]] && cpdir="${2%/*}/" || cpdir=""
	if [ ! -d "$destdir/$cpdir" ]; then mkdir -p "$destdir/$cpdir"; fi
	cp -i -r "$1/$2" "$3/$cpdir"
}
function mvr() # move file including parent dirs from source to destination
{
	if [ "$#" -ne 3 ]; then echo "mvr: usage: mvr source-dir file-to-move destination-dir" >&2; return 1; fi
	if [ ! -d "$1" ]; then echo "${red}mvr: source directory does not exist${fg}" >&2; return 1; fi
	if [ ! -e "$1/$2" ]; then echo "${red}mvr: file to move does not exist${fg}" >&2; return 1; fi
	if [ ! -d "$3" ]; then echo "${red}mvr: destination directory does not exist${fg}" >&2; return 1; fi
	[[ "$1" == /* ]] && srcdir="$1" || srcdir=$(cd "$(pwd)/$1"; pwd)
	[[ "$3" == /* ]] && destdir="$3" || destdir=$(cd "$(pwd)/$3"; pwd)
	[[ "$2" == */* ]] && mvdir="${2%/*}/" || mvdir=""
	if [ ! -d "$destdir/$mvdir" ]; then mkdir -p "$destdir/$mvdir"; fi
	mv -i "$1/$2" "$3/$mvdir"
}
# alias rm='trash -r'

# aliases for pacman
alias pacinfo='pacman -Qi'
alias pacsearch='yay -Ss'
alias pacfind='yay -Qs'
alias pacfile='yay -F'
alias pacinstall='sudo pacman -Sy; yay -S --noconfirm --sudoloop'
alias pacuninstall='sudo pacman -Sy; sudo pacman -R'
alias pacupdatabase='sudo pacman -Sy; sudo pacman -Fy'
alias pacupgradable='yay -Sy && yay -Qu && echo $(yay -Qu | wc -l) "packages to upgrade"'
alias pacupgrade='xdotool key "ctrl+shift+i"; sudo pacman -Fy; kde-inhibit --power sudo pacman -Syu --noconfirm --disable-download-timeout --ignore=network-manager-sstp,pipewire,libpipewire,libcamera,libcamera-ipa && sudo paccache -r -k 1 && paccache -r -c ~/.cache/yay; notify-send "System upgrade finished" -a "pacman" -i update-none; xdotool key "ctrl+shift+i"'
alias pacupgradeall='xdotool key "ctrl+shift+i"; sudo pacman -Fy; kde-inhibit --power yay -Syu --noconfirm --sudoloop --disable-download-timeout --ignore=network-manager-sstp,pipewire,libpipewire,libcamera-ipa && sudo flatpak update --noninteractive && rm -r ~/.cache/yay; notify-send "System upgrade finished" -a "pacman" -i update-none; xdotool key "ctrl+shift+i"'

# aliases for kdesrc-build
function kode()
{
    module=$([ "$arg" = "." ] && echo "${arg/\./"$(basename $(git rev-parse --show-toplevel))"}" || echo "$arg")
    code "/home/natalie/kde/src/$module"
}

export PATH="/home/natalie/kde/src/kde-builder:$PATH"
function _comp_kde_builder_launch
{
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Complete only the first argument
  if [[ $COMP_CWORD != 1 ]]; then
    return 0
  fi

  # Retrieve build modules through kde-builder-launch
  # If the exit status indicates failure, set the wordlist empty to avoid
  # unrelated messages.
  local modules
  if ! modules=$(kde-builder-launch --list-installed);
  then
      modules=""
  fi

  # Return completions that match the current word
  COMPREPLY=( $(compgen -W "${modules}" -- "$cur") )

  return 0
}

## Register autocomplete function
complete -o nospace -F _comp_kde_builder_launch kde-builder-launch

alias kdesrc-build='xdotool key "ctrl+shift+o"; xdotool key "ctrl+shift+d"; ~/kde/usr/bin/kde-inhibit --power kdesrc-build'
alias kdesrc-build-5='xdotool key "ctrl+shift+o"; xdotool key "ctrl+shift+d"; ~/kde/usr/bin/kde-inhibit --power kdesrc-build --rc-file=/home/natalie/.config/kde5src-buildrc'
function kompile()
{
    command="kdesrc-build --no-src --no-include-dependencies"
    for arg in "$@"; do
        # replace "." with current directory name
        module=$([ "$arg" = "." ] && echo "${arg/\./"$(basename $(git rev-parse --show-toplevel))"}" || echo "$arg")
        option="$module"
        command="$command $option"
    done
    command="rainbow --red=error: $command"
    eval "$command"
}
compdef _kdesrc-build kompile

function kdesrc-install()
{
    command="ninja"
    for arg in "$@"; do
        module=$([ "$arg" = "." ] && echo "${arg/\./"$(basename $(git rev-parse --show-toplevel))"}" || echo "$arg")
        option=$([[ -d "/home/natalie/kde/build/$module" ]] && echo "-C /home/natalie/kde/build/$module install" || echo "$arg")
        command="$command $option"
    done
    eval "$command"
}
compdef _kdesrc-build kdesrc-install
#alias kdesrc-install-sessions='~/kde/build/plasma-workspace/login-sessions/install-sessions.sh'

function kdesrc-test()  # usage: konfirm -R 'testPlacement' kwin
{
# 	export PATH=/home/natalie/kde/usr/bin/:$PATH
    command="ctest --verbose --output-on-failure --timeout 300"
    for arg in "$@"; do
        module=$([ "$arg" = "." ] && echo "${arg/\./"$(basename $( git rev-parse --show-toplevel ))"}" || echo "$arg")
        option=$([[ -d "/home/natalie/kde/build/$module" ]] && echo "--test-dir /home/natalie/kde/build/$module" || echo "$arg")
        command="$command $option"
    done
    command="rainbow --green=PASS --red=FAIL! $command"
    eval "$command"
#     PATH=$(echo "$PATH" | sed -e 's/:\/home\/natalie\/kde\/usr\/bin$//')
    rm "/home/natalie/kde/src/$module/appiumtest/utils/__pycache__"
}
alias konfirm='kdesrc-test'
compdef _kdesrc-build kdesrc-test

function kdesrc-mr()
{
    MR=$1
    REPO=$(basename $(git rev-parse --show-toplevel))

    # check out the MR
    git branch --delete "mr/$MR" # delete an existing branch if present, so we can check out the latest version of the MR
    git mr "$MR" # we are now on a branch named "mr/[number] that is based on some base branch

    # build
    kdesrc-build --no-src --no-include-dependencies "$REPO"

    # handle errors
    ERRORFILE=~/kde/src/log/latest/$REPO/error.log
    if [ -f "$ERRORFILE" ]
    then
        cat "$ERRORFILE"
        false
    else
        source ../../build/$REPO/prefix.sh
    fi
}

function kdesrc-locate()
{
	locate -i "/home/natalie/kde/src/*$1*" -l 1 | grep -i -P --color=always "(?<=/home/natalie/kde/src/)[^/]+";
	locate -i "/home/natalie/kde/src/*/*$1*.h" | grep -i -P --color=always "(?<=/home/natalie/kde/src/)[^/]+";
	echo "";
	locate -i "/home/natalie/kde/usr/include/*/*$1*.h" | grep -i -P --color=always "(?<=/home/natalie/kde/usr/include/)(\w|-|/)+(?=/)"
}

# aliases for session start
alias start-plasma-dist-x11='startx /usr/bin/startplasma-x11'
alias start-plasma-dev-x11='startx /home/natalie/kde/usr/lib/libexec/startplasma-dev.sh -x11'
alias start-plasma-dist-wayland='dbus-run-session /usr/bin/startplasma-wayland'
alias start-plasma-dev-wayland='dbus-run-session /home/natalie/kde/usr/lib/libexec/startplasma-dev.sh -wayland'
alias start-gnome-dist-x11='startx /usr/bin/gnome-session'
alias start-gnome-dist-wayland='dbus-run-session /usr/bin/gnome-session'

# aliases for session management
alias ksm-logout='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout'
alias ksm-shutdown='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndShutdown'
alias ksm-reboot='qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndReboot'
alias ksm-lock='qdbus org.kde.screensaver /ScreenSaver org.freedesktop.ScreenSaver.Lock'
alias ksm-sleep='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendToRam'
alias ksm-hibernate='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendToDisk'
alias ksm-suspend='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/SuspendSession org.kde.Solid.PowerManagement.Actions.SuspendSession.suspendHybrid'
alias ksm-blank='sleep 3 & qdbus org.kde.kglobalaccel /component/org_kde_powerdevil org.kde.kglobalaccel.Component.invokeShortcut "Turn Off Screen"'

# aliases for shell scripts
alias lpd='duplex_print_CLI.sh'
alias replace='replace.py'
alias backup-home='rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=.cache /home/natalie/ home/$(date +"%Y-%m-%d")'
alias backup-root='sudo rsync -ahpvxAEHSWX --numeric-ids --progress --stats --exclude=home --exclude=media --exclude=var/temp --exclude=swapfile / root/$(date +"%Y-%m-%d")'

# other aliases
alias touchpaddriver-synaptics='sudo mv /etc/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/30-libinput.conf; sudo mv /etc/X11/xorg.conf.d/xorg.conf.d/30-synaptics.conf /etc/X11/xorg.conf.d/xorg.conf.d/40-synaptics.conf'
alias touchpaddriver-libinput='sudo mv /etc/X11/xorg.conf.d/40-synaptics.conf /etc/X11/xorg.conf.d/30-synaptics.conf; sudo mv /etc/X11/xorg.conf.d/30-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf'
alias restart-powerdevil-dist='systemctl --user restart plasma-powerdevil.service'
alias restart-powerdevil-dev='pkill org_kde_powerde -u $UID; /home/natalie/kde/usr/lib/libexec/org_kde_powerdevil &'
alias grep='grep --color=always'
alias komparediff='~/kde5/usr/bin/kompare -o -'
alias procgrep='ps aux | head -n 1; ps aux | grep -i'
alias zonfig='kwrite ~/Dropbox/Code/dotfiles/zsh/.zshrc'

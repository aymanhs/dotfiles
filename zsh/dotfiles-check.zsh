# Checks the dotfiles repo for upstream and local changes.
# Runs on shell start, then re-arms itself every DOTFILES_CHECK_INTERVAL via
# zsh's `sched` builtin -- no cron, no systemd, and no per-prompt cost beyond
# zsh's own schedule-queue check (the actual work only runs when due). Each
# shell re-arms its own next check, so long-lived sessions keep getting
# checked. The network fetch is separately throttled by a cache-file
# timestamp, shared across all shells, so concurrent sessions don't all fetch
# at once.
#
# The first run is deferred to the first precmd (rather than called directly
# here, at source time) so any output lands after the prompt is up -- p10k's
# instant prompt (set to `verbose`) warns about console output that happens
# during zsh initialization.

zmodload zsh/sched 2>/dev/null

_dotfiles_check() {
  local repo="${DOTFILES_DIR:-$HOME/dotfiles}"
  local interval="${DOTFILES_CHECK_INTERVAL:-3600}" # 1hr
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-check-last"

  sched +"$interval" _dotfiles_check

  [[ -d "$repo/.git" ]] || return

  local now last=0
  now=$(date +%s)
  [[ -f "$cache" ]] && last=$(<"$cache")
  if (( now - last >= interval )); then
    git -C "$repo" fetch --quiet 2>/dev/null
    echo "$now" > "$cache"
  fi

  local ahead behind dirty
  ahead=$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null) || ahead=0
  behind=$(git -C "$repo" rev-list --count 'HEAD..@{u}' 2>/dev/null) || behind=0
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  (( ahead == 0 && behind == 0 && dirty == 0 )) && return

  local -a lines
  lines=("dotfiles:")
  (( behind )) && lines+=("  $behind behind origin")
  (( ahead ))  && lines+=("  $ahead ahead of origin")
  (( dirty ))  && lines+=("  $dirty uncommitted")

  local width=0 l
  for l in "${lines[@]}"; do (( ${#l} > width )) && width=${#l}; done

  local border
  printf -v border '%*s' $(( width + 2 )) ''
  border=${border// /-}

  echo "+${border}+"
  for l in "${lines[@]}"; do
    printf '| %-*s |\n' "$width" "$l"
  done
  echo "+${border}+"
}

autoload -Uz add-zsh-hook

_dotfiles_check_first_precmd() {
  add-zsh-hook -d precmd _dotfiles_check_first_precmd
  _dotfiles_check
}

add-zsh-hook precmd _dotfiles_check_first_precmd

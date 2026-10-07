# Functions without an @credit tag were developed with AI assistance.
# See README for details.

# Directory functions

# @desc: Create a new directory and enter it
# @usage: mkd <directory>
# @credit: https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789
mkd() {
    mkdir -p "$@" && cd "$@"
}

# ---------------------------------------------------------------------------
# macOS utilities

# @desc: Open current directory or file using macOS default application
# @usage: o [path]
# @credit: https://github.com/mathiasbynens/dotfiles
o() {
    if [ $# -eq 0 ]; then
        open .
    else
        open "$@"
    fi
}

# ---------------------------------------------------------------------------

# @desc: Open a man page as a PDF in Preview
# @usage: manpdf <command>
# @credit: https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789
manpdf() {
    man -t "$1" | open -f -a Preview
}

# ---------------------------------------------------------------------------
# File utilities

# @desc: Display file or directory size
# @usage: fs [path]
# @credit: https://github.com/mathiasbynens/dotfiles
fs() {
    if [[ -n "$@" ]]; then
        du -sh "$@"
    else
        du -sh .[^.]* *
    fi
}

# ---------------------------------------------------------------------------

# @desc: Compare original and gzipped file size
# @usage: gz <file>
# @credit: https://github.com/mathiasbynens/dotfiles
gz() {
    local origsize=$(wc -c < "$1")
    local gzipsize=$(gzip -c "$1" | wc -c)
    local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
    printf "orig: %d bytes\n" "$origsize"
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# ---------------------------------------------------------------------------
# Language & translation utilities

# @desc: Validates German text for grammar/style errors via a local LanguageTool server, and translates each error's German explanation into English
# @usage: lt <german text>
# @requires: languagetool (brew install languagetool && brew services start languagetool), jq, translate-shell
lt() {
    if [[ -z "$*" ]]; then
        echo "Usage: lt <German text to check>"
        return 1
    fi

    local resp count
    resp=$(curl -s -X POST 'http://localhost:8081/v2/check' \
        --data-urlencode "language=de-DE" \
        --data-urlencode "text=$*")

    count=$(jq '.matches | length' <<< "$resp")

    if [[ "$count" -eq 0 ]]; then
        echo "No issues found."
        return 0
    fi

    local -a matches
    matches=("${(f)$(jq -c '.matches[]' <<< "$resp")}")

    local match snippet msg_de msg_en suggestions
    for match in "${matches[@]}"; do
        snippet=$(jq -r '.context.text' <<< "$match")
        msg_de=$(jq -r '.message' <<< "$match")
        suggestions=$(jq -r '[.replacements[].value] | join(", ")' <<< "$match")
        msg_en=$(trans -b de:en "$msg_de" 2>/dev/null)

        echo "- $snippet"
        echo "  issue (DE): $msg_de"
        echo "  issue (EN): $msg_en"
        echo "  try: $suggestions"
        echo
    done
}

# ---------------------------------------------------------------------------

# @desc: Quick German-to-English translation via translate-shell. Defaults to
#   trans's native/full output (translation, pronunciation, definitions,
#   examples) since a bare translation alone is thin when learning a
#   language; pass -b for just the bare translation, or -d for a
#   dictionary-style breakdown of a single word
# @usage: td [-b|-d] <german text>
# @requires: translate-shell (brew install translate-shell)
td() {
    local flag=""
    case "$1" in
        -b|-d)
            flag="$1"
            shift
            ;;
    esac

    if [[ -z "$*" ]]; then
        echo "Usage: td [-b|-d] <German text to translate>"
        return 1
    fi

    if [[ -n "$flag" ]]; then
        trans "$flag" de:en "$*"
    else
        trans de:en "$*"
    fi
}

# ---------------------------------------------------------------------------

# @desc: Quick English-to-German translation via translate-shell. Defaults to
#   trans's native/full output (translation, pronunciation, definitions,
#   examples) since a bare translation alone is thin when learning a
#   language; pass -b for just the bare translation, or -d for a
#   dictionary-style breakdown of a single word
# @usage: te [-b|-d] <english text>
# @requires: translate-shell (brew install translate-shell)
te() {
    local flag=""
    case "$1" in
        -b|-d)
            flag="$1"
            shift
            ;;
    esac

    if [[ -z "$*" ]]; then
        echo "Usage: te [-b|-d] <English text to translate>"
        return 1
    fi

    if [[ -n "$flag" ]]; then
        trans "$flag" en:de "$*"
    else
        trans en:de "$*"
    fi
}

# ---------------------------------------------------------------------------

# @desc: Lists all custom functions with their usage and description, parsed from the @desc/@usage tags in this file
# @usage: fndoc
fndoc() {
    local file="$ZSH_CUSTOM/functions.zsh"

    if [[ ! -f "$file" ]]; then
        echo "fndoc: functions file not found at $file"
        return 1
    fi

    # One block per function: name, then usage and description wrapped to the terminal width
    # (column -t kept each function on one long line that the terminal then broke mid-word)
    local c_name="" c_off="" width=${COLUMNS:-80}
    [[ -t 1 ]] && { c_name=$'\e[1;32m'; c_off=$'\e[0m'; }
    (( width < 40 )) && width=80    # COLUMNS can be tiny or unset when piped

    awk -v w="$width" -v cn="$c_name" -v co="$c_off" '
        function wrap(text, ind,    n, i, words, line, pad) {
            pad = sprintf("%" ind "s", "")
            n = split(text, words, " ")
            line = pad
            for (i = 1; i <= n; i++) {
                if (length(line) + length(words[i]) + 1 > w && line != pad) {
                    print line
                    line = pad
                }
                line = line (line == pad ? "" : " ") words[i]
            }
            if (line != pad) print line
        }
        /^# @desc:/  { sub(/^# @desc:[ ]?/, ""); desc = $0; more = 1; next }
        /^#   /      { if (more) { sub(/^#[ ]+/, ""); desc = desc " " $0 }; next }
        { more = 0 }
        /^# @usage:/ { sub(/^# @usage:[ ]?/, ""); usage = $0 }
        /^[a-zA-Z_][a-zA-Z0-9_-]*\(\) \{/ {
            name = $0
            sub(/\(\).*/, "", name)
            print cn name co
            if (usage != "") wrap("usage: " usage, 4)
            if (desc != "")  wrap(desc, 4)
            desc = ""; usage = ""
        }
    ' "$file"
}

# ---------------------------------------------------------------------------

# @desc: Audits installed Homebrew packages against this machine's active Brewfiles (shared Brewfile plus the role-specific Brewfile.dev or Brewfile.spare), listing anything installed but not tracked in either, and anything tracked but not installed
# @usage: dotfiles-audit
dotfiles-audit() {
    local dotfiles="$HOME/.dotfiles"
    local profile

    if [[ -f "$HOME/.dotfiles-profile" ]]; then
        profile=$(cat "$HOME/.dotfiles-profile" | tr -d '[:space:]')
    else
        case "$(uname -m)" in
            arm64) profile="dev" ;;
            *)     profile="spare" ;;
        esac
    fi

    local profile_file="$dotfiles/Brewfile.$profile"
    local files=("$dotfiles/Brewfile")
    [[ -f "$profile_file" ]] && files+=("$profile_file")

    # Every brew/cask name declared across the shared file + this machine's role file, normalized to the final path segment so tap-qualified names (e.g. teamookla/speedtest/speedtest) compare equal regardless of qualification
    local declared
    declared=$(grep -hE '^(brew|cask) ' "${files[@]}" | sed -E 's/^(brew|cask) "([^"]+)".*/\2/' | sed -E 's#.*/##' | sort -u)

    echo "Installed but not tracked in Brewfile or Brewfile.$profile:"
    echo "--- Formulae (explicitly installed only, not auto-pulled dependencies) ---"
    comm -23 <(brew leaves | sed -E 's#.*/##' | sort) <(echo "$declared")
    echo "--- Casks ---"
    comm -23 <(brew list --cask | sed -E 's#.*/##' | sort) <(echo "$declared")

    # The reverse direction: declared but not installed, e.g. a package removed with brew uninstall whose Brewfile line was left behind. Compared against every installed formula (not only leaves), since a declared formula may be installed as another package's dependency; formulae and casks are checked separately
    local declared_brews declared_casks
    declared_brews=$(grep -hE '^brew ' "${files[@]}" | sed -E 's/^brew "([^"]+)".*/\1/' | sed -E 's#.*/##' | sort -u)
    declared_casks=$(grep -hE '^cask ' "${files[@]}" | sed -E 's/^cask "([^"]+)".*/\1/' | sed -E 's#.*/##' | sort -u)

    echo
    echo "Tracked in Brewfile or Brewfile.$profile but not installed:"
    echo "--- Formulae ---"
    comm -13 <(brew list --formula | sed -E 's#.*/##' | sort) <(echo "$declared_brews")
    echo "--- Casks ---"
    comm -13 <(brew list --cask | sed -E 's#.*/##' | sort) <(echo "$declared_casks")
}

# ---------------------------------------------------------------------------

# @desc: Lists every alias currently loaded in this shell, grouped by where it was defined (each enabled Oh My Zsh plugin, OMZ core lib, or the custom aliases.zsh); no args shows groups with counts. -t ranks your most-used aliases from shell history with a trend, -m lists full commands you typed although an alias exists
# @usage: aliasdoc [group | keyword | -s <keyword> | -a | -t [N] [-d DAYS] | -m [N] [-d DAYS] | -h]
aliasdoc() {
    case "$1" in
        -h|--help)
            cat <<'EOF'
aliasdoc - browse every alias loaded in this shell, grouped by where it was defined
(each enabled Oh My Zsh plugin, omz-core, or custom/aliases.zsh)

Usage: aliasdoc [group | keyword | -s <keyword> | -a | -t [N] [-d DAYS] | -m [N] [-d DAYS] | -h]

  (no args)      list the groups with how many aliases each has
  <group>        show the aliases of one group
  <keyword>      if it is not a group name, search alias names and expansions
  -s <keyword>   force a search, even if the word is also a group name
  -a, --all      list every alias, grouped, through a pager (q to quit)
  -t [N]         top N most-used aliases (default 15) from the shell history,
                 with a trend and how many aliases are never used
  -m [N]         top N "missed shortcuts" (default 15): full commands typed
                 although an alias exists, e.g. "git status" -> gst
  -d DAYS        with -t: trend window, last DAYS vs the DAYS before (default 30)
                 with -m: only look at the last DAYS days (default: all history)
  -h, --help     show this help

Examples:
  aliasdoc               which groups exist?
  aliasdoc git           all git aliases
  aliasdoc checkout      every alias whose name or command contains "checkout"
  aliasdoc -s git        search for the word "git" across all groups,
                         instead of showing the git group
  aliasdoc -t            the 15 most-used aliases
  aliasdoc -t 5 -d 7     top 5, trend over the last 7 days
  aliasdoc -m -d 14      aliases worth learning, from the last two weeks

Notes:
  - An exact group name always wins over a search; use -s to override.
  - Matches are highlighted; colors are off when output is piped.
  - -t and -m read $HISTFILE, so they only see what it keeps (SAVEHIST lines);
    only the first word of a command is counted (a leading sudo is
    ignored), so "a && b" counts "a".
  - After editing aliases or plugins, run 'reload' to refresh the list.
EOF
            return 0
            ;;
    esac

    # Map each alias name to the group (plugin) whose source file defines it. Aliases live only in shell memory, so the only way to learn their origin is to scan the source files for "alias name=" lines.
    local -A owner
    local group f name
    local -a srcs
    for group in $plugins; do
        srcs=($ZSH_CUSTOM/plugins/$group/*.zsh(N) $ZSH/plugins/$group/*.zsh(N))
        for f in $srcs; do
            for name in ${(f)"$(grep -oE '(^|&&|\|\|)[[:space:]]*alias( +-[gsm])* +[^=[:space:]]+=' "$f" | sed -E 's/^.*alias( +-[gsm])* +//; s/=$//; s/^["'\'']//; s/["'\'']$//')"}; do
                [[ -z ${owner[$name]} ]] && owner[$name]=$group
            done
        done
    done
    for f in $ZSH/lib/*.zsh(N); do
        for name in ${(f)"$(grep -oE '(^|&&|\|\|)[[:space:]]*alias( +-[gsm])* +[^=[:space:]]+=' "$f" | sed -E 's/^.*alias( +-[gsm])* +//; s/=$//')"}; do
            [[ -z ${owner[$name]} ]] && owner[$name]="omz-core"
        done
    done
    # Custom file is read last so a custom definition wins when it overrides an OMZ alias
    for name in ${(f)"$(grep -oE '(^|&&|\|\|)[[:space:]]*alias( +-[gsm])* +[^=[:space:]]+=' "$ZSH_CUSTOM/aliases.zsh" | sed -E 's/^.*alias( +-[gsm])* +//; s/=$//')"}; do
        owner[$name]="custom"
    done

    # One tab-separated row per live alias: group, name, expansion
    local rows
    rows=$(for name in ${(ko)aliases}; do
        printf "%s\t%s\t%s\n" "${owner[$name]:-other}" "$name" "${aliases[$name]//$'\n'/ }"
    done | sort -t$'\t' -k1,1 -k2,2)

    # Colors only when writing to a terminal, so piping the output stays clean. The check runs here, before any pipe is set up.
    local c_head="" c_name="" c_hit="" c_off="" c_dim="" c_up="" c_down="" c_bar=""
    if [[ -t 1 ]]; then
        c_head=$'\e[1;38;5;160m'; c_name=$'\e[1;32m'; c_hit=$'\e[1;4;38;5;33m'; c_off=$'\e[0m'
        c_dim=$'\e[2m'; c_up=$'\e[32m'; c_down=$'\e[31m'; c_bar=$'\e[38;5;33m'
    fi

    # Renders rows as: heading per group, then indented "name  = expansion". Pads names itself (column -t would count the invisible color codes as width and misalign). Optional vars: only = show one group, kw = case-insensitive match on name/expansion, highlighted.
    local render='
        function hl(s, base,   i, out, l, k) {
            if (kw == "") return base s o
            k = tolower(kw); l = tolower(s); out = ""
            while ((i = index(l, k)) > 0) {
                out = out base substr(s, 1, i - 1) o t substr(s, i, length(kw)) o
                s = substr(s, i + length(kw)); l = tolower(s)
            }
            return out base s o
        }
        only != "" && $1 != only { next }
        kw != "" && index(tolower($2), tolower(kw)) == 0 && index(tolower($3), tolower(kw)) == 0 { next }
        { n++; g[n] = $1; nm[n] = $2; ex[n] = $3; if (length($2) > w) w = length($2) }
        END {
            if (n == 0) { print "No aliases found."; exit }
            for (i = 1; i <= n; i++) {
                if (g[i] != last) { last = g[i]; printf "%s%s[%s]%s\n", (i > 1 ? "\n" : ""), h, g[i], o }
                pad = ""; for (j = length(nm[i]); j < w; j++) pad = pad " "
                printf "  %s%s = %s\n", hl(nm[i], c), pad, hl(ex[i], "")
            }
        }'
    local -a awkvars=(-F'\t' -v h="$c_head" -v c="$c_name" -v t="$c_hit" -v o="$c_off")

    # Usage statistics from the shell history. Reads two inputs: the alias rows, then the history file (extended format ": <epoch>:0;<command>"; continuation lines are skipped). mode=t counts how often each alias is typed (first word, optional sudo) with a trend of the last <days> days against the <days> before; mode=m finds full commands that match an alias expansion (longest expansion wins) although the alias was not used.
    local stats='
        function padr(s, w,   r, j) { r = s; for (j = length(s); j < w; j++) r = r " "; return r }
        function padl(s, w,   r, j) { r = s; for (j = length(s); j < w; j++) r = " " r; return r }
        function when(t,   dd) { dd = int((now - t) / 86400); return (dd == 0) ? "today" : dd "d ago" }
        FNR == NR {
            isal[$2] = 1; ex[$2] = $3; total++
            if (mode == "m" && index($3, " ") > 0 && length($2) < length($3)) {
                names[$3] = ($3 in names) ? names[$3] ", " $2 : $2
                if (!($3 in seen)) { seen[$3] = 1; split($3, fwp, " "); cand[fwp[1]] = cand[fwp[1]] "\n" $3 }
            }
            next
        }
        {
            raw++
            if ($0 !~ /^: [0-9]+:[0-9]+;/) next
            match($0, /^: [0-9]+/); ts = substr($0, 3, RLENGTH - 2) + 0
            cmd = substr($0, index($0, ";") + 1)
            sub(/^[ \t]+/, "", cmd); sub(/[ \t]+$/, "", cmd)
            if (cmd == "") next
            lines++; if (min == 0 || ts < min) min = ts
            age = now - ts
            cc = cmd; sub(/^sudo[ \t]+/, "", cc)
            split(cc, wd, /[ \t]+/); w = wd[1]
            if (mode == "m") {
                if (days > 0 && age > days * 86400) next
                if (!(w in cand)) next
                if (!(cc in memo)) {
                    nc = split(cand[w], cl, "\n"); best = ""
                    for (k = 2; k <= nc; k++) { e = cl[k]; if (length(e) > length(best) && (cc == e || index(cc, e " ") == 1)) best = e }
                    memo[cc] = best
                }
                best = memo[cc]
                if (best != "") { miss[best]++; if (ts > lastm[best]) lastm[best] = ts }
                next
            }
            if (w in isal) {
                cnt[w]++; if (ts > last[w]) last[w] = ts
                if (age <= days * 86400) rec[w]++
                else if (age <= 2 * days * 86400) prev[w]++
            }
        }
        END {
            if (lines == 0) {
                print (raw > 0) ? "No timestamped history found: -t and -m need EXTENDED_HISTORY (lines like \": 1700000000:0;cmd\")." : "No history found."
                exit
            }
            span = int((now - min) / 86400)
            if (mode == "m") {
                win = (days > 0) ? "last " days " days" : "all history, " span " days"
                cw = 5; mw = 13
                while (shown < n) {
                    best = ""; bc = 0
                    for (e in miss) if (!(e in done) && (miss[e] > bc || (miss[e] == bc && best != "" && e < best))) { best = e; bc = miss[e] }
                    if (best == "") break
                    done[best] = 1; order[++shown] = best
                    if (length(best) > mw) mw = length(best)
                    if (length(bc) > cw) cw = length(bc)
                }
                if (shown == 0) { print "No missed shortcuts found (" win ")."; exit }
                printf "%sFull commands typed although an alias exists%s (top %d, %s)\n", h, o, shown, win
                print dm "  " padl("COUNT", cw + 2) "  " padr("LAST TYPED", 10) "  " padr("TYPED IN FULL", mw) "      ALIAS" o
                for (i = 1; i <= shown; i++) {
                    e = order[i]
                    print "  " padl(miss[e] " x", cw + 2) "  " dm padr(when(lastm[e]), 10) o "  " padr(e, mw) "  ->  " c names[e] o
                }
                exit
            }
            for (a in cnt) used++
            if (!used) { print "No alias usage found in history."; exit }
            nw = 5; cw = 5; tw = 5
            full = (span >= 2 * days); part = (span > days); pd = full ? days : span - days
            while (shown < n) {
                best = ""; bc = 0
                for (a in cnt) if (!(a in done) && (cnt[a] > bc || (cnt[a] == bc && best != "" && a < best))) { best = a; bc = cnt[a] }
                if (best == "") break
                done[best] = 1; order[++shown] = best
                trs[best] = part ? (rec[best] + 0) "/" (prev[best] + 0) : (rec[best] + 0) "/-"
                if (length(best) > nw) nw = length(best)
                if (length(bc) > cw) cw = length(bc)
                if (length(trs[best]) + 2 > tw) tw = length(trs[best]) + 2
            }
            maxc = cnt[order[1]]
            printf "%sTop %d most-used aliases%s\n", h, shown, o
            printf "%shistory: %d commands over %d days; trend = last %d days / previous %d days%s%s\n", dm, lines, span, days, days, (full ? "" : (part ? " (previous window only partly covered: arrows compare per-day rates)" : " (history is no longer than one window, so no trend yet)")), o
            print dm "  " padr("ALIAS", nw) "  " padr("USAGE", 16) " " padl("COUNT", cw) "  " padr("TREND", tw) "  " padr("LAST USED", 9) "  COMMAND" o
            for (i = 1; i <= shown; i++) {
                a = order[i]
                bl = int(cnt[a] * 16 / maxc + 0.5); if (bl < 1) bl = 1
                bar = ""; for (j = 0; j < bl; j++) bar = bar "▆"
                r = rec[a] + 0; p = prev[a] + 0
                if (!part) ar = dm "-"; else if (r * pd > p * days) ar = up "▲"; else if (r * pd < p * days) ar = dn "▼"; else ar = dm "="
                print "  " c padr(a, nw) o "  " bar_c bar o padr("", 16 - bl) " " padl(cnt[a], cw) "  " ar o " " padr(trs[a], tw - 2) "  " dm padr(when(last[a]), 9) o "  " dm ex[a] o
            }
            printf "\n%d of %d aliases never used in this history.\n", total - used, total
        }'

    case "$1" in
        "")
            echo "Alias groups (run 'aliasdoc <group>' to see one, 'aliasdoc -s <word>' to search):"
            print -r -- "$rows" | cut -f1 | uniq -c | awk -v h="$c_head" -v o="$c_off" '
                { g[NR] = $2; n[NR] = $1; if (length($2) > w) w = length($2) }
                END { for (i = 1; i <= NR; i++) { pad = ""; for (j = length(g[i]); j < w; j++) pad = pad " "; printf "  %s%s%s%s  %s\n", h, g[i], o, pad, n[i] } }'
            ;;
        -a|--all)
            # less needs -R to pass the colors through instead of showing raw codes
            print -r -- "$rows" | awk "${awkvars[@]}" "$render" | LESS="${LESS:--R}" ${PAGER:-less}
            ;;
        -t|--top|-m|--missed)
            local mode=t n=15 days=""
            [[ "$1" == -m || "$1" == --missed ]] && mode=m
            shift
            while (( $# )); do
                case "$1" in
                    -d)
                        if [[ "$2" != <-> || "$2" -lt 1 ]]; then
                            echo "aliasdoc: -d needs a number of days, e.g. -d 7"
                            return 1
                        fi
                        days=$2; shift 2
                        ;;
                    <1->) n=$1; shift ;;
                    *)
                        echo "aliasdoc: unexpected argument '$1' (see 'aliasdoc -h')"
                        return 1
                        ;;
                esac
            done
            # Trend window defaults to 30 days; missed shortcuts default to the whole history
            [[ -z "$days" ]] && { [[ $mode == t ]] && days=30 || days=0 }
            if [[ ! -r "$HISTFILE" ]]; then
                echo "aliasdoc: history file not found ($HISTFILE)"
                return 1
            fi
            # LC_ALL=C: zsh stores some non-ASCII bytes in history in a form macOS awk rejects as invalid UTF-8
            LC_ALL=C awk "${awkvars[@]}" -v mode="$mode" -v n="$n" -v days="$days" -v now="$(date +%s)" \
                -v dm="$c_dim" -v up="$c_up" -v dn="$c_down" -v bar_c="$c_bar" \
                "$stats" <(print -r -- "$rows") "$HISTFILE"
            ;;
        -s|--search)
            if [[ -z "$2" ]]; then
                echo "Usage: aliasdoc -s <keyword>"
                return 1
            fi
            print -r -- "$rows" | awk "${awkvars[@]}" -v kw="$2" "$render"
            ;;
        *)
            # An exact group name shows that group; anything else is treated as a search keyword
            if print -r -- "$rows" | cut -f1 | grep -qxF -- "$1"; then
                print -r -- "$rows" | awk "${awkvars[@]}" -v only="$1" "$render"
            else
                print -r -- "$rows" | awk "${awkvars[@]}" -v kw="$1" "$render"
            fi
            ;;
    esac
}

# ---------------------------------------------------------------------------

# @desc: Switches the missed-alias reminder on or off (it is on by default); the choice is remembered across shells via a marker file
# @usage: aliasmiss [on | off | status]
aliasmiss() {
    local flag="${XDG_STATE_HOME:-$HOME/.local/state}/aliasmiss.off"

    case "${1:-status}" in
        on)
            rm -f -- "$flag"
            echo "aliasmiss: on"
            ;;
        off)
            mkdir -p -- "${flag:h}" && : >| "$flag"
            echo "aliasmiss: off"
            ;;
        status)
            [[ -e "$flag" ]] && echo "aliasmiss: off" || echo "aliasmiss: on"
            ;;
        *)
            echo "Usage: aliasmiss [on | off | status]"
            return 1
            ;;
    esac
}

# @desc: Runs before each command (after alias-finder): when the command was typed in full although an alias exists, prints how many times it was typed in full in the last 7 days (shown from the 2nd time); toggled by aliasmiss
# @usage: runs automatically via the preexec hook, no direct call needed
_aliasmiss_hook() {
    [[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/aliasmiss.off" ]] && return

    local line="${1//$'\n'/ }" cand name n count
    local -a words=( ${=line} )
    (( $#words )) || return

    # Like alias-finder: drop trailing words until what is left is exactly an alias expansion
    for (( n = $#words; n >= 1; n-- )); do
        cand="${(j: :)words[1,n]}"
        name="${(k)aliases[(re)$cand]}"
        [[ -n "$name" ]] && break
    done
    [[ -n "$name" ]] || return

    # Typed text in history (the current line is already in it), within the last 7 days.
    # fc must write to a plain file: piped or in $(...) it runs ~40x slower in a subshell, and only the
    # most recent 3000 entries are listed so the cost stays flat however large the history grows.
    local tmp="${TMPDIR:-/tmp}/aliasmiss.$$"
    fc -l -t %s $(( HISTCMD > 3000 ? HISTCMD - 3000 : 0 )) >| "$tmp" 2>/dev/null
    count=$(AM_CMD="$cand" LC_ALL=C awk -v since=$(( EPOCHSECONDS - 7 * 86400 )) '
        BEGIN { e = ENVIRON["AM_CMD"] }
        /^ *[0-9]+\*? +[0-9]+ / {
            t = $2; sub(/^ *[0-9]+\*? +[0-9]+ +/, "")
            if (t >= since && ($0 == e || index($0, e " ") == 1)) n++
        }
        END { print n + 0 }' "$tmp")
    rm -f -- "$tmp"

    (( count >= 2 )) && print -P "%F{172}  ↳ '$name' missed: typed '$cand' in full ${count}x in the last 7 days%f"
}

zmodload zsh/datetime    # provides EPOCHSECONDS, used for the 7-day window
autoload -U add-zsh-hook
add-zsh-hook preexec _aliasmiss_hook

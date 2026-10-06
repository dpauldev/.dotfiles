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

    {
        printf "NAME\tUSAGE\tDESCRIPTION\n"
        printf "----\t-----\t-----------\n"
        awk '
            /^# @desc:/  { sub(/^# @desc:[ ]?/, ""); desc = $0 }
            /^# @usage:/ { sub(/^# @usage:[ ]?/, ""); usage = $0 }
            /^[a-zA-Z_][a-zA-Z0-9_-]*\(\) \{/ {
                name = $0
                sub(/\(\).*/, "", name)
                printf "%s\t%s\t%s\n", name, usage, desc
                desc = ""; usage = ""
            }
        ' "$file"
    } | column -t -s $'\t'
}

# ---------------------------------------------------------------------------

# @desc: Audits installed Homebrew packages against this machine's active Brewfiles (shared Brewfile plus the role-specific Brewfile.dev or Brewfile.spare), listing anything installed but not tracked in either
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
}

# ---------------------------------------------------------------------------

# @desc: Lists every alias currently loaded in this shell, grouped by where it was defined (each enabled Oh My Zsh plugin, OMZ core lib, or your own aliases.zsh); no args shows groups with counts
# @usage: aliasdoc [group | keyword | -s <keyword> | -a | -h]
aliasdoc() {
    case "$1" in
        -h|--help)
            cat <<'EOF'
aliasdoc - browse every alias loaded in this shell, grouped by where it was defined
(each enabled Oh My Zsh plugin, omz-core, or your own custom/aliases.zsh)

Usage: aliasdoc [group | keyword | -s <keyword> | -a | -h]

  (no args)      list the groups with how many aliases each has
  <group>        show the aliases of one group
  <keyword>      if it is not a group name, search alias names and expansions
  -s <keyword>   force a search, even if the word is also a group name
  -a, --all      list every alias, grouped, through a pager (q to quit)
  -h, --help     show this help

Examples:
  aliasdoc               which groups exist?
  aliasdoc git           all git aliases
  aliasdoc checkout      every alias whose name or command contains "checkout"
  aliasdoc -s git        search for the word "git" across all groups,
                         instead of showing the git group

Notes:
  - An exact group name always wins over a search; use -s to override.
  - Matches are highlighted; colors are off when output is piped.
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
    # Custom file is read last so your own definition wins when you override an OMZ alias
    for name in ${(f)"$(grep -oE '(^|&&|\|\|)[[:space:]]*alias( +-[gsm])* +[^=[:space:]]+=' "$ZSH_CUSTOM/aliases.zsh" | sed -E 's/^.*alias( +-[gsm])* +//; s/=$//')"}; do
        owner[$name]="custom"
    done

    # One tab-separated row per live alias: group, name, expansion
    local rows
    rows=$(for name in ${(ko)aliases}; do
        printf "%s\t%s\t%s\n" "${owner[$name]:-other}" "$name" "${aliases[$name]//$'\n'/ }"
    done | sort -t$'\t' -k1,1 -k2,2)

    # Colors only when writing to a terminal, so piping the output stays clean. The check runs here, before any pipe is set up.
    local c_head="" c_name="" c_hit="" c_off=""
    if [[ -t 1 ]]; then
        c_head=$'\e[1;38;5;160m'; c_name=$'\e[1;32m'; c_hit=$'\e[1;4;38;5;33m'; c_off=$'\e[0m'
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

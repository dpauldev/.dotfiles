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
        du -sh .
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

# @desc: Quick German-to-English translation via translate-shell
# @usage: td <german text>
# @requires: translate-shell (brew install translate-shell)
td() {
    if [[ -z "$*" ]]; then
        echo "Usage: td <German text to translate>"
        return 1
    fi
    trans -b de:en "$*"
}

# ---------------------------------------------------------------------------

# @desc: Quick English-to-German translation via translate-shell
# @usage: te <english text>
# @requires: translate-shell (brew install translate-shell)
te() {
    if [[ -z "$*" ]]; then
        echo "Usage: te <English text to translate>"
        return 1
    fi
    trans -b en:de "$*"
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
            /^[a-zA-Z_][a-zA-Z0-9_]*\(\) \{/ {
                name = $0
                sub(/\(\).*/, "", name)
                printf "%s\t%s\t%s\n", name, usage, desc
                desc = ""; usage = ""
            }
        ' "$file"
    } | column -t -s $'\t'
}

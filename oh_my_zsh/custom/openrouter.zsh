# OpenRouter: separate Claude Code launcher, kept apart from functions.zsh.
# Plain `claude` is untouched (normal Anthropic login and picker); only `claude-or` routes through OpenRouter.
# The key is read from the macOS Keychain at launch, so nothing secret lives in this file.
# One-time setup: security add-generic-password -a "$USER" -s openrouter -w
# The model list lives in openrouter-models.conf next to this file; edit that, not this function.

# @desc: Launch Claude Code through OpenRouter with a /model picker built from openrouter-models.conf
# @usage: claude-or [claude args]
# @requires: OpenRouter key in Keychain (service "openrouter"); openrouter-models.conf; Claude Code v2.1.242+ for modelPicker
claude-or() {
    # Config file location; override by setting CLAUDE_OR_MODELS to another path
    local conf="${CLAUDE_OR_MODELS:-${ZSH_CUSTOM:-$HOME/.dotfiles/oh_my_zsh/custom}/openrouter-models.conf}"
    if [[ ! -r "$conf" ]]; then
        echo "claude-or: model list not found at $conf"
        return 1
    fi

    local key
    key=$(security find-generic-password -s openrouter -w 2>/dev/null) || {
        echo "claude-or: no OpenRouter key in Keychain. Add it with:"
        echo "  security add-generic-password -a \"\$USER\" -s openrouter -w"
        return 1
    }

    # Build the modelPicker JSON from the config rows ("ID|Label|Description"), skipping blank and # lines
    # The first row's ID becomes the starting model
    # replaceBuiltInOptions hides the 10+ Anthropic rows: the picker shows only these rows, plus Default and the current model
    # Comment detection avoids the [[:space:]]# glob, which only works when EXTENDED_GLOB is set (it is not in every shell)
    local start="" rows="" line id trimmed
    local -a p
    for line in "${(@f)$(<"$conf")}"; do
        trimmed="${line#"${line%%[![:space:]]*}"}"
        [[ -z "$trimmed" || "$trimmed" == \#* ]] && continue
        p=("${(@s:|:)line}")
        id="${p[1]//[[:space:]]/}"
        [[ -z "$id" ]] && continue
        [[ -z "$start" ]] && start="$id"
        rows+="${rows:+,}{\"model\":\"${id}\",\"label\":\"${p[2]:-$id}\",\"description\":\"${p[3]}\"}"
    done
    if [[ -z "$start" ]]; then
        echo "claude-or: no models found in $conf"
        return 1
    fi
    local picker="{\"modelPicker\":{\"replaceBuiltInOptions\":true,\"options\":[${rows}]}}"

    # The three slot variables point Default and background tasks at the starting model, so nothing asks Anthropic for a model it can't serve
    # `command` skips any alias or function named claude
    ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
    ANTHROPIC_AUTH_TOKEN="$key" \
    ANTHROPIC_API_KEY="" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="$start" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="$start" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="$start" \
        command claude --model "$start" --settings "$picker" "$@"
}

# Directory functions

# Create a new directory and enter it
# Credit:
# https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789
mkd() {
    mkdir -p "$@" && cd "$@"
}


# macOS utilities

# Open current directory or file using macOS default application
# Credit:
# https://github.com/mathiasbynens/dotfiles
o() {
    if [ $# -eq 0 ]; then
        open .
    else
        open "$@"
    fi
}


# Open man page as PDF in Preview
# Credit:
# https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789
manpdf() {
    man -t "$1" | open -f -a Preview
}


# File utilities

# Display file or directory size
# Credit:
# https://github.com/mathiasbynens/dotfiles
fs() {
    if [[ -n "$@" ]]; then
        du -sh "$@"
    else
        du -sh .
    fi
}


# Compare original and gzipped file size
# Credit:
# https://github.com/mathiasbynens/dotfiles
gz() {
    local origsize=$(wc -c < "$1")
    local gzipsize=$(gzip -c "$1" | wc -c)
    local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)

    printf "orig: %d bytes\n" "$origsize"
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

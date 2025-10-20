#!/usr/bin/env bash

# ---- functions above ----
save_file() {
    mv tmp.json Phrases.json
}

new_p() {
    local phrase="$1"
    jq --arg phrase "$phrase" '
        .Phrases += [{"Phrase": $phrase, "Variants": [], "Patterns": []}]
        | .Phrases |= sort_by(.Phrase)
    ' Phrases.json > tmp.json && save_file
}

new_v() {
    local phrase="$1"
    local variant="$2"
    jq --arg phrase "$phrase" --arg variant "$variant" '
        .Phrases |= map(
            if .Phrase == $phrase then
                .Variants += [$variant]
                | .Variants |= (sort | unique)
            else
                .
            end
        )
        | .Phrases |= sort_by(.Phrase)
    ' Phrases.json > tmp.json && save_file
}

new_pt() {
    local phrase="$1"
    local pattern="$2"
    jq --arg phrase "$phrase" --arg pattern "$pattern" '
        .Phrases |= map(
            if .Phrase == $phrase then
                .Patterns += [$pattern]
                | .Patterns |= (sort | unique)
            else
                .
            end
        )
        | .Phrases |= sort_by(.Phrase)
    ' Phrases.json > tmp.json && save_file
}

del_p() {
    local phrase="$1"
    jq --arg phrase "$phrase" '
        .Phrases |= map(select(.Phrase != $phrase))
        | .Phrases |= sort_by(.Phrase)
    ' Phrases.json > tmp.json && save_file
}

del_v() {
    local phrase="$1"
    local variant="$2"
    jq --arg phrase "$phrase" --arg variant "$variant" '
        .Phrases |= map(
            if .Phrase == $phrase then
                .Variants |= map(select(. != $variant))
            else
                .
            end
        )
        | .Phrases |= sort_by(.Phrase)
    ' Phrases.json > tmp.json && save_file
}

search_p() {
    local search_term="$1"
    jq --arg search_term "$search_term" '
        .Phrases[] | select(.Phrase | test($search_term; "i"))
    ' Phrases.json
}


cmd="$1"
shift
case "$cmd" in
  new_p)   new_p "$@" ;;
  new_v)   new_v "$@" ;;
  new_pt)  new_pt "$@" ;;
  del_p)   del_p "$@" ;;
  del_v)   del_v "$@" ;;
  search_p) search_p "$@" ;;
  *) echo "Unknown command: $cmd" >&2; exit 1 ;;
esac

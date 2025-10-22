#!/usr/bin/env bash

MAIN_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$MAIN_SCRIPT")
json="$SCRIPT_DIR/Phrases.json"
tempJson="$SCRIPT_DIR/tmp.json"

save_file() {
    mv "$tempJson" "$json"

    jq -c -M . "$json" > "$tempJson" && mv "$tempJson" "$json"
}

newp() {
    local phrase="$1"
    jq --arg phrase "$phrase" '
        .Phrases += [{"Phrase": $phrase, "Variants": [], "Patterns": []}]
        | .Phrases |= sort_by(.Phrase)
    ' "$json" > "$tempJson" && save_file
}

newv() {
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
    ' "$json" > "$tempJson" && save_file
}

newpt() {
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
    ' "$json" > "$tempJson" && save_file
}

newh() {
    local phrase="$1"
    local href="$2"

    jq --arg phrase "$phrase" --arg href "$href" '
        .Phrases |= map(
            if .Phrase == $phrase then
                .HREF += [$href]
                | .HREF |= (sort | unique)
            else
                .
            end
        )
        | .Phrases |= sort_by(.Phrase)
    ' "$json" > "$tempJson" && save_file
}

delp() {
    local phrase="$1"
    jq --arg phrase "$phrase" '
        .Phrases |= map(select(.Phrase != $phrase))
        | .Phrases |= sort_by(.Phrase)
    ' "$json" > "$tempJson" && save_file
}

delv() {
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
    ' "$json" > "$tempJson" && save_file
}

serp() {
    local search_term="$1"
    jq --arg search_term "$search_term" '
        .Phrases[] | select(.Phrase | test($search_term; "i"))
    ' "$json"
}

serv() {
    local search_term="$1"
    jq --arg search_term "$search_term" '
        .Phrases[]
        | select(.Variants[]? | test($search_term; "i"))
    ' "$json"
}
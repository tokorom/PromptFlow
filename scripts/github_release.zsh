#!/bin/zsh

github_release() {
    local repo="$1"
    local tag="$2"
    local token="$3"
    local release_note_file="$4"
    
    if [[ -z "$repo" || -z "$tag" || -z "$token" || -z "$release_note_file" ]]; then
        echo "Usage: create_github_release <repo> <tag> <token> <release_note_file>" >&2
        return 1
    fi

    BODY=$(<"$release_note_file" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

    local api_url="https://api.github.com/repos/$repo/releases"
    local response=$(curl -s -X POST $api_url \
        -H "Authorization: token $token" \
        -H "Content-Type: application/json" \
        -d "{
            \"tag_name\": \"$tag\",
            \"name\": \"v$tag\",
            \"body\": \"$BODY\",
            \"draft\": false,
            \"prerelease\": false
        }")

    echo $response
}

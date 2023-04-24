#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

COLOR_BLUE='\e[0;34m'
COLOR_NONE='\e[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

main() {
    local environment="${1?Environment is required}"

    log '🚀 Running Terraform...'

    pushd "$SCRIPT_DIR" > /dev/null

    while read -r dir; do
        if [[ "$dir" == _* ]]; then
            continue
        fi

        echo
        log "💡 Initializing module: $dir"
        echo

        gotf --params environment="$environment" --module-dir "$dir" --debug init -reconfigure

        echo
        log "🔮 Planning module: $dir"
        echo

        gotf --params environment="$environment" --module-dir "$dir" --debug plan -out=plan.out

        echo
        log "💣 Applying module: $dir"
        echo

        gotf --params environment="$environment" --module-dir "$dir" --no-vars --debug apply plan.out

    done < <(ls -d -- */)

    popd > /dev/null

    echo
    log '🎉 Done.'
}

log() {
    echo -e "$COLOR_BLUE$1$COLOR_NONE"
}

main "$@"

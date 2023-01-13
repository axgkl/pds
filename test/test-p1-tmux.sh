#!/usr/bin/env bash
## These tests may *never* fail

set -o errexit
. "$(dirname "$0")/tools.sh"

function test-vi-dashboard {
    # 0.4 too long but first ti
    # I hate failing plugins on startup. may never happen time
    TSK vi
    ✔️ max 0.4 shows "Recents"
    ✔️ shows "Find File"
    ❌ shows 'Error'
}

# lib call?
return 2>/dev/null || test_in_tmux "$@"

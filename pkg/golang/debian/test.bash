#!/usr/bin/env bash
set -e
eval $(./bin/go tool dist env -p)
bash run.bash --no-rebuild -banner ""

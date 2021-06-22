#!/bin/bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "${ROOT_DIR}"

package=$1
debuild_args=${2-}

apt-get update

# Overriding tool to add --yes to defaults so it doesn't prompt.
mk-build-deps \
  --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes" \
  --install --remove \
  "pkg/${package}/debian/control"

# Create user with the same uid as the host user so that created files are
# owned by the correct user on the host.
useradd -m --uid "$(stat --format=%u .)" --shell /bin/bash builduser

su builduser << EOF
env DEBUILD_ARGS="${debuild_args}" ./container_scripts/build_source.rb "pkg/${package}"
EOF

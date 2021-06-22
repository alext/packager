#!/bin/bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "${ROOT_DIR}"

package=${1}

echo "bulding packager docker image"
docker build -t packager .

echo "building package in docker"
# Using -us -uc to skip signing the source package as we won't have keys
# available inside the container. WE'll sign then using debsign before dput'ing
# them.
docker run -ti --rm -v "$(pwd):/packaging" packager /packaging/container_scripts/build_package_in_docker.sh "${package}" "-us -uc"

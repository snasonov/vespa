#!/bin/bash
# Copyright 2017 Yahoo Holdings. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <git commit>"
  echo "This script should not be called manually."
  exit 1
fi

GIT_COMMIT=$1
SOURCE_DIR=~/vespa
BUILD_DIR=~/build
MAPPED_DIR=/vespa
LOG_DIR=~/log

mkdir "${SOURCE_DIR}"
mkdir "${BUILD_DIR}"
mkdir "${LOG_DIR}"

git clone --no-checkout --no-hardlinks "file://${MAPPED_DIR}" "${SOURCE_DIR}"
cd "${SOURCE_DIR}"
git -c advice.detachedHead=false checkout ${GIT_COMMIT}

NUM_THREADS=$(($(nproc --all) * 2))
bash "${MAPPED_DIR}/docker/ci/build-and-test.sh" "${SOURCE_DIR}" "${BUILD_DIR}" "${LOG_DIR}" ${NUM_THREADS}

TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
sudo cp "${LOG_DIR}/java.log" "${MAPPED_DIR}/docker/logs/vespa-ci-java-${TIMESTAMP}.log"
sudo cp "${LOG_DIR}/cpp.log" "${MAPPED_DIR}/docker/logs/vespa-ci-cpp-${TIMESTAMP}.log"

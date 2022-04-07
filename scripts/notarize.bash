#!/bin/bash

set -e

function main() {
  xcrun altool --notarize-app \
    --output-format json \
    --primary-bundle-id "${APP_BUNDLE_ID}" \
    --file "${NOTARIZATION_FILE}" \
    --username "${NOTARIZATION_EMAIL}" \
    --password "${NOTARIZATION_PASSWORD}" \
    --show-progress
  rm -f "${NOTARIZATION_FILE}"
}

main

#!/bin/bash

set -e

function main() {
  altool --notarize-app \
    --verbose --output-format json \
    --primary-bundle-id "${APP_BUNDLE_ID}" \
    --file "${NOTARIZATION_FILE}" \
    --username "${NOTARIZATION_EMAIL}" \
    --password "${NOTARIZATION_PASSWORD}" \
    --show-progress
}

main

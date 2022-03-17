#!/bin/bash

set -e

CODESIGN="$(command -v codesign || echo -n "/usr/bin/codesign")"

function main() {
  security default-keychain -s "${KEYCHAIN_FILE}"
  security unlock-keychain -p "$PASSWORD" "${KEYCHAIN_FILE}"
  security import "${CERTIFICATE_FILE}" -f pkcs12 -k "${KEYCHAIN_FILE}" -T "$CODESIGN" -P "${DEVELOPER_CERTIFICATE_PASSWORD}"
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$PASSWORD" "${KEYCHAIN_FILE}"
  $CODESIGN --force -s "${DEVELOPER_CERTIFICATE_ID}" -o runtime "${BINARY_PATH}"
}

main

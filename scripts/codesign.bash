#!/bin/bash

set -e

CODESIGN="$(command -v codesign || echo -n "/usr/bin/codesign")"
NOTARIZATION_FILE="LP_NOTARIZATION_${RANDOM}.zip"

function main() {
  security default-keychain -s "${KEYCHAIN_FILE}"
  security unlock-keychain -p "$PASSWORD" "${KEYCHAIN_FILE}"
  security import "${CERTIFICATE_FILE}" -f pkcs12 -k "${KEYCHAIN_FILE}" -T "$CODESIGN" -P "${DEVELOPER_CERTIFICATE_PASSWORD}"
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$PASSWORD" "${KEYCHAIN_FILE}"
  if [[ -d "${BINARY_PATH}" ]]; then
    cd "${BINARY_PATH}"
    $CODESIGN --force -s "${DEVELOPER_CERTIFICATE_ID}" -o runtime *
    cd -
  else
    $CODESIGN --force -s "${DEVELOPER_CERTIFICATE_ID}" -o runtime "${BINARY_PATH}"
  fi
  rm -f "${CERTIFICATE_FILE}" "${KEYCHAIN_FILE}"
  zip -9r "${NOTARIZATION_FILE}" "${BINARY_PATH}"
}

main
echo "::set-output name=notarization-file::${NOTARIZATION_FILE}"

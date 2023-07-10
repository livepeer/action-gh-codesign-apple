#!/bin/bash

set -e

CODESIGN="$(command -v codesign || echo -n "/usr/bin/codesign")"
NOTARIZATION_FILE="LP_NOTARIZATION_${RANDOM}.zip"
CERTIFICATE_FILE="certificate.csr"
KEYCHAIN_NAME="lp_${RANDOM}.keychain"
KEYCHAIN_FILE=""

function livepeer-keychain() {
  # Create and unlock a custom temporary keychain for codesigning and
  # notarization purpose
  local password="$(uuidgen)"
  if [[ "${KEYCHAIN_PASSWORD}" == "" ]]; then
    KEYCHAIN_PASSWORD="$password"
  fi
  security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
  security default-keychain -s "$KEYCHAIN_NAME"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
  if [[ "$KEYCHAIN_FILE" == "" ]]; then
    KEYCHAIN_FILE="$(security default-keychain)"
  fi
}

function livepeer-codesign() {
  echo "${DEVELOPER_CERTIFICATE_BASE64}" | base64 -d >"$CERTIFICATE_FILE"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
  security import "${CERTIFICATE_FILE}" -f pkcs12 -k "$KEYCHAIN_NAME" -T "$CODESIGN" -P "${DEVELOPER_CERTIFICATE_PASSWORD}"
  security set-key-partition-list -S "apple-tool:,apple:,codesign:" -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
  if [[ -d "${BINARY_PATH}" ]]; then
    cd "${BINARY_PATH}"
    $CODESIGN --force --sign "${DEVELOPER_CERTIFICATE_ID}" -o runtime *
    cd -
  else
    $CODESIGN --force --sign "${DEVELOPER_CERTIFICATE_ID}" -o runtime "${BINARY_PATH}"
  fi
  rm -f "${CERTIFICATE_FILE}"
  zip -9r "${NOTARIZATION_FILE}" "${BINARY_PATH}"
}

function livepeer-notarize() {
  set -x
  local keychain_profile="lp-notarize_${RANDOM}"
  security default-keychain -s "$KEYCHAIN_NAME"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
  if [[ "$KEYCHAIN_FILE" == "" ]]; then
    KEYCHAIN_FILE="$(security default-keychain)"
  fi
  xcrun notarytool store-credentials \
    --verbose \
    --validate \
    --apple-id "$NOTARIZATION_EMAIL" \
    --password "$NOTARIZATION_PASSWORD" \
    --team-id "$NOTARIZATION_TEAM_ID" \
    --keychain "$KEYCHAIN_FILE" \
    "$keychain_profile"

  xcrun notarytool submit \
    --keychain-profile "$keychain_profile" \
    --keychain "$KEYCHAIN_FILE" \
    --verbose \
    --wait \
    --timeout 3m \
    "${NOTARIZATION_FILE}"
  rm -f "${NOTARIZATION_FILE}"
}

function main() {
  livepeer-keychain
  livepeer-codesign
  livepeer-notarize
}

main

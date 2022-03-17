#!/bin/bash

set -e

function main() {
  local password="$(uuidgen)"
  if [[ "${KEYCHAIN_PASSWORD}" != "" ]]; then
    password="${KEYCHAIN_PASSWORD}"
  fi
  echo "${DEVELOPER_CERTIFICATE_BASE64}" | base64 -d >"certificate.cer"
  security create-keychain -p "$password" build.keychain
  echo "::set-output name=password::${password}"
  echo "::set-output name=keychain-file::build.keychain"
  echo "::set-output name=certificate-file::certificate.cer"
}

main

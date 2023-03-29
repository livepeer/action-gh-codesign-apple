#!/bin/bash

set -e

function main() {
  local password="$(uuidgen)"
  if [[ "${KEYCHAIN_PASSWORD}" != "" ]]; then
    password="${KEYCHAIN_PASSWORD}"
  fi
  echo "${DEVELOPER_CERTIFICATE_BASE64}" | base64 -d >"certificate.cer"
  security create-keychain -p "$password" build.keychain
  echo "password=${password}" >>"${GITHUB_OUTPUT}"
  echo "keychain-file=build.keychain" >>"${GITHUB_OUTPUT}"
  echo "certificate-file=certificate.cer" >>"${GITHUB_OUTPUT}"
}

main

#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <environment-url>"
  exit 1
fi

if ! command -v pac >/dev/null 2>&1; then
  echo "Power Platform CLI (pac) is required. Install it, then rerun this script."
  exit 1
fi

environment_url="$1"
solution_name="cre_CRESales"
solution_zip="dist/${solution_name}.zip"

mkdir -p dist src
pac auth create --url "$environment_url"
pac solution export --name "$solution_name" --path "$solution_zip" --managed false
pac solution unpack --zipfile "$solution_zip" --folder src --allowDelete true

echo "Unpacked solution source is available in solutions/cre-sales/src/."

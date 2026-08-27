#!/usr/bin/env bash
set -euo pipefail

if [ "${G8N_ENVIRONMENT:-}" != "local" ]; then
  echo "Refusing reset: G8N_ENVIRONMENT must be 'local'." >&2
  exit 2
fi

if [ "${G8N_RESET_CONFIRMATION:-}" != "RESET_G8N_LOCAL_ONLY" ]; then
  echo "Refusing reset: G8N_RESET_CONFIRMATION must be 'RESET_G8N_LOCAL_ONLY'." >&2
  exit 2
fi

task_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for relative_path in "data/raw/g8n-fixtures" "exports/g8n-fixtures"; do
  target_path="${task_root}/${relative_path}"
  case "${target_path}" in
    "${task_root}/data/raw/g8n-fixtures"|*"${task_root}/data/raw/g8n-fixtures/"*|"${task_root}/exports/g8n-fixtures"|*"${task_root}/exports/g8n-fixtures/"*) ;;
    *)
      echo "Refusing reset: unexpected target ${target_path}" >&2
      exit 3
      ;;
  esac
  if [ -d "${target_path}" ]; then
    find "${target_path}" -mindepth 1 -maxdepth 2 -type f -name '*.json' -print
  fi
done

echo "Dry-run only. Delete the printed fixture files manually after reviewing the list, or extend this script locally."

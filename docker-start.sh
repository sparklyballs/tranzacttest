#!/usr/bin/env bash

# shellcheck disable=SC2154
tranzact start "${service}"

trap "echo Shutting down ...; tranzact stop all -d; exit 0" SIGINT SIGTERM

# shellcheck disable=SC2154
if [[ ${log_to_file} == 'true' ]]; then
  # Ensures the log file actually exists, so we can tail successfully
  touch "$TRANZACT_ROOT/log/debug.log"
  tail -F "$TRANZACT_ROOT/log/debug.log" &
fi

while true; do sleep 1; done

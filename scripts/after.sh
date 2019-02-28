#!/usr/bin/env sh
# User defined after script
if [[ ! -z "$AFTER_SCRIPT" ]]; then
  eval "$AFTER_SCRIPT"
fi

# END
echo END!

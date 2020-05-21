#!/bin/bash
#
# startup script for the automount-service
# This script has the following responsibilities:
# - copy the auto config to the correct location
# - start the autofs service

preconditions=0
DRY_RUN="${DRY_RUN:-false}"

checkPreconditions() {
  [ -z "$CONFIG_LOCATION" ] && echo "ERROR: CONFIG_LOCATION ENV variable must be available" && preconditions=1
  [ -z "$AUTOFS_USER" ] && echo "ERROR: AUTOFS_USER ENV variable must be available" && preconditions=1
  [ -z "$AUTOFS_PASS" ] && echo "ERROR: AUTOFS_PASS ENV variable must be available" && preconditions=1
}

main() {
  ## check for required environment variables
  checkPreconditions
  [ "$preconditions" == 1 ] && exit 1

  ## get the config file
  curl -s "${CONFIG_LOCATION}" -o /tmp/auto.indirect

  ## parse the file using sed because sigil is having difficulty with the large file size
  sed -e "s/{{ .username }}/${AUTOFS_USER}/;s/{{ .password }}/${AUTOFS_PASS}/;" /tmp/auto.indirect > /etc/auto.cifs

  if [ "${DRY_RUN}" == "true" ]; then
    cat /etc/auto.cifs
  else
    ## output the current version information
    automount --version

    ## run the automount process in the foreground to output logs
    exec automount --foreground --verbose --global-options sloppy
  fi
}

main


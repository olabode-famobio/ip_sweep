#!/bin/bash

set -u

usage() {
  echo "Usage: ./ipsweep.sh <first-three-octets>" >&2
  echo "Example: ./ipsweep.sh 192.168.0" >&2
}

validate_subnet_prefix() {
  local prefix="$1"

  if [[ ! "$prefix" =~ ^([0-9]{1,3}\.){2}[0-9]{1,3}$ ]]; then
    return 1
  fi

  IFS='.' read -r o1 o2 o3 <<< "$prefix"
  for octet in "$o1" "$o2" "$o3"; do
    if (( octet < 0 || octet > 255 )); then
      return 1
    fi
  done

  return 0
}

if [[ $# -ne 1 ]]; then
  echo "You forgot an IP address!" >&2
  usage
  exit 1
fi

prefix="$1"

if ! validate_subnet_prefix "$prefix"; then
  echo "Invalid subnet prefix: $prefix" >&2
  usage
  exit 1
fi

for ip in $(seq 1 254); do
  ping -c 1 -W 1 "$prefix.$ip" 2>/dev/null | awk '/bytes from/ { gsub(":", "", $4); print $4 }' &
done

wait

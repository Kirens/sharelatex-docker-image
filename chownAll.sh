#! /usr/bin/env bash
cnt=$(find "$1" | wc -l)

processed=1
progress=0
find "$1" -print0 |
  while IFS= read -r -d $'\0' line; do
    tmp=$(($((processed++)) * 100 / cnt))
    printf $line | bash -c "$2"
    if [ "$tmp" -gt "$progress" ]; then
      progress="$tmp"
      echo "PROGRESS: $progress %"
    fi

  done

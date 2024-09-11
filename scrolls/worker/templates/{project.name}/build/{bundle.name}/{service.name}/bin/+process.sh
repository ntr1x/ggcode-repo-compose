#!/bin/bash

process_put () {
  local key=$1

  local object=$(echo $key | sed -e 's/.*\///g')

  # TODO: Implement
}

process_delete () {
  local key=$1

  local object=$(echo $key | sed -e 's/.*\///g')

  # TODO: Implement
}

if [[ "$EVENT_NAME" == "s3:ObjectCreated:Put" ]]; then
  echo "[PUT]: $OBJECT_KEY" >&2;
  process_put "$OBJECT_KEY"
elif [[ "$EVENT_NAME" == "s3:ObjectRemoved:Delete" ]]; then
  echo "[DELETE]: $OBJECT_KEY" >&2;
  process_delete "$OBJECT_KEY"
else
  echo "[SKIP]: $OBJECT_KEY. Unsupported event: '$EVENT_NAME'" >&2
fi

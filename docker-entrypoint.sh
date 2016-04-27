#!/bin/sh

if [ -z "$1" ]; then
  if [ "$RUN_MODE" = "" -o "$RUN_MODE" = "http_server" ]; then
    echo "Running http_server"
    /usr/app/magellan-proxy --port 3000 bundle exec rails s
  elif [ "$RUN_MODE" = "delayed_job" ]; then
    echo "Running delayed_job"
    bundle exec bin/delayed_job run
  fi
  exit 1
fi

exec "$@"

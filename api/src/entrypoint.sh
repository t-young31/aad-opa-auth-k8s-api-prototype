#!/bin/bash

debug_args=""
if [ "$PRODUCTION" == "false" ]; then
  debug_args="--reload "
fi

uvicorn main:app "$debug_args"--host 0.0.0.0 --port "$API_PORT"

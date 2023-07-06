#!/bin/bash

debug_args=""
if [ "$PRODUCTION" == "False" ]; then
  debug_args="--reload "
fi

uvicorn main:app "$debug_args"--host 0.0.0.0 --port 5000

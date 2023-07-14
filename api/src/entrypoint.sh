#!/bin/bash

cd app/ || exit

if [ "$PRODUCTION" == "true" ]; then
  uvicorn main:app --host 0.0.0.0 --port "$API_PORT"
else
  uvicorn main:app --reload --host 0.0.0.0 --port "$API_PORT"
fi

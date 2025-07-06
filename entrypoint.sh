#!/bin/bash
set -e

./config.sh --unattended \
  --url https://github.com/parth-github/aws-billing-alert \
  --token $RUNNER_TOKEN \
  --name $(hostname) \
  --work _work \
  --labels self-hosted,docker

trap 'echo Removing runner...; ./config.sh remove --unattended --token $RUNNER_TOKEN; exit 130' INT TERM

./run.sh
echo "Runner started successfully. Press Ctrl+C to stop."
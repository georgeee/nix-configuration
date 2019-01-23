#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$DIR"

rsync -r /etc/nixos/* global && git add global && git commit -m "Updated configuration"

#!/bin/bash

set -e
echo Start deploying to main server...
ssh tony-main-server 'cd "/home/codelove-docs" && git pull'
echo Finish deploying.

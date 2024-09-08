#!/usr/bin/env bash
set -ex

git clone https://github.com/xDiaym/asm-template.git $1
find . -not -path ".git/*" -not -path './build_*' -type f | xargs sed -i "s/lab1/${1}/g"

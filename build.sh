#!/usr/bin/env bash
# build, tag, and push docker images

# exit if a command fails
set -o errexit

# exit if required variables aren't set
set -o nounset

# set current directory as base directory
basedir="$(pwd)"

# create docker run image
docker build -t docker.seedno.de/seednode/linx:latest "$basedir"/.

# log in to docker registry
pass show docker-credential-helpers/docker-pass-initialized-check && docker login docker.seedno.de

# push the image to registry
docker push docker.seedno.de/seednode/linx:latest

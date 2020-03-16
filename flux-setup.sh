#!/bin/bash

kubectl create ns plant-simulator-ns

export GHUSER="joesan"

fluxctl install \
--git-user=${GHUSER} \
--git-email=${GHUSER}@users.noreply.github.com \
--git-url=git@github.com:${GHUSER}/plant-simulator-deployment \
--git-path=dev \
--git-readonly=true \
--manifest-generation=true \
--namespace=plant-simulator-ns | kubectl apply -f -
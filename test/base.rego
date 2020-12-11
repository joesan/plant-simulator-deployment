package main

import data.kubernetes

name = input.metadata.name

# Check latest API version for Deployment
deny[msg] {
  input.kind = "Deployment"
  not input.apiVersion = "apps/v1"
  validAPI = "apps/v1"
  msg := sprintf("%q API version %s is deprectated and not allowed. Please use %v apiVersion", [input.kind, input.apiVersion, validAPI])
}

# Check the image has a tag version
deny[msg] {
  input.kind == "Deployment"
  image := input.spec.template.spec.containers[_].image
  not count(split(image, ":")) == 2
  msg := sprintf("image '%v' doesn't specify a valid tag", [image])
}

# Check the image tag version is not just latest
deny[msg] {
  input.kind == "Deployment"
  image := input.spec.template.spec.containers[_].image
  endswith(image, "latest")
  msg := sprintf("image '%v' uses latest tag", [image])
}

# Check container is not run as root
deny_run_as_root[msg] {
  kubernetes.is_deployment
  not input.spec.template.spec.securityContext.runAsNonRoot

  msg = sprintf("Containers must not run as root in Deployment %s", [name])
}

exception[rules] {
  input.kind == "Deployment"
  label := input.metadata.labels[_].fluxPatchFile
  #output := contains(label, "prodPatchFile")
  sprintf("printed label is %s", [label])
  label == "fluxPatchFile"
  #output == true
  rules := ["run_as_root"]
}

required_deployment_selectors {
  input.spec.selector.matchLabels.app
  # input.spec.selector.matchLabels.version
}

# Check deployment contains matchLabel selectors
deny[msg] {
  kubernetes.is_deployment
  not required_deployment_selectors

  msg = sprintf("Deployment %s must provide app selector labels for pod selectors", [name])
}
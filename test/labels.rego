package main

import data.kubernetes

name = input.metadata.name

required_deployment_labels {
    input.metadata.labels["app.kubernetes.io/name"]
    input.metadata.labels["app.kubernetes.io/instance"]
    input.metadata.labels["app.kubernetes.io/version"]
    input.metadata.labels["app.kubernetes.io/component"]
    input.metadata.labels["app.kubernetes.io/part-of"]
    input.metadata.labels["app.kubernetes.io/managed-by"]
}

deny_required_labels[msg] {
  kubernetes.is_deployment
  not required_deployment_labels
  msg = sprintf("%s must include Kubernetes recommended labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels", [name])
}

exception[rules] {
  kubernetes.is_deployment
  #label := input.metadata.labels[_].fluxPatchFile
  #output := contains(label, "prodPatchFile")
  input.metadata.name == "plant-simulator-dev"
  #input.metadata.name == "plant-simulator-prod"
  #sprintf("printed label is %s", [label])
  #label == "fluxPatchFile"
  #output == true
  rules := ["required_labels"]
}

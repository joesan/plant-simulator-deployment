package main

test_deployment_without_security_context {
  deny["Containers must not run as root in Deployment sample"] with input as {"kind": "Deployment", "metadata": { "name": "sample" }}
}

deny[msg] {
  input.kind = "Deployment"
  not input.spec.selector.matchLabels.app
  msg = "Containers must provide app label for pod selectors"
}

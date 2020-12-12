#!/bin/bash
# Read the deployment version file, extract the version
read -r line  < "deployment-version.txt"
#helm package helm-k8s/ --version "636"
echo "$line" | cut -d "=" -f2
a=$("$line" | cut -d "=" -f2)
echo "$a"
#while IFS= read -r line
#do
 # echo "$line" | cut -d "=" -f2
#done < "$input"
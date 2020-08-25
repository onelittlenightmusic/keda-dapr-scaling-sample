#!/bin/bash

# create cluster
kind create cluster --name serverless --config 1-kind/kind-config.yaml

# ingress controller
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'


# install dapr
helm repo add dapr https://daprio.azurecr.io/helm/v1/repo
kubectl create namespace dapr-system
helm install dapr dapr/dapr --namespace dapr-system

# install keda
helm repo add kedacore https://kedacore.github.io/charts
kubectl create namespace keda  
helm install keda kedacore/keda --namespace keda -f 2-keda/values.yaml

# install kafka
helm install my-kafka incubator/kafka

kubectl wait po --for=condition=ready --all --timeout=-1s

# install 
kubectl apply -f 3-kafka-pubsub/pubsub
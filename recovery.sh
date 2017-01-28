#!/bin/bash

kubectl create -f k8s/ConfigMap.yaml
kubectl create -f k8s/Secrets.yaml
kubectl replace -f k8s/Deployment-recover.yaml

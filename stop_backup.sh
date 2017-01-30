#!/bin/bash

pod="$1"

if [ -z $pod ]; then
  echo "Usage: $0 <postgres-pod-name>"
  exit 1
fi

kubectl delete -f k8s/Job-pg-backup.yaml
kubectl delete -f k8s/CronDeployment-pg-backup.yaml
kubectl delete -f k8s/Secrets.yaml
kubectl delete -f k8s/ConfigMap.yaml

kubectl exec -it $pod -n hasura -- sh -c "sed -i '/# Add settings for extensions here/q' /var/lib/postgresql/data/postgresql.conf"

kubectl rollout undo deploy/postgres -n hasura


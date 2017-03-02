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

echo "**** NEXT STEPS ****"
echo "Now you should rollback your deployment to the default postgres image."
echo ""
echo "To do that, find out what revision of the deployment contains that image."
echo "First, execute:"
echo "  $ kubectl rollout history deploy/postgres -n hasura "
echo ""
echo "Next check each revision and note the image."
echo "  $ kubectl rollout history deploy/postgres -n hasura --revision=<REVISION-NUMBER>"
echo "It should be hasura/postgres:<some-version> and not hasura/postgres-wal-e:<some-version>"
echo ""
echo "Once you have found the revision number. Rollback to that revision of the deployment."
echo "  $ kubectl rollout undo deploy/postgres -n hasura --to-revision=<REVISION-NUMBER-FROM-PREVIOUS-STEP>"


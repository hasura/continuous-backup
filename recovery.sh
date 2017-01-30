#!/bin/bash

echo "Setting up configuration to start recovery"

kubectl create -f k8s/ConfigMap.yaml
kubectl create -f k8s/Secrets.yaml

kubectl replace -f k8s/Deployment-recover.yaml

echo ""
echo "*** STATUS ***"
echo "--------------"
echo "The recovery process will take some time depending on your data and"
echo "size and number of backups."
echo ""
echo "You can see the status by tail-ing the log of the postgres pod:"
echo "  $ kubectl logs <postgres-pod-name> -n hasura"
echo ""

echo "*** POST RECOVERY STEPS ***"
echo "---------------------------"
echo "More details in the documentation."
echo ""
echo "Make sure kubectl is pointing to old project"
echo "  $ kubectl config set current-context <old-hasura-project>"
echo "Then:"
echo "  $ kubectl get secret postgres -n hasura -o yaml"
echo "The value in postgres.password is the postgres admin password."
echo "Copy the value in the postgres.password field and keep it."
echo "Again:"
echo "  $ kubectl get secret auth -n hasura"
echo "The value in django.sapass is the project admin password."
echo "Copy the value in the django.sapass field and keep it."
echo ""
echo "Now switch to new project:"
echo "  $ kubectl config set current-context <new-hasura-project>"
echo "Then:"
echo "  $ kubectl edit secret postgres -n hasura"
echo "In the postgres.password field, paste the value from previous step."
echo "And:"
echo "  $ kubectl edit secret auth -n hasura"
echo "In the django.sapass field, paste the value from previous step."
echo ""
echo "Now restart auth and data pods:"
echo "  $ kubectl delete pod <auth-pod-name> -n hasura"
echo "  $ kubectl delete pod <data-pod-name> -n hasura"

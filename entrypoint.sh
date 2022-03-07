#!/bin/sh -l

echo "Deploying $GITHUB_JOB"

echo $K8S_KUBECONFIG | base64 -d > ./kube_config
kubectl config use-context $K8S_CLUSTER
# kubectl get po -n $NAMESPACE
export igs=$(awk -v ORS="\n                " 1 deploy/igs.txt)
if [[ $sport == "cfb" ]]
  then echo "adding cfb secrets to deployment"
  envsubst < deploy/${sport}.txt > secrets.txt
  export secrets=$(awk -v ORS="\n\        " 1 secrets.txt)
fi
if [[ $rprofile == "true" ]]
  then echo "adding rprofile secrets"
  envsubst < deploy/rprofile-secrets.txt > rprofile-secrets.txt
  export rprofile_secrets=$(awk -v ORS="\n        " 1 rprofile-secrets.txt)
fi
envsubst < deploy/deployment.yml > deployment.yml
# cat deployment.yml
kubectl apply -f deployment.yml -n $NAMESPACE
envsubst < deploy/service.yml > service.yml
kubectl apply -f service.yml -n $NAMESPACE
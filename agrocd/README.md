## ARGOCD ##

```bash
kubectl create namespace argocd

wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f install.yaml -n argocd

kubectl get po -n agrocd
```

Replace ClusterIP with NodePort so that you can access it from anywhere.:

```bash
kubectl edit svc argocd-server -n argocd
```

Get secret using below command: 

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Deploy your app inside agroCD using below command:

```bash
kubectl apply -f application.yaml
```

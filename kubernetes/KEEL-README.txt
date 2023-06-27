#Steps for using keel

1. Make changes in baseservices.yaml as shown below. Add annotations section after namespace
2. To select the custom tag (latest/dev/prod) or any tag that you provide during deploying services
$keel.sh/policy: glob:{{build_id}} 
3. The method that keel will use to check image updates. here we are using polling method.
$keel.sh/trigger: poll
4. Time span that keel will poll the private registry.
$keel.sh/pollSchedule: "@every 30s"
5. In containers section change image pull policy to Always, this will Always pull image from registry whenever a change is detected.
$imagePullPolicy: Always
6. Add Image pull secrets section and provide the secret name that you will be creating. here raven-registry is our secret name.
$imagePullSecrets: 
$- name: raven-registry
7. I have demonstrated the changes in event-app service example.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-app
  namespace: default
  labels:
    name: "event-app"
  annotations:
    keel.sh/policy: glob:{{build_id}}
    keel.sh/trigger: poll
    keel.sh/pollSchedule: "@every 30s"
spec:
  selector:
    matchLabels:
      app: event-app 
  replicas: 1
  template:
    metadata:
      labels:
        app: event-app 
    spec:
      containers:
      - name: event-app 
        image: {{registry_server}}/{{client_name}}/event-app:{{build_id}}
        imagePullPolicy: Always
        volumeMounts:
        - mountPath: /app/images
          name: glusterfs  
        - mountPath: /app/config
          name: config
        - mountPath: /app/k8s
          name: kubeconfig 
        - mountPath: /app/raven-cam
          name: ravenyaml
        - mountPath: /app/ffmpeg-cam
          name: ffmpegyaml
      volumes:
      - name: glusterfs
        hostPath:
          path: /mnt/ravenfs/pivotchain
          type: Directory
      - name: config
        configMap:
          name: backend-config 
      - name: kubeconfig
        configMap:
          name: kubeconfig
      - name: ravenyaml
        configMap:
          name: raven-yaml
      - name: ffmpegyaml
        configMap:
          name: ffmpeg-yaml
      imagePullSecrets: 
      - name: raven-registry


8. Setup the K8S cluster and then apply the keel-service.yaml which is present in yamls directory.
If the keel-service.yaml is not present then apply below command
$kubectl apply -f https://sunstone.dev/keel?namespace=keel&username=admin&password=admin&tag=latest

This command will deploy Keel to keel namespace with enabled basic authentication and admin dashboard.

9. To check whether Keel successfully started - check pods:

$kubectl -n keel get pods

You should see output something like this:
NAME                    READY     STATUS    RESTARTS   AGE
keel-2732121452-k7sjc   1/1       Running   0          14s

10. Do docker login to your registry
$docker login $registry_server -u="$registry_user" -p="$registry_pass"

11. Create secrets as Keel needs secrets to access private registry
$kubectl create secret generic raven-registry  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson	
To check if secrets are generated shoot below command
$kubectl get secrets
You should see output something like this:
NAME                    READY     STATUS    RESTARTS   AGE
raven-registry   1/1       Running   0          36s

12. Congratulations on implementing your keel. For any queries you can contact me at abrahamcyril77@gmail.com

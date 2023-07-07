Creating Kubernetes cluster on the AWS CLOUD--> Service name--> EKS

Below are the steps to create the EKS Cluster.

1] Create the VPC.

2] Create IAM role for EKS Cluster:
   IAM --> Role --> EKS --> ROLE-NAME

3] Create the EKS Cluster on AWS Dashboard (While creating it, attach the role created in second steps.)

4] Access EKS cluster from your machine
   - install kubectl, aws cli,
   - configure aws cli(aws configure,)


<!-- 
aws configure --profile PROFILE-NAME
aws configure list-profiles
export AWS_PROFILE=PROFILE-NAME
aws sts get-caller-identity
aws eks describe-cluster --name CLUSTER-NAME --region us-east-2
aws eks update-kubeconfig --region us-east-2 --name CLUSTER-NAME 
kubectl get nodes
kubect get pods  
-->

5]  Create the New IAM role for workernodegroup:
     
     IAM --> Role --> EKS --> AmazonEKS_CNI_Policy  --> AmazonEKSWorkerNodePolicy  --> AmazonEC2ContainerRegistryReadOnly --> ROLE-NAME

6]  Create the EKS workernodegroup on AWS Dashboard (While creating it, attach the role created in 5th steps.)

7] Once workernodegrp ready u r good to go to deploy application on it...


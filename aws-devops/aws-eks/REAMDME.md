## Creating Kubernetes cluster on the AWS CLOUD
### Service name: EKS

Below are the steps to create the EKS Cluster.

1. Create the VPC.

2. Create IAM role for EKS Cluster:
   - Go to IAM > Role > EKS > ROLE-NAME

3. Create the EKS Cluster on AWS Dashboard:
   - Attach the role created in the previous step while creating the cluster.

4. Access EKS cluster from your machine:
   - Install kubectl and aws cli.
   - Configure aws cli using the command: `aws configure`.
   - Run the following commands:
   
   ```bash
   aws configure --profile PROFILE-NAME
   aws configure list-profiles
   export AWS_PROFILE=PROFILE-NAME
   aws sts get-caller-identity
   aws eks describe-cluster --name CLUSTER-NAME --region us-east-2
   aws eks update-kubeconfig --region us-east-2 --name CLUSTER-NAME
   kubectl get nodes
   kubectl get pods

5. Create a new IAM role for workernodegroup:
   Go to IAM > Role > EKS > AmazonEKS_CNI_Policy >
   AmazonEKSWorkerNodePolicy > AmazonEC2ContainerRegistryReadOnly > ROLE-NAME

7. Create the EKS workernodegroup on AWS Dashboard:
   Attach the role created in the previous step while creating the workernodegroup.
   Once the workernodegroup is ready, you are good to go to deploy applications on it

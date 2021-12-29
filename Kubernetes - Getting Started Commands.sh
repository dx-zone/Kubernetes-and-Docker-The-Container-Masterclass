# Kubernetes - Getting Started Commands

# Master & Nodes

# Setup the Master node on Linux Debian

apt-get update

# Install Docker
apt-get install -y docker.io
docker version

# Install dependencies
apt-get install -y apt-transport-https curl

# Setup Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF >/etc/apt/sources.list.d/kubernetes.list
EOF

apt-get update

# Install Kubernetes components
apt-get install -y kubelet kubeadm kubectl

# Prerequisite to install the network part for Kubernetes cluster
sysctl net.bridge.bridge-nf-call-iptables=1

# Initialize the kubernetes cluster
kubeadm init

# Make a note of the recommended commands to start using the cluster, the Join commands, and the token
# You will need these commands later

# Set the part network
kubeclt apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Deploy the components of Kubernetes master
kubectl get pods --all-namespaces

# Grant regular users access to the master node
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Check if is Kubernetes is working with regular users
kubectl get pods --all-namespaces

# Log/ssh into the node-1 and switch to root
sudo su -

# Execute the kubeadm join command copied after initializing the Kubernetes cluster (kubeadm init).

# Log/ssh into the node-2 and switch to root
sudo su -

# Execute the kubeadm join command copied after initializing the Kubernetes cluster (kubeadm init).


# Log/ssh into the master
# Check the list of the nodes joint
kubeclt get nodes

#### LAB ####
# Imperative Pod Creation: Create an object from a YAML file
kubectl create -f imperative-pod.yaml

# Declarative Pod Creation: Create an object from a YAML file
kubectl apply -f declarative-pod.yaml

# Display status of the pods running
kubectl get pods

# Insect the pods
kubectl describe pods imp-pod
kubectl describe pods dec-pod

# Container's Lifecycle Hooks
kubectl create -f lifecyc-prod.yaml
kubectl get pods
kubectl describe pod lifecyc-pod

# Log/ssh into the container
kubectl exec -it lifecyc-pod -- /bin/bash
cat /usr/share/poststart-msg

# Create anoter pod/container which will execute commands and then terminate the container (complete)
kubectl create -f command-pod.yaml
kubectl get pods
kubectl describe pod cmd-pod
kubectl logs cmd-pod

# Create another pod/container passing custom environmental variables to the container
kubectl create -f environment-pod.yaml
kubectl get pods
kubectl describe pod env-pod

kubectl exec -it env-pod -- /bin/bash
printenv

# Labeling Containers

# Working with Namespaces (logical partitions)
# Check available Namespaces
kubectl get namespaces

kubectl get pods

kubectl get pods --all-namespaces

# Create a new Namespace
kubectl create namespace my-namespace

# Create a pod/container under the namespace "my-namespace"
# This allows you to duplicate pods name but under different namespaces
kubectl create -f imperative-pod.yaml -n my-namespace
kubectl get pods
kubectl get pods -n my-namespace
kubectl get pods --all-namespaces


# Creatig two (2) Containers Specifying CPU & Memory
kubectl create -f resource-pod.yaml
kubectl get pods
kubectl describe pods frontend

# You will notice the MySQL container being Backoff due to OOMKill (lack of memory)
# Delete the pod and increase the memory in the resource-pod.yaml from 250m to 1021Mi
# for both, db-container & wp-container
kubectl delete pods frontend

kubectl create -f resource-pod.yaml
kubectl describe pods frontend

# Delet all pods/containers
kubeclt get pods
kubectl delete pods --all

# Working with Reaplica-Set (Higher Units of Orchestration Compared to Pods)
kubectl create -f replica-pod.yaml
kubectl get pods
kubectl describe pods replicaset-guestbook-mb2jv
kubectl get rs
kubectl describe rs replicaset-guestbook

kubectl delete pods replicaset-guestbook-mb2jv
kubectl get pods

# Working with Deployments (Higher Units of Orchestration Compared to Pods and Replicas)
kubectl get pods
kubectl create -f deployment.yaml
kubectl get pods
kubectl describe pods deploy-nginx-asuiyitda897s

kubectl get deployments
kubectl describe deployments deploy-nginx

# Working with Jobs (run to completion and terminate the container)
kubectl create -f jobs.yaml
kubectl get pods
kubectl describe pods job-pi-mtrzk

kubectl get jobs
kubectl describe jobs job-pi
kubectl logs job-pi-mtrzk

# Networking and Storaging with Kubernetes
# Create a Deployment and a Service
kubectl create -f deploy-nginx.yaml
kubectl create -f serve-nginx.yaml

kubectl get pods

kubectl get deployments
kubectl get svc
kubectl describe svc serve-nginx

kubectl delete svc serve-nginx

# Working with NodePort (assign an external IP to access the pods)
kubectl get deployments
kubectl create -f serve-nginx-v2.yaml
kubectl get svc

curl -k 35.200.215.139:30939

# Mounting Volume to a Pod
kubectl get pods
kubectl create -f redis-pod.yaml
kubectl get pods

kubectl exec -it redis-pod -- /bin/bash
echo "This is an open source in-memory data structure store used as database." > redis-intro.txt
apt-get update
apt-get install procps
ps aux
kill 1 # Kill redis process which in turn will restart the container, all files will be lost

kubectl get pods

kubectl exec -it redis-pod -- /bin/bash
ls # notice the redis-intro.txt file no longer exist because the was no volume declared in the yaml file
exit

kubectl create -f redis-vol.yaml
kubectl describe pods redis-vol

kubectl exec -it redis-vol -- /bin/bash
echo "This is an open source in-memory data structure store used as database." > redis-intro.txt
apt-get update
apt-get install procps
ps aux
kill 1 # Kill redis process which in turn will restart the container but this time teh redis-intro.txt file will persist
exit

kubectl -it redis-pod -- /bin/bash
ls # Check for the redis-intro.txt file
cat redis-intro.txt
exit

# Mounting Projected Volume to a Pod – Secrets
kubeclt get pods

echo -n "admin" > ./username.txt
echo -n "m6d9-ch#u*p@" > ./password.txt

kubectl create secret generic user --from-file=./username.txt

kubectl create secret generic pswd --from-file=./password.txt

kubectl get secrets
kubectl describe secret pswd

kubectl get pods

kubectl exec -it projectedvol-pod -- /bin/sh
ls /projected-volume/


# Good Old MySQL WordPress Combination with Kubernetes
kubectl create secret generic mysql-pswd --from-literal=password=abc@123
kuectl get secrets

kubectl apply -f mysql-db.yaml

kubectl get pods

kubectl get deployments

kubectl describe deployments mysql-db

kubectl get svc

kubectl describe services mysql-db

kubectl apply -f wordpress-frontend.yaml

kubectl get pods

kubectl get deployments

kubectl describe deployments wp-frontend

kubectl get svc


# Node Eviction from a Kubernetes Cluster
kubectl create -f nginx.yaml

kubectl get rs

kubectl get pods - o wide

kubectl drain node-2 # turn draining mode (the equivalent of "Maintenance Mode" in VMware vSphere)
kubectl drain node-2 --ignore-daemonsets

kubectl get nodes

kubectl get pods

kubectl uncordon node-2 # to exit draining mode (the equivalent of exiting from "Maintenance Mode" in VMware vSphere)

##########################################
# Introduction to Taints and Tolerations #
##########################################

# Taint and Toleration is kind of tagging a node to only accept Pods with matching tags

# Create a 3rd node in GCP
# SHH into it and install Docker, kubectl & kubeadm on node-3 (as done in the bootstrapping k8s cluster demo on GCP)
# Then continue with the following lab

# Now SSH in into the Master node
# You will see the token is invalid because the initial token created when setting up the cluster was valid for 12 hours
kubectl token list
kubeadm token create # Copy and save the token newly generated.

# SSH back into node-3
kubeadm join 10.160.0.2:6443 --token <token copied from the master node> --discovery-token-ca-cert-hash sha256:3ac4b7e861111c3045d

# SSH back into Master node
kubectl get nodes

kubectl get nodes

kubectl get nodes -o wide

kubectl get nodes --show-labels

# Change the label of the node (kind of similar to change a hostname)
kubectl label nodes node-3 disktype=ssd
kubectl describe nodes node-3

kubectl get pods -o wide

# Creating Pods and Tain the new node-3
kubectl create -f test-pod.yaml

kubectl get pods -o wide

# Tain a node with the taint condition (Pods having the label disk=pd will not be schedule on this node)
kubectl taint nodes node-3 disk=pd:NoSchedule

kubectl describe node node-3

kubectl run hdd --image=nginx --replica=6 --port=8080 -l disk=pd

kubectl get pods -o wide

# Remove the taint on node-3
kubectl taint nodes node-3 disk:NoSchedule-

# Delete our hdd deployment
kubectl delete deployments hdd

# Create the same deployment again with the disk=pd label
kubectl run hdd --image=nginx --replicas=6 --port=8080 -l disk=pd

kubectl get pods -o wide


#####################################
# Horizontal Pod Auto-scaling (HPA) #
#####################################

kubectl get pods
kubectl get deployments
kubectl get svc

# Create a deployment from Google Container Register
kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port:80

# Spin up a busybox container, and ssh in to create a sudo load to trigger auto-scaling (HPA)
kubectl run - i --tty load-generator --image=busybox /bin/sh
wget -q -O- http://php-apache.default.svc.cluster.local

# Deploy an HPA from the master node to trigger auto-scaling after reaching 50% CPU usage
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=5

kubectl get hpa

# Go back to the shell of the busy box previously created to put a load to trigger the auto-scaling
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done

# Back in the master node check if new replicas has been automatically deployed
kubectl get hpa


#################################
# Clean/Delete All Your CLuster #
#################################

kubectl delete *

#####################################################
# Demo: Deploying Apache ZooKeeper Using Kubernetes #
#####################################################
kubectl create -f zookeper-hs.yaml
kubectl create -f zookeeper-cs.yaml
kubectl create -f zookeeper-pdb.yaml
kubectl create -f zookeeper-ss.yaml

kubectl get pods -w -l app=zk

for i in 0 1 2; do kubectl exec zk-$i -- hostname; done

for i in 0 1 2; do echo "myid zk-$i"; kubectl exec zk-$i -- cat /var/lib/zookeeper/data/myid; done

for i in 0 1 2; do kubectl exec zk-$i -- hostname -f; done

kubectl exec zk-0 -- cat /opt/zookeeper/conf/zoo.cfg

kubectl exec zk-0 zkCli.sh create /hi-from-sender hi-from-receiver

kubectl exec zk-1 zkCli.sh get /hi-from-sender

# Cleaning
kubectl delete statefulset zk

kubectl get pods -w -l app=zk

kubectl get pods


################################################
# Managed Kubernetes as a Service on the Cloud #
################################################

#################################
## Google Cloud Platform (GCP) ##
# Lab: Kubernetes on Google Cloud Platform (GCP)

kubectl get nodes

kubectl get pods

kubectl get pods --all-namespaces

git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

ls

cd -r kubernetes-engine-samples /k8s-samples/

ls

cd k8s-samples/

ls

cd wordpress-persistent-disks/

ls

cat mysql-volumeclaim.yaml

kubectl apply -f mysql-volumeclaim.yaml

cat wordpress-volumeclaim.yaml

kubectl apply -f wordpress-volumeclaim.yaml

kubectl get pvc

kubectl create secret generic mysql --from-literal=password=abc@123

cat mysql.yaml

kubectl create -f mysql.yaml

kubectl get pod

cat mysql-service.yaml

kubectl create -f mysql-service.yaml

cat wordpress.yaml

kubectl create -f wordpress.yaml

cat wordpress-service.yaml

kubectl create -f wordpress-service.yaml

kubectl get svc

kubectl describe svc wordpress

###########################
## Microsoft Azure Cloud ##
# Lab: Kubernetes on Microsoft Azure #

# Launch Cloud Shell and choose Bash, then create a cloud drive when prompted
# Create a resource group in the East US region
az group create --name CC-AKS --location eastus

# Create a Kubernetes cluster whithin the resource group itself (aks = Azure Kubernetes Services)
az aks create --resource-group CC-AKS --name AKS-Cluster --node-count 1 --enable-addons monitoring --generate-ssh-keys

# To access the cluster - import the credentials of the cluster to our cloud shell
az aks get-credentials --resource-group CC-AKS --name AKS-Cluster

kubectl get node

cat nginx-deployment.yaml

cat nginx-service.yaml

kubectl create -f nginx-deployment.yaml

kubectl create -f nginx-service.yaml

kubectl get pods

kubectl get deployments

kubectl describe deployments my-nginx

kubectl get services

kubectl describe svc my-nginx

# Delete the resources we have created
az group delete --name CC-AKS --yes --no-wait


#############################
# Docker GUI with Kitematic #
#############################

# Get Kitematic from Github
https://github.com/docker/kitematic/releases


##################################
# Kubernetes with Minikube + GUI #
##################################

sudo apt-get update -o Acquire::ForceIPv4=true sudo apt-get install -y apt-transport-https

cursl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

sudo apt-get install -y kubectl

kubectl version

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64

chmod +x minikube

sudo cp minikube /usr/local/bin/ && rm minikube

minikube start --vm-driver=virtualbox

kubectl run nginx-server --image nginx:latest --port 80

kubectl get pods

kubectl describe pods nginx-server-76a54da687sd4

kubectl get pods

kubectl get deployments

kubectl describe deployment nginx-server

kubectl expose deployment nginx-server --type=NodePort

kubectl get svc

minikube ip

# URL: <ip:port>

minikube dashboard

minikube stop

minikube delete

################################
# Serverless Kubernetes on GPC #
################################

# Google GKE with Cloud Run API #
# Enable Cloud Run API
# Go to Cloud Run
# Create cloud run service


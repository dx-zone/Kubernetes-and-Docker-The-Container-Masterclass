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
ls # Check for teh redis-intro.txt file
cat redis-intro.txt
exit

# Mounting Projected Volume to a Pod – Secrets



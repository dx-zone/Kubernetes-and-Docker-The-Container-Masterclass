# Docker - Getting Started Commands

# Practice the following commands
docker image pull nginx:latest

docker image

docker container run -itd --name web-server-nginx -p 8080:80 nginx:latest

docker ps -a

# How Docker works?
#
# Docker Client - Piece of client software, passess CLI and API calls to Docker Host.
# Docker Host - Runs Docker daemon, host Containers and pull and push images between Docker Host and Docker Registry.
# Docker Registry - Store Docker images.

# Docker Architecture and Dockerfiles
#
# Dockerfile (Build) - sequential set of instructions processed by Docker Engine
# Docker Image (Ship) - 
# Containers (Run)

# Dockerfile Content Overview (Dockerfile Instructions)
## Fundamental Instructions
# FROM
# ARG
#
## Configuration Instructions 
# RUN
# ADD | COPY
# ENV
#
## Execution Instructions
# CMD
# ENTRYPOINT
# EXPOSE


# Build a Docker image from a Dockerfile:
docker build -t img_from .

# List Docker images build:
docker images

# Build a Docker image from another Dockerfile:
# The container will be named img_run-env
docker build -t img_run-env .

# Run an image as Container with arguments to run interactive, tty, detached (ITD)
# - i | stands for interactive
# -d | The detach flag makes the container runs into the background
# -t | Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
docker run -itd --name cont_run-env img_run-env

# List container ID, image, command, created, status, & port currently running
docker ps -a

# List the running containers and bring the bash of the container from background to the foreground (when run with -d detach flag)
docker ps -a
docker exec -it cont_run-env bash # this will bring you into the bash of the dockerized image
ls
echo $USER
echo $SHELL
echo $LOGNAME
cd /home
ls
exit # this will exit you from the dockerized bash

# List containers built and remove the container once stopped
docker images
docker run -itd --rm --name cont_expose -p 8080:80 img_expose

# Stop a running containter
docker container stop web-server-nginx

# Send sigkill signal to a container
docker kill web-server-nginx

# Destroy a container
docker container rm web-server-nginx

# Delete the image of a container
docker rmi img_expose


# Another Example
#
# Build a docker image
# the -t flag will set/tag the name for the image to be created out of the Docker file located in the same directory
docker build -t image_expose .
# List the images built
docker images
# Run a container based on the image created and in addition
# the -idt flags are for interactive, tty, and detached
# the --rm flag will automatically remove the container one it has stopped
# the --name flag will set the name of the container
# the -p 8080:80 will map the container's ports 80 with the host port 8080
# the last name is the name of the image previously built
docker run -idt --rm --name container_expose -p 8080:80 image_expose
# List all the running and stopped containers
docker ps -a

# Another Example Using child and parent Dockerfile
docker build -f parent-Dockerfile -t papa-ubuntu .
docker build -f child-Dockerfile -t baby-ubuntu .

docker run -itd --name baby-container baby-ubuntu
docker exec -it baby-container bash

ls
cd /tmp/
ls
cat greetings.txt 
exit

# Understand and implement Docker healthcheck, stopsignal, and containerize a simple Flask application
# Demo 9
docker build -t flask-app-image .
docker images
docker run --rm -idt --name flask-container -p 8080:8080 flask-app-image
docker ps -a

docker container rm flasky


# Working with Docker Images
#
# Search for images
docker search python:3.6

# Search Docker Registry images from Docker Hub
docker search registry

# Search Docker Registry for images filtering by Docker official images
docker search --filter "is-official=true" registry

# Format the search results
docker search --format "table {{.Name}}\t{{.Description}}\t{{.IsOfficial}}" registry

# List images
docker images ls

# Look for a particular image
docker images ubuntu
docker images ubuntu:16.04
docker images --no-trunc ubuntu

# Download nginx apline release
docker image pull nginx:alpine

# Download all variations of nginx
docker image pull --all-tags nginx
docker images nginx

# Go to hub.docker.io in order to create a repository
# Click on the Repositories link
# Create a public repository
# Copy the user/path for the repo newly created
# Example: https://hub.docker.com/repository/docker/399663/repo-nginx

# Login to Docker interactively from CLI
docker login

# Tag a local image into a new Docker image (this will create an alias from existing image)
# the 399663 represents the username or ID for your Docker account/tag name
docker tag nginx:latest 399663/repo-nginx:cc-nginx

# Push the image to your online repository (https://hub.docker.com/repository/docker/399663/repo-nginx)
docker image push 399663/repo-nginx:cc-nginx


# Lab: Download an Ubuntu image to inspect the image
docker image pull ubuntu
docker images ubuntu
docker image inspect ubuntu:latest

docker image inspect ubuntu:latest | grep 'Id'
docker image inspect ubuntu:latest | grep -a2 'Repo'
docker image inspect ubuntu:latest | grep -a2 'Container'
docker image inspect ubuntu:latest | grep -a2 'Architecture'
docker image inspect ubuntu:latest | grep -a2 'Size'
docker image inspect ubuntu:latest | grep -a2 'Host'
docker image inspect ubuntu:latest | grep -a2 'Layer'

docker image inspect --format "{{.RepoTags}} : {{.RepoDigests}} : {{.Architecture}}" ubuntu:latest


# Save the inspect results in JSON format in a text file
docker image inspect --format "{{json .Config}}" ubuntu
docker image inspect --format "{{json .Config}}" ubuntu > inspect_report_ubuntu.txt

# Check the intermediate layers of an image created
docker image history ubuntu

# Remove an image forcefully
docker image rmi b46db85084b8 --force
docker image rm ba6acccedd29 --force

# Create a container (but wont't run it) which will be pulled from the Docker Hub since the content is not available locally
docker container create -it --name cc-busybox-A busybox:latest
docker ps -a # The container has been created but won't be in running state

# Set a container to run (if it was only created but no set to run)
docker container start cc-busybox-A

# Set a container to run and to be deleted once is stopped running
docker container run -itd --rm --name cc-busybox_B busybox:latest

# Stop a container from running
docker container stop cc_busybox-B

# Restart a container after 5 seconds
docker container restart --time 5 cc-busybox-A


# Rename a container
docker container rename cc-busybox-A my-busybox

# Attach a standard IO & standard error to a container
# Note: attaching to the container conditions the status of the container to be stopped when you exit from the container's shell 
docker container attach my-busybox

# Start the container again
docker container start my-busybox

# Pass and execute commands to the container's shell (without causing changes to the container's state)
docker exec -it my-busybox pwd
docker exec -it my-busybox ls /
docker exec -it my-busybox pwd ls

# Inspecting a Commiting a Container
docker container inspect my-busybox
docker inspect --format='{{range .NetworkSettings.Networks}} | {{.IPAddress}} | {{end}}' my-busybox

# Execute commands from the container's shell (without causing changes to the container's state).
# In this case, is to jump into the bash of the container
docker exec -it my-busybox bash

# Create a new image from a container's changes (using repo format)
docker container commit ubuntubox 399663/ubuntu:nmap

# Lab: Create an Ubuntu box, exec into it, install, commit changes to the container's image
docker container run -idt --name ubuntubox ubuntu:latest
docker ps -a
docker exec -it ubuntubox bash
/# apt-get install -y nmap
/# exit
docker container commit ubuntubox 399663/ubuntu:nmap


######################################
## Maps Network Ports to Containers ##
######################################

# Map ports to the containers
docker container run -idt --name container-a -p 8080:80/tcp ubuntu:latest

# Allow Dockers to map ports by itself based on the Dockerfile
docker container run -idt --name netcontainer -P ubuntu:latest

# Check the ports already mapped for a running container
docker container port container-a


##################################
## Cleaning/Removing Containers ##
##################################

# Cleaning up/removing stopped containers by container's name
docker container rm container-a

# Cleaning up/removing multiple stopped containers at once
docker container rm container-a container-b container-c

# Cleaning up/removing stopped containers by container's ID
docker container rm cb9676d062c5

# Cleaning up/removing a running containers by force
docker container rm cb9676d062c5 --force

# Gracefully remove a container
docker container kill --signal=SIGTERM ubuntubox

# Remove all the stopped containers at once
docker container prune


##############################
## Creating Docker Networks ##
##############################

# Create a bridge network
docker network create --driver bridge my-bridge-1
docker network create --driver bridge --subnet=192.168.0.0/16 --ip-range=192.168.5.0/24 my-bridge-1

# List the networks available
docker network list
docker network ls
docker network ls --filter driver=bridge


####################################
## Connect Containers to Networks ##
####################################

# Connet a container to a network
docker network connect my-bridge-1 container-d
docker container-docker inspect container-d

# Create a container specifying the network type as bridge
docker container run -itd --network host --name container-d ubuntu:latest
docker container-docker inspect container-d

# Change container network connection to port (not communication other than with the host)
docker container port container-d
docker container-docker inspect container-d

# Inspect a network
docker network inspect bridge
docker network inspect --format "{{.Scope}}" bridge
docker network inspect --format "{{.ID}} | {{.Name}}" bridge
docker network inspect --format "{{.ID}} | {{.Name}} | {{.Scope}}" bridge


#######################################
## Disconnect Containers to Networks ##
#######################################
docker network disconnect my-bridge-1 container-d


########################################
## Lab: Ping one container to another ##
########################################

# Create the network
docker network create --driver bridge --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 net-bridge

docker network ls

# Run a database container
docker run -itd --net=net-bridge --name=container-db redis

# Fecth the ip of the container
docker inspect --format='{{range .NetworkSettings.Networks}} {{.IPAddress}} {{end}}' container-db

# Run another container named server-a
docker run -idt --net=net-bridge --name=server-a busybox
docker inspect --format='{{range .NetworkSettings.Networks}} {{.IPAddress}} {{end}}' server-a

# Inspect net-bridge network to find which containers are connected to it
docker network inspect --format='{{json .Containers}} net-bridge | python -m jason.tool' net-bridge

# Run a 3rd container
docker run -idt --name=server-b busybox

# Verify the 3rd container's IP and the network assigned (it will be assigned to default network which is bridge by default)
docker container inspect --format='{{json .NetworkSettings.Networks}} server-b | python -m json.tool' server-b

# Open three (3) terminal windows

# Run the following in the terminal windows #1
docker container exec -it container-db bash
# ping www.google.com
# apt-get -y install iputils-ping
# ping www.google.com -c 5
# ping 172.20.240.2 # ping container-b IP address
# ping server-a # ping another container using his hostname (DNS)

# Run the following in the terminal windows #2
docker container exec -it server-a sh
# ping google
# ping 172.20.240.1 # ping container-db IP address
# ping container-db # ping another container using his hostname (DNS)

# Run the following in the terminal windows #3
docker container exec -it server-b sh
# ping google
# ping 172.20.240.1 # ping container-db IP address



#########################
## Storage with Docker ##
#########################

#####################
## Storage Volumes ##
#####################

# Create a Docker volume
docker volume create vol-busybox

# Run a container specifying the volume and mount point (vol-ubuntu:/tmp)
docker run -idt --volume vol-ubuntu:/tmp --name server-a ubuntu

# List available volumes
docker volume ls

# Use filters to list Docker volumes currently unused by a container (not mounted to any container)
docker volume ls --filter "dangling=true"

# Inspect Docker volume
docker volume inspect vol-ubuntu

# Remove a volume
docker volume rm vol-ubuntu

# Check which container has a volume mounted
docker container inspect --format "{{json .Mounts}}" server-a | python -m json.tool


#############################################################
## LAB: Create a Docker volume and mount it to a container ##
#############################################################
# This is how we mount a Docker volume to a container and 
# create a backup of the container's data, /var/log in this case
# into the Docker host using local volume driver

# Create a container, a volume, and set a mounting point (Container: container-a | Volume: vol-ubuntu | Mounting Point: /var/log)
docker run -idt --name container-a --volume vol-ubuntu:/var/log ubuntu:latest

# Check the list of the volumes and find the newly created volume
docker volume ls

# Check the list of the containers and find the newly created container
docker ps -a

# Check the volume and the mounting point of the volume set for the container
docker container inspect --format "{{json .Mounts}}" container-a | python -m json.tool

# Jump into the container's terminal and execute some changes to be stored in the mounting point
# /var/log/ which in turned will be stored in the newly created volume (to be stored in the host where Docker engine is running)
docker exec -it container-a bash
# apt-get update
# cd /var/log
# exit

# Stop the container
docker stop container-a

# Change into the directory where Docker is storing the files of the volumes
# Notice the files generated in the container and stored in the /var/log
# were also stored in the local Docker volume (vol-ubuntu)
sudo su -
cd /var/lib/docker/volumes
ls
cd vol-ubuntu
ls
cd _data
ls


#################
## Bind Mounts ##
#################

# Create a directory in the Docker host
mkdir /tmp/volumes/bind-data

# Create and run a container binding the container's /tmp directory with the Docker host /tmp/volumes/bind-data directory
docker run -idt \
--name container-a \
--mount type=bind,source="/tmp/volumes/bind-data",target=/tmp \
ubuntu:latest

# Inspect the container and check the Mounts type, source, destination, and the RW
# The RW set to true means the user can access (read) and modify (write) the content
# of the bind-mount from host machine as well as the running container
# Lastly, the Progapation defines bilateral proagation of files creation between host directory and the container's mounting point
docker container inspect container-a

# Jump into the container's terminal, create a file in the bind-mount directory, exit the container's terminal,
# check the file existance from the host's bind-mount directory,
# create a file in the bind-mount directory from the host
docker exec -it container-a bash
# ls
# touch /tmp/foot.txt
# 
# ls /tmp
# exit
cd /tmp/volumes/bind-data
ls
touch /tmp/volumes/bind-data/hello.txt

# Jump back to the container's terminal and check the existance of the file created from the host
docker exec -it container-a bash
# cd /tmp/
# ls hello.txt


###############################
## Demo: Containerizing 2048 ##
###############################
# 
git clone https://github.com/cerulean-canvas/2048.git
cd 2048
ls

docker run -itd --name 2048 \
-- mount type=bind,source="$(pwd)"/,target=/usr/share/nginx/html \
-p 8080:80 \
nginx:latest


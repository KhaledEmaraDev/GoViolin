# GoViolin

GoViolin is a web app written in Go that helps with violin practice.

Currently hosted on Heroku at https://go-violin.herokuapp.com/

GoViolin allows practice over both 1 and 2 octaves.

Contains:
* Major Scales
* Harmonic and Melodic Minor scales
* Arpeggios
* A set of two part scale duet melodies by Franz Wohlfahrt


# Internship Task
This repo is part of Instabug's Infrastructure internship.

## Golang
I migrated towards Go Modules, because it's the preferred way of dependency management.

## Docker
For Docker I used a multi-stage build to shave off as much space as possible. The first
stage builds the binary, while the second runs it through Apline Linux.

## Jenkins
For Jenkins I used the following plugins in addition to the recommended ones:
* [Docker plugin](https://plugins.jenkins.io/docker-plugin)
* [Docker Pipeline](https://plugins.jenkins.io/docker-workflow)
* [HTML Publisher plugin](https://plugins.jenkins.io/htmlpublisher)

As for reporting the Pipeline generates three reports:
1. golang app tests archived using JUnit after converting the report to a JUnit XML one.
2. golang coverage report generated as HTML and reported using the aforementioned plugin.
3. Email on failure with a link to the build job using `${env.BUILD_URL}`.

As for Docker There were numerous ways to run and build the images. As for building:
1. Use the Docker Pipeline plugin.
2. Use [dind (Docker in Docker)](https://hub.docker.com/_/docker) as a Docker agent.

You have to add your Docker Hub credentials in Jenkins using the following id (docker-hub) to
be able to run the Pipeline and publish the Docker image.

## Kubernetes
As for Kubernetes, I created two manifests:
1. A Deployment manifest to run the Docker image from the Docker Hub registery.
2. A Service manifest to expose the app using a LoadBalancer.
Only one replica runs.

You have to add a Kubernetes secret the stores Docker Hub registery credentials to be
able to pull the image. You can do that in on of the following ways:

1. 
```sh
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```
2. 
```sh
kubectl create secret docker-registry regcred --docker-server=https://registry.hub.docker.com --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

To run the application run the following:
```sh
cd <project-root-directory>
kubectl apply -f kubernetes/go-violin-deployment.yaml
kubectl apply -f kubernetes/go-violin-service.yaml
```
Please, give Kubernetes a minute or two to pull the image and provision the pod.

To access the application you can do one of the following:
1. Use port forwarding
```sh
kubectl port-forward service/go-violin-service 7090:7090
```
2. Use minikube to open a browser session or copy the URL
```sh
minikube service go-violin-service
```

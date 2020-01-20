# hello-world-k8s

## How it works

This repository contains a basic Python Flask application to be deployed on K8s.
This is a just a dummy application to demonstrate K8s capabilities.

The `k8s` directory contains all the K8s manifest templates with variable placeholders to that the Makefile
can subistitute with the actual parameters.

The `k8s-static` directory contains a version of all the K8s manifest with the necessary parameters in place, they  work as a self-contained way to deploy the application using existing Docker images.

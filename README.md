# Azure Arc for Kubernetes

This repository contains useful resources for provisioning Azure resources, Kubernetes clusters and applications

You will create a child repository from this template and use it as a basis of your work.

The rest of the contents are divided into two halves, firstly the unmanaged cluster set up that will provision between 1..n Kubernetes clusters

# Challenge 0

1. Create a child of this repository in your own organisation

# Challenge 1

1. Follow the instructions to [create unmanaged clusters](00-setup)

# Challenge 4

Now you have the clusters set up and connected to Azure you will want to deploy a real application to them. In order to achieve this there are a number of scripts and templates organised for running.

1. Create a new repository for the Application Development team in the same Organisation
2. Generate [infrastructure and deployment resources](01-app-setup)
3. Apply SQL changes as a Database Administrator
4. Use a GitOps approach to deploy the application

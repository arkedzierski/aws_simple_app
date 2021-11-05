# ECS Cluster for Flask apps

A terraform project for creating ECS Fargate Cluster and deploying Flask apps (s3 and DB).
This template has been build as an AWS up-skill activity.

## Prerequisites

    * APPs
        Shall be build using dockerfiles and store on ECR repo (private is recommended) in this same region and on this same AWS account with this same prefix.

    * Backend
        By defualt S3 bucket with DynamoDB table is used. Both must be created separately before used it.

## Input variables

    Please check env.tfvars_example

## How to run

    ```
    terraform plan -var-file=/<path>/<to>/my-env.tfvars
    terraform apply -var-file=/<path>/<to>/my-env.tfvars
    ```

## Verification

    In output loadbalancer DNS name is printed.
    Using this name three endpoints are available:
        * <loadbalancer_dns_name>/db - with list of records in database
        * <loadbalancer_dns_name>/add - page with form allow add new records to database
        * <loadbalancer_dns_name>/s3 - page with list files in S3 bucket as well as form to add new file

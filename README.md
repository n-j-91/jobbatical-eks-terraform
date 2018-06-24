# Jobbatical Kubernetes Assignment
This terraform module will deploy a EKS cluster on us-east-1 region, making use of two availability zones for the worker nodes.
Upon successful cluster creation, this will also deploy a containerized mongo in to the provisioned cluster. A jenkins server will be built afterwards with two preloaded jobs for building a simple todo application written in node. 


##Prerequisites
Please make sure following tools are installed/configured before trying this.

1. Create an AWS IAM user with neccessary permission for provisioning EKS/EC2 and VPC related services. (Preferably an admin user to avoid any privilege issues)

2. Terraform v0.11.7

3. aws-cli/1.15.40 

4. Python/2.7.15

5. heptio-authenticator-aws (EKS leverages IAM user based access via heptio-authenticator)

6. kubectl latest

## How to run
Execute below commands in order

1. Clone the repository.

2. execute "run.sh" script with necessary parameters.

i.e:
Usage: ./run.sh <AWS_ACCESS_KEY> <AWS_SECRET_KEY>  <PATH_TO_SSH_PUBLIC_KEY> <PATH_TO_SSH_PVT_KEY> [AWS_PROFILE_NAME(default: jobbatical)]

run.sh expects the following.
a. Access key for the IAM user created during prereuisites phase.
b. Secret key of the same IAM user.
c. File path to the public key of a key pair.
d. File path to the private key of a key pair.
e. [Optional] A profile name to store the aws credentials. If not specified, a profile called "jobbatical" will be created.

##How to destory

Run terraform destroy

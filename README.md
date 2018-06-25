# Jobbatical Kubernetes Assignment
This terraform module will deploy an EKS cluster on us-east-1 region, making use of two availability zones for the worker nodes.

Upon successful cluster creation, this will also deploy a containerized mongo in to the provisioned cluster. A jenkins server will be built afterwards with two preloaded jobs for building a simple todo application written in node. 

### Note: Check the console output of terraform run to find the Jenkins server IP, Username and Password.

Run 	build-node-todo to create a new docker image for deployment. You can specify the "branch" to build from and a tag to the new docker image. If not specified, code will be pulled from master branch and docker image will be tagged as "latest"

run deploy-node-todo to deploy a specific image to the node-todo application. You should specify the tag given for the build-node-todo job, if you wish to get artifacts for that particular built. If not specified the image with "latest" tag will be deployed.

### Note: Check console output of deploy-node-todo job to find the application url endpoint.


## Prerequisites
Please make sure following tools are installed/configured before trying this.

1. Create an AWS IAM user with neccessary permission for provisioning EKS/EC2 and VPC related services. (Preferably an admin user to avoid any privilege issues)

2. Terraform v0.11.7

3. aws-cli/1.15.40 

4. Python/2.7.15

5. heptio-authenticator-aws (EKS leverages IAM user based access via heptio-authenticator)

6. kubectl latest

More information on how to install these dependencies is listed here, https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

## How to run
Execute below commands in order

1. Clone the repository.

2. execute "run.sh" script with necessary parameters.

i.e:
Usage: ./run.sh \
       <AWS_ACCESS_KEY> \
       <AWS_SECRET_KEY>  \
       <PATH_TO_SSH_PUBLIC_KEY> \
       <PATH_TO_SSH_PVT_KEY> \
       [AWS_PROFILE_NAME(default: jobbatical)]

run.sh expects the following.
a. Access key for the IAM user created during prereuisites phase.
b. Secret key of the same IAM user.
c. File path to the public key of a key pair.
d. File path to the private key of a key pair.
e. [Optional] A profile name to store the aws credentials. If not specified, a profile called "jobbatical" will be created.

## How to Destroy
 
Run terraform destroy.

You will have to provide the same four parameters that were passed to terraform module during resource creation phase.

1. var.access_key
  Enter a value: <AWS_ACCESS_KEY>

2. var.deployer_key_file <PATH TO SSH PUBLIC KEY>

3. var.deployer_pvt_key_file <PATH TO SSH PVT KEY> (During destroy, some remote provisioners are running to destroy kubernetes specific resources like services. Hence this is needed to establish remote connetivity to jenkins server.)

4. var.secret_key
  Enter a value: <AWS_SECRET_KEY>

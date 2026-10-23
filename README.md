# Arno Marais - Terraform Training on AWS

As this project base was provided by Geeks4Learning, we will just build on top of what was provided.

learner_subnets.json file was provided that contains some VPC and subnet information foreach learner to use to assist with setup and we will get to it a little later in this readme.

## Intro

Before we are going to start with any changes, code or config we need to do some requirement gathering.

First off we need to understand what the want is. This project is part of the Terraform training. It consists of some base files that will be used to create an EKS cluster in the shared AWS account (auth details was provided but omitted in this doc for security reasons).

As stated, by the end of this project the acceptance criteria will be a new EKS cluster provisioned in AWS and a vanilla nginx running on a pod. You should be able to navigate to this url to ensure everything is working. 

## First steps

Now that we know what we are workign towards we can start looking at the project and see what is already there. Also read the [Project brief](../Terraform-Project-Cap/project_brief.md) and [Prerequisites](../Terraform-Project-Cap/PREREQUISITES.md) to understand what is needed. Keep tract of the items within this and make sure you are addressing all of them.

We also should agree on some items:

* Naming: All resources to be named as surname-initials-resource-env
* default region is always af-south-1

## Bootstrapping

Before anything is to be created in AWS we first need to bootstrap the backend. This is to keep track of the state as thing changes, gets created or is destroyed. We also need to use a state lock as no changes can happen at the same time by different people or sessions.

For the backend we will be using a S3 bucket to store the state files. We will also be using the s3 state locking.

Something has to create this S3 first for the rest of the project to use it. We also need an AWS role so github oidc can later use it. Both these will be created outside of the main project.

### Step 1 - State

* Create one S3 bucket per ENV (dev, qa, prod). For now we will just create the dev one and comment out the qa and prod ones. Later we can just uncomment them when they need to be created.
* Settings that we will need is:
  * Versioning for recovery
  * Encryption for security
  * blocking public access
* We should add prevent destroy lifecycle so it is not acidentally destroyed.
* Use the dafaults
* Make sure all the backends for each env use this bucket.
* set the use_lockfile = true (Needs Terraform 1.10+ versions)

```bash
cd bootstrap/state
terraform init
terraform validate
terraform plan 
terraform apply
```

NOTE! This will create a local state file to track the changes.

### Step 2 - Github OIDC

* Create a IAM IODC for token.actions.githubusercontent.com
* Create an IAM Role for GitHub Actions to assume
* Set the permissions
* The Role arn in the outputs needs to be added to github as AWS_ROLE_ARN repository variable and read in workflows.

```bash
cd bootstrap/github-oidc
terraform init
terraform validate
terraform plan 
terraform apply
```

### Step 3 - EKS Module

As the module is already provided with some configurations, my first step is to look at what is provided and strip out what can be stripped out to variables, data and locals. It is important to note that dynamic blocks should be used where possible to create multiple instances where possible. I also stripped out jsonencode to aws_iam_policy_document as this makes it more fir to terraform and easy changes.

Make sure that resources makes use of the backend that was created in bootstrapping stages.

Once all required information is there to create the EKS we can move on to using the module in our main.

### Step 4 - Main

We now have the module needed to create the EKS Cluster and worker nodes in our AWS environment. 

[!NOTE]
 We are only creating dev for purpose of the training and the environment set only consist of dev. There is lines commented to add all the other environments if you want to create all environemt components.

Lets setup all the variables that is needed for provisioning the eks. This is sent to the module when making use of it in main.tf

We are also going to need some outputs to verify that everything is created. For simplicity I also added some outputs to copy, past and run in a terminal to deploy or validate the nginx if you manually want to run it. 

### Step 5 - Run
To run this deploy locally follow the next in order.

To install and setup providers and modules and link to the backend.
`terraform init`

Check the format of all you terraform files in this repository.
`terraform fmt -recursive`

As an additional step you can validate your configurations by running
`terraform validate`
This is also done as part of the plan step, but good for an additional check before you plan.

The next step is to create the plan. We will use the dev variables for the purpose of this training. Also the plan will create a tfplan file that is encrypted on your local. This tfpaln file can be named anything. For a real world scenario one will export this file to an artifacts repo during CI where it can be fetched later to run in the apply step during CD. This enables us to customise the Github actions into separate steps where you can introduce steps for approval, review, security checks etc.
`terraform plan -var-file="envs/dev/dev.tfvars" -out "tfplan"`

Now that the plan was successful we can go on to running apply.
`terraform apply "tfplan"`

After a successful apply, you can run a state list to verify that everything needed is there.
`terraform state list`

### Step 6 - K8s and Nginx
Once the cluster is up and running, we can deploy to the created nodes.

First we will have to ensure the kubectl cli is installed when running locally. If not installed install it based on your OS.
[Use this as reference.](https://kubernetes.io/docs/tasks/tools/ "Install Tools | Kubernetes")

Once installed we will need to set our kubeconfig to be able to connect to this cluster. 
`aws eks update-kubeconfig --region af-south-1 --name marais-a-eks-dev`

Please note that you need to use your own cluster name.

Once that is configured you can run the kubectl to apply the default nginx to your cluster node. This will deploy the default nginx with default welcome screen.
`kubectl apply -f k8s/nginx.yaml`

Now you can check you nodes by running.
`kubectl get nodes -o wide && kubectl get pods,svc -o wide`

This will provide you information around your nodes that are running. Take note of the External-IP as that can be used in a browser to reach the nginx Welcome screen. 

### Step 7 - Proof
Please see some screenshots as proof of a successfull deploy.

![alt text](../Terraform-Project-Cap/screenshots/1.png "Welcome Page 1")

![alt text](../Terraform-Project-Cap/screenshots/2.png "Welcome Page 2")

### Step 8 - Destroy

Now that we prooved that the EKS cluster was successfully deployed to our AWS account we can go ahead and destroy what was created.
`terraform destroy`

This will tear down all resources that was created as part of this training. 

Please remember to also destroy the backend!


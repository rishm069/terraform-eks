# Full infra and app task

In this repository a simple Python app is stored along with infrastructure for its deployment.

The app is just a simple FastAPI server that does stuff as per the docs here

## Prerequirements

- - - -

> **IMPORTANT**: this set up is tested on Ubuntu 22.01 but should work on most Linux machines.

* All operations and processes are intended to be performed on a local Linux-machine with the following tool-set installed:

    | Tool          | Version                                                                                      |
    | ------------- |:---------------------------------------------------------------------------------------------|
    | [Docker](https://docs.docker.com/desktop/install/linux-install/)                             | 20.10.21      |
    | [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)                     | v1.25.4       |
    | [helm](https://helm.sh/docs/helm/helm_install/)                                              | v3.10.2       |
    | [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) | v1.3.5        |
    | [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)     | 2.9.0         |
    | [jq](https://stedolan.github.io/jq/download/)                                                | 1.6           |

* `AWS CLI` must be configured as per [the documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

    > **IMPORTANT**: an IAM user with **Administrator permissions** must be used for this setup to work correctly.

* To work locally with dummy app Python ~> `3.11.0` is required as well as modules from [requirements.txt](./app/requirements.txt).

## Quick start

- - - -

To bring up all infrastructure and install the application run the following command:

```bash
make up-all
```

The following infrastructure in AWS is created as a result:

* VPC with subnets
* Security group
* EKS cluster with:
  * A single node of `t3.small` size
  * NGINX ingress controller with corresponding NLB
  * Namespace for the application (default name: `dummy-app`)
* Private repository in ECR (default repository name: `dummy-app`)

After all the infrastructure is deployed successfully, the application is installed via [Helm-chart](./helm/) into namespace for the application.

To check the application locally run:

```bash
make local-check
```

This command will create port forwarding from the app inside EKS to local port 8080, open [http://localhost:8080/](http://localhost:8080/) (should receive `{"Hello":"World"}` as the responce).

### Check ingress with custom domain name

- - - -

To check that ingress is functional use the output of command:

```bash
make get-lb-ip
```

to set up a `CNAME` record in DNS zone of a custom domain and then reinstall the application with this domain specified as follows (`APP_HOSTNAME` variable can also be exported):

```bash
make APP_HOSTNAME=app.example.com helm-deploy
```

For more details see [the documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/using-domain-names-with-elb.html).

## Repository structure and components

- - - -

Application code and configuration is placed into separate folders per component. The following is the description of each component.

### **Python dummy application**

- - - -


*Stored at [./app/](./app/)*

This is an example application taken diretcly from [FastAPI documentaion](https://fastapi.tiangolo.com/#example).

It has been tested with Pyrhon `3.11.0` thus doesn't require `typing` module manual installation.

To run app locally create and activate venv:

```bash
python -m venv ./
source bin/activate
```

Then install `requirements.txt`:

```bash
pip install -r ./requirements.txt
```

And start uvicorn:

```bash
uvicorn main:app --reload
```

### **Dockerfile**

- - - -

*Stored at [./docker/](./docker/)*

Consists of a single Dockerfile that's build and pushed to ECR.

### **Application Helm-chart**

- - - -

The dummy application Helm-chart is based on default Nginx-chart that is generated via [`helm create`](https://helm.sh/docs/helm/helm_create/) command.

Deployment with a single replica and corresponding service and ingress are created by default.

Only default values are provided with `repository` and `tag` being set during deploy. Simple liveness and readiness probes are configured for the [deployment](./helm/templates/deployment.yaml).

### **Terraform configuration**

- - - -

All terraform files are placed in the root module with local `namespaces` module. Deatiled information about providers, resources etc. can be found in subfolder's [README file](./terraform/README.md).

## Makefile refernece

- - - -

* `up-all` - brings up entire infrastructure and installs the application
* `up-infra` - brings up entire infrastructure
* `up-app` - builds app-image, pushes it to ECR and install the app via Helm-chart
* `build-and-push` - builds app-image and pushes it to ECR
* `docker-build` - builds app-image (**requires `docker-login`**)
* `docker-login` - logs into previously created repository in ECR (**requires `configure-kubectl`**)
* `docker-push` - pushes app-image to ECR (**requires `docker-build`**)
* `helm-dry-run` - dry-runs Helm chart without installation
* `helm-deploy` - deploys Helm-chart
* `local-check` - creates port forwarding from app in EKS to local port 8080
* `get-lb-ip` - returns NLB adress
* `configure-kubectl` - auto-configures `kubectl` to work with created EKS
* `auto-terraform-%` - wrapper for auto-approved terraform commands (apply, destroy)

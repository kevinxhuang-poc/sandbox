# README
This Terraform template deploys a VPC environment on IBM Cloud, which includes 2 bastion hosts, an optional admin host, 3 subnets on different zones in a specified region, and various networking components.

## Run it locally
You can deploy the VPC infrastructure components using this Terraform template on your local machine. Make sure you run the correct version of Terraform binary specified in ```versions.tf```, and set the appropriate [input variables](https://www.terraform.io/language/values/variables) for your specific deployment.

### Run Terraform through Docker Compose
You can run Terraform through Docker Compose to avoid the hassle of installing and switching to a specific version of the Terraform binary required by the template. Simply update the ```docker-compose.yaml``` with the version you want.

Assuming Docker is already installed on your machine, you can run ```terraform``` commands through Docker Compose as follows:

```
docker-compose -f docker-compose.yaml run --rm terraform
```
Otherwise, install the ```terraform``` binary somewhere on your PATH and run it directly.

To avoid adding your IBM Cloud credential to the Terraform files, you can set the IBM Cloud API Key with an environment variable.

```
export IC_API_KEY=< your_api_key >
```

To deploy Classic Infrastructure resources, you may also need the following environment variables.

```
export IAAS_CLASSIC_USERNAME=< your_classic_username >
export IAAS_CLASSIC_API_KEY=< your_classic_api_key >
```

### Initialize the working directory
The ```terraform init``` command is used to initialize a working directory containing Terraform configuration files. This is the first command that you need to run after writing a new Terraform configuration or cloning an existing one from a source code repository. It is safe to run this command multiple times.

```
docker-compose -f docker-compose.yaml run --rm terraform init
```
### Provisioning

To check whether the configuration is valid:

```
docker-compose -f docker-compose.yaml run --rm terraform validate
```

To show changes required by the current configuration:

```
docker-compose -f docker-compose.yaml run --rm terraform plan
```

To create or update infrastructure:

```
docker-compose -f docker-compose.yaml run --rm terraform apply
```

To destroy previously-created infrastructure:

```
docker-compose -f docker-compose.yaml run --rm terraform destroy
```
## Run it in an IBM Cloud Schematics Workspace
IBM Cloud Schematics Workspaces, is a hosted solution to create and manage Terraform workspaces on IBM Cloud. You can deploy and manage your VPC environment by [creating a workspace](https://cloud.ibm.com/docs/schematics?topic=schematics-workspace-setup) and pointing it to this GitHub repository.


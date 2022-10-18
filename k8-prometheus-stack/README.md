# k8s rancher-desktop
Contains routines to setup a mock of the EBSA k8s (**v1.19.15**) cluster, providing:
- NGINX ingress
- Hashicorp Vault (running in dev mode, with no persistence), with
  - v1 Secrets backend
  - PKI backend
- Monitoring stack
  - Prometheus
  - Grafana
  - Alertmanager
- Jenkins-App
  - Jenkins

# Prerequisites
- Uninstall Docker-desktop (If already installed)
- Taskfile; Install [Taskfile](https://taskfile.dev/#/installation)
- Point k8s ingresses to localhost via ```/etc/hosts``` (run the following commands):

```bash
$ echo "127.0.0.1   vault.home.local" | sudo tee -a /etc/hosts
$ echo "127.0.0.1   prometheus.home.local" | sudo tee -a /etc/hosts
$ echo "127.0.0.1   grafana.home.local" | sudo tee -a /etc/hosts
$ echo "127.0.0.1   alertmanager.home.local" | sudo tee -a /etc/hosts
$ echo "127.0.0.1   jenkins.home.local" | sudo tee -a /etc/hosts
```

# Installing Rancher Desktop & other tools

```bash
$ git clone ssh://git@bitbucket.bics-collaboration.homeoffice.gov.uk/sre/docker-desktop.git
$ cd docker-desktop

# install pre-requisite tools
# NOTE: requires sudo for writing to /etc/resolver/
# This will install pre-requisite tools specified in the Brewfile as well as rancher desktop with the required configurations
$ task install
```
### Additional configuration setup on Rancher Desktop UI > Kubernetes settings tab:

- Deselect 'Enable Traefik' if selected
- Select Dockerd(moby) as container runtime
- Set memory to 6GB, and CPU to 2 cores

# Installing Vault and Prometheus stacks

```bash
# deploy vault [and setup PKI secrets backend]
# this will generate your own root Certificate Authority using CFSSL, as well as setup Vault PKI as an intermediate CA
# NOTE: vault is setup in dev mode, no data is persisted anywhere - so if your pod restarts, you will have to setup again
# (just run the below command again)
$ task vault:install vault:import:ca

# install prometheus, grafana & alertmanager monitoring stack with a minimal set of service monitors and prometheus rules for reduced noise during development
# NOTE: if you are setting up a CloudWatch datasource in Grafana, then your AWS credentials will expire after a time.

$ task prometheus:install
```
- The above task has helm repo (add and update), ingress and aws credential tasks as dependencies
  - Read the taskfile to have a clear understanding of what is being deployed
- The AWS credentials tend to expire after a while, so run the following command to validate a new set of credentials

```bash
$ task aws:creds:temporary
```
# Installing Jenkins and generating AWS credentials

```bash

# obtain a temporary set of AWS credentials and generate a K8s secret for accessing ECR images (and CloudWatch metrics and logs)
# defaults to,
#   region: eu-west-1
#   account: np
$ task aws:ecr:dns aws:creds:temporary

# to get temporary creds eu-west-2 / np account
$ task aws:ecr:dns aws:creds:temporary AWS_REGION=eu-west-2

# to get temporary creds for eu-west-2 / pr account
$ task aws:ecr:dns aws:creds:temporary AWS_REGION=eu-west-2 AWS_ACCOUNT=pr

# install jenkins app - optional
$ task jenkins:install

# uninstall jenkins app only - optional
$ task jenkins:uninstall

# uninstall jenkins app and all supporting resources - optional
$ task jenkins:uninstall:all

```

Vault should now be available on http://vault.home.local/.

(It is just running over plain HTTP to circumvent issues with certificate trust.)

Monitoring stack should be available on:

- Prometheus http://prometheus.home.local/
- Grafana http://grafana.home.local/
- Alertmanager http://alertmanager.home.local/

Note: Your Grafana username and password is 'admin'

Jenkins-App should be avaliable on:

- Jenkins http://jenkins.home.local/

# Rewriting vault secrets for rds pass
  $ task vault:rewrite-secrets
  Will write vault secrets if that does not already exists, it will be useful then vault pods restarts and secrets erased.
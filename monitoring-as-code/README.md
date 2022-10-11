# Monitoring-as-Code (MaC)

SRE Monitoring-as-Code (MaC) is a Jsonnet Mixin implementation of SLIs/SLO/Error Budgets using the open-source monitoring and alerting eco-system of Prometheus and Grafana. 

## Description

Monitoring Mixins bundle up SLI configuration, Alerting, Grafana dashboards, and Runbooks into a single package. Engineers commit a monitoring definition file and this triggers the packaging of Prometheus Rules and Grafana Dashboards and injects them into the monitoring tools. This way, we can ease up Engineers burden of writing alerting rules, manually drawing up Grafana dashboards, and scribing runbooks.

- Monitoring Mixins<sup>2</sup> are a lightweight flexible configuration, which don’t mandate specific labels or expressions. You can configure and overwrite everything.
- Mixins use data templating language called Jsonnet. The only templating language which has fully supported libraries for Grafana and Prometheus.
- jsonnet-bundler is used for package management. Once you have a Monitoring Mixin package, you need to install it, keep track of versions and update them
- SRE MaC will be open-sourced and live on UKHomeOffice GitHub and can be integrated with any Platform which supports pulling containers from GitHub.
- SLI/SLO/Error Budget configurations match Google SRE<sup>3</sup> industry patterns.

## Installation

**First make sure you have the following dependencies.**

- [docker](https://docs.docker.com)
- [git](https://git-scm.com)

## Docker installation

See GitHub Releases page for most recent tagged version and pull the Docker image: -

`docker pull ghcr.io/ho-cto/sre-monitoring-as-code:{tag}`

## GitHub clone installation

**In a directory of your choosing run the following setup commands.**

```
# Clone the repository to your local machine
git clone git@github.com:HO-CTO/sre-monitoring-as-code.git

# Navigate to repository root directory
cd monitoring-as-code

# Build the dockerfile 
docker build -t sre-monitoring-as-code:latest .
```

## Usage

### Default mixin config 

**To run the default monitoring and summary mixins bundles into the built container run the following command**

```
# Execute makefile script
sh deploy.sh
```

### Custom mixin

**To run a custom mixin file**

```
# Add mixin file <service>-mixin.jsonnet to a directory
touch grapi-mixin.jsonnet

# Execute docker run command based on mounted directory where the mixin file has been added.
docker run --mount type=bind,source="$PWD"/{user input directory},target=/input --mount type=bind,source="$PWD"/{user output directory},target=/output -it sre-monitoring-as-code:{tag} -m {service} -rd -i input -o output
```

### Configuration Arguments

**Arguments to be passed to container at runtime**

| Argument | Description                                                                                                            |
|----------|------------------------------------------------------------------------------------------------------------------------|
| -m       | The name of the mixin to target, must be included                                                                      |
| -o       | The path to the directory where you want the output to be copied to, must be included                                  |
| -i       | The path to the directory containing the mixin file, if not included defaults to mixin-defs directory inside container |
| -a       | The type of account (np, pr or localhost), if not included defaults to localhost                                       |
| -r       | Include if you only want to generate Prometheus rules, both generated if neither included                              |
| -d       | Include if you only want to generate Grafana dashboards, both generated if neither included                            |

## Distribution 

### Add artefacts (dashboard, alerts rules and recording rules) to Grafana and Prometheus package management tooling (Prometheus Operator)

TBC

## Resources

1. [Homeoffice - Monitoring as Code User Documentation](https://ho-cto.github.io/sre-monitoring-as-code/)
2. [Databrick - Jsonnet Style Guide](https://github.com/databricks/jsonnet-style-guide)
3. [Prometheus - Monitoring Mixins](https://monitoring.mixins.dev/)
4. [Google SRE - Implementing SLOs](https://sre.google/workbook/implementing-slos/)
5. [Google SRE - Setting SLOs: a step-by-step guide](https://cloud.google.com/blog/products/management-tools/practical-guide-to-setting-slos)
6. [Liz Fong-Jones - Adopting SRE and Error Budgets](https://youtu.be/7VeU6LnOUms)
7. [GDS - Run a Service Level Indicator workshop](https://gds-way.cloudapps.digital/standards/slis.html#run-a-service-level-indicator-sli-workshop)

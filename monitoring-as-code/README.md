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

**Now in a directory of your choosing run the following setup commands.**

```
# Clone the repository to your local machine
git clone ssh://git@bitbucket.bics-collaboration.homeoffice.gov.uk/sast/monitoring-as-code.git

# Navigate to repository root directory
cd monitoring-as-code

# Build the dockerfile 
docker build -t mac:latest .
```

## Useage

```
# Add mixin file <service>-mixin.jsonnet to /montoring-config
touch grapi-mixin.jsonnet

# Add Global and SLI configuration as per sre-monitoring-as-code docs (see Resources)

# Execute makefile script
sh deploy.sh

# Add artefacts (dashboard, alerts rules and recording rules) to Grafana and Prometheus package management tooling (Prometheus Operator)
```

## Resources

1. [Homeoffice - Montoring as Code User Documentation](https://ho-cto.github.io/sre-monitoring-as-code/)
2. [Databrick - Jsonnet Style Guide](https://github.com/databricks/jsonnet-style-guide)
3. [Prometheus - Monitoring Mixins](https://monitoring.mixins.dev/)
4. [Google SRE - Implementing SLOs](https://sre.google/workbook/implementing-slos/)
5. [Google SRE - Setting SLOs: a step-by-step guide](https://cloud.google.com/blog/products/management-tools/practical-guide-to-setting-slos)
6. [Liz Fong-Jones - Adopting SRE and Error Budgets](https://youtu.be/7VeU6LnOUms)
7. [GDS - Run a Service Level Indicator workshop](https://gds-way.cloudapps.digital/standards/slis.html#run-a-service-level-indicator-sli-workshop)

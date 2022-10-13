# sre-monitoring-as-code

SRE Monitoring-as-Code (MaC) is a Jsonnet Mixin implementation of SLIs/SLO/Error Budgets using the open-source monitoring and alerting eco-system of Prometheus and Grafana. [Our documentation is available to view online](https://ho-cto.github.io/sre-monitoring-as-code/).

## About the framework

Monitoring Mixins bundle up SLI configuration, Alerting, Grafana dashboards, and Runbooks into a single package. Engineers commit a monitoring definition file and this triggers the packaging of Prometheus Rules and Grafana Dashboards and injects them into the monitoring tools. This way, we can ease up engineers' burden of writing alerting rules, manually drawing up Grafana dashboards, and scribing runbooks.

- Monitoring Mixins<sup>1</sup> are a lightweight flexible configuration, which don’t mandate specific labels or expressions. You can configure and overwrite everything.
- Mixins use data templating language called Jsonnet, which is the only templating language which has fully supported libraries for Grafana and Prometheus.
- jsonnet-bundler is used for package management. Once you have a Monitoring Mixin package, you need to install it, keep track of versions and update them
- SRE MaC will be open-sourced and live on UKHomeOffice GitHub and can be integrated with any Platform which supports pulling containers from GitHub.
- SLI/SLO/Error Budget configurations match Google SRE<sup>2</sup> industry patterns.

## Repository structure

| Directory | Description |
| ----------| ----------- |
| `docs/` | Contains the technical documentation for Monitoring-as-Code using Tech Docs Template and Middleman. |
| `local/` | Contains a docker-compose implementation of Prometheus, Thanos, Grafana and Alertmanager. The purpose of this project is to test Monitoring-as-Code locally with your application. |
| `monitoring-as-code/` | Contains the Jsonnet mixin implementation of SLIs/SLO/Error Budgets for Prometheus and Grafana |

`Installation` and `usage` information is provided in a Readme within each of the directories.

## Resources

1. [Prometheus - Monitoring Mixins](https://monitoring.mixins.dev/)
2. [Google SRE - Implementing SLOs](https://sre.google/workbook/implementing-slos/)
3. [Google SRE - Setting SLOs: a step-by-step guide](https://cloud.google.com/blog/products/management-tools/practical-guide-to-setting-slos)
4. [Liz Fong-Jones - Adopting SRE and Error Budgets](https://youtu.be/7VeU6LnOUms)
5. [GDS - Run a Service Level Indicator workshop](https://gds-way.cloudapps.digital/standards/slis.html#run-a-service-level-indicator-sli-workshop)

## Licence

Unless stated otherwise, the codebase is released under [the MIT License](https://opensource.org/licenses/MIT).
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms
of the [Open Government 3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
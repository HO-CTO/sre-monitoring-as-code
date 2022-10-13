# Localdev for Monitoring

L2 Transformer local implementation of Prometheus, Thanos, Grafana, Alertmanager and Yet-Another-Cloudwatch-Exporter using a `docker-compose.yaml` file. The purpose of this project is for proof of concept activity and demos.

## Installation

**First make sure you have the following dependencies.**

- [docker](https://docs.docker.com)
- [git](https://git-scm.com)

**Now in a directory of your choosing run the following setup commands.**

```
# Clone the repository to your local machine
git clone git@github.com:HO-CTO/sre-monitoring-as-code.git

# jump to cloned root directory
cd local
```

## Usage

### Before running the monitoring local environment

1. Create and store required environment variables in a `global.env` file in the root of the directory like this:

```
YACE_ENVIRONMENT_TAG=somethingsomething
AM_SLACK_API_URL=somethingsomething
AM_SLACK_CHANNEL=somethingsomething
```

2. Create and store local application json prometheus scrape config to `prometheus/file_sd_configs/client_app_targets.json` like this:

```
[
  {
    "labels": {
      "job": "localhost/grapi",
      "__metrics_path__": "/grapi/actuator/prometheus",
      "namespace": "localhost"
    },
    "targets": [
      "host.docker.internal:8080"
    ]
  }
]
```

### Running environment WITHOUT cloudwatch exporter

```
# build, start and attach containers for monitoring-local service in detached mode (exlcudes YACE cloudwatch exporter component)
docker-compose up -d
```

### Running environment WITH cloudwatch exporter

```
# build, start and attach containers for full stack monitoring-local service in detached mode (includes all components)
docker-compose --profile monitoring-fullstack up -d
```

## Housekeeping

```
# once local dev complete stop and shut down containers 
docker-compose down

# remove any remaining volumes
docker volume prune
```

## Signposting

The following services will be installed (and some are accessible via browser):

| Component                     | Description                                                               | URL                           |
| -----------------------       | ------------------------------------------------------                    | ----------------------------- |
| grafana                       | Grafana                                                                   | <http://localhost:3000/>      |
| alertmanager                  | Alertmanager                                                              | <http://localhost:9093/>      |
| prometheus-1                  | Prometheus Server 1                                                       | <http://localhost:9081/>      |
| prometheus-2                  | Prometheus Server 2                                                       | <http://localhost:9082/>      |
| thanos-sidecar-1              | Thanos Sidecar for Prometheus Server 1                                    | not accessible via browser    |
| thanos-sidecar-2              | Thanos Sidecar for Prometheus Server 2                                    | not accessible via browser    |
| thanos-querier                | Thanos Query Gateway                                                      | <http://localhost:10902/>     |
| thanos-ruler                  | Thanos Ruler                                                              | <http://localhost:10903/>     |
| thanos-bucket-web             | Thanos Bucket Web                                                         | <http://localhost:10904/>     |
| thanos-store-gateway          | Thanos Store Gateway                                                      | not accessible via browser    |
| thanos-compactor              | Thanos Compactor                                                          | not accessible via browser    |
| yace                          | Yet Another Cloudwatch Exporter                                           | not accessible via browser    |
| minio                         | Minio - Amazon S3 Compatible Object Storage                               | <http://localhost:9001/>      |

## Credentials

Grafana:

```
username - admin
password - l2password
```

Minio:

```
Access Key - l2accesskey
Secret Key - l2secretkey (Keys are stored in the `docker-compose.yaml` file)
```

## Add Thanos Data Source in Grafana
Is already preconfigured via grafana/provisioning/datasources/datasource.yml but check using:

* Open <http://localhost:3000/datasources>
* Choose `Thanos`
* Click the green button `Save & Test`
